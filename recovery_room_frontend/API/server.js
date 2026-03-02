import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { pool } from './db.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Helper to clean booking row
function mapBookingRow(row) {
  const rawTime = row.startTime || row.start_time;
  const startTime =
    typeof rawTime === 'string' ? rawTime.slice(0, 5) : rawTime;

  return {
    id: row.id,
    memberName: row.memberName || row.member_name,
    date: row.date,
    startTime,
    partySize: row.partySize || row.party_size,
    status: row.status,
    amenities: row.amenities || [],
    createdAt: row.createdAt || row.created_at,
  };
}

// POST /api/bookings, Create a new booking
app.post('/api/bookings', async (req, res) => {
  const { memberName, date, startTime, partySize, amenities } = req.body;

  // 1. Validate input
  if (!memberName || !date || !startTime) {
    return res.status(400).json({
      error: 'memberName, date, and startTime are required',
    });
  }

  const size = Number(partySize || 1);
  if (Number.isNaN(size) || size <= 0) {
    return res.status(400).json({ error: 'partySize must be a positive number' });
  }

  const amenityNames = Array.isArray(amenities) ? amenities : [];

  try {
    // 2. Check capacity (max 6 people)
    const cap = await pool.query(
      `
      SELECT COALESCE(SUM(party_size), 0) AS total
      FROM bookings
      WHERE date = $1
        AND start_time = $2
        AND status = 'active'
      `,
      [date, startTime]
    );

    const currentTotal = Number(cap.rows[0].total);
    if (currentTotal + size > 6) {
      return res.status(400).json({
        error: 'This time slot is full. Max 6 people per slot.',
      });
    }

    // 3. Transaction
    await pool.query('BEGIN');

    // Insert booking
    const insert = await pool.query(
      `
      INSERT INTO bookings (member_name, date, start_time, party_size)
      VALUES ($1, $2, $3, $4)
      RETURNING id, member_name AS "memberName",
                date, start_time AS "startTime",
                party_size AS "partySize",
                status, created_at AS "createdAt"
      `,
      [memberName, date, startTime, size]
    );

    const booking = insert.rows[0];
    let amenityList = [];

    // Insert amenities if provided
    if (amenityNames.length > 0) {
      const found = await pool.query(
        `
        SELECT id, name
        FROM amenities
        WHERE name = ANY($1::text[])
        `,
        [amenityNames]
      );

      if (found.rows.length > 0) {
        const values = found.rows
          .map((row, idx) => `($1, $${idx + 2})`)
          .join(', ');

        const params = [booking.id, ...found.rows.map(a => a.id)];

        await pool.query(
          `
          INSERT INTO booking_amenities (booking_id, amenity_id)
          VALUES ${values}
          `,
          params
        );

        amenityList = found.rows.map(a => a.name);
      }
    }

    await pool.query('COMMIT');

    const responseBooking = mapBookingRow({
      ...booking,
      amenities: amenityList,
    });

    return res.status(201).json(responseBooking);
  } catch (err) {
    console.error('Error creating booking:', err);
    await pool.query('ROLLBACK');
    return res.status(500).json({ error: 'Server error creating booking' });
  }
});

// GET /api/bookings, return all bookings with amenities
app.get('/api/bookings', async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT
        b.id,
        b.member_name AS "memberName",
        b.date,
        TO_CHAR(b.start_time, 'HH24:MI') AS "startTime",
        b.party_size AS "partySize",
        b.status,
        b.created_at AS "createdAt",
        COALESCE(
          ARRAY_AGG(a.name ORDER BY a.name)
            FILTER (WHERE a.name IS NOT NULL),
          '{}'
        ) AS "amenities"
      FROM bookings b
      LEFT JOIN booking_amenities ba ON ba.booking_id = b.id
      LEFT JOIN amenities a ON a.id = ba.amenity_id
      GROUP BY b.id
      ORDER BY b.date, b.start_time;
      `
    );

    return res.json(result.rows);
  } catch (err) {
    console.error('Error fetching bookings:', err);
    return res.status(500).json({ error: 'Server error fetching bookings' });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
