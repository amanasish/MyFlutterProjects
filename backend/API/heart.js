const express = require('express');
const router = express.Router();
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');

let heartData = [];
let index = 0;

// CSV path (place sample_heart_rate.csv in API folder)
const csvPath = path.join(__dirname, 'sample_heart_rate.csv');

// Load CSV on server start
fs.createReadStream(csvPath)
  .pipe(csv())
  .on('data', (row) => {
    heartData.push({
      timestamp: row.timestamp,
      heart_rate: Number(row.heart_rate),
      heartbeat_type: row.heartbeat_type
    });
  })
  .on('end', () => console.log('Heart rate CSV loaded. Total rows:', heartData.length));

// API endpoint for current heart reading
router.get('/heart', (req, res) => {
  if (heartData.length === 0) return res.status(500).json({ message: 'Data not loaded' });

  const current = heartData[index % heartData.length];
  index++;

  // Override timestamp to now
  current.timestamp = new Date();

  res.json(current);
});

module.exports = router;
