const express = require('express');
const app = express();
const mysql = require('mysql2');

// Database connection
const db = mysql.createConnection({
  host: '172.31.74.252', // Private IP of your backend instance
  user: 'my_user', // Your MySQL username
  password: 'my_password', // Your MySQL user password
  database: 'my_database' // Your MySQL database name
});

db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log('MySQL Connected...');
});

// Middleware to parse incoming form data
app.use(express.urlencoded({ extended: true }));

// Route to handle form submissions
app.post('/api/submit', (req, res) => {
  const { name, email } = req.body;

  // Validate form data if necessary

  // Insert form data into the database
  const query = 'INSERT INTO tbl_contact (name, email) VALUES (?, ?)';
  db.query(query, [name, email], (err, results) => {
    if (err) {
      console.error('Error inserting data:', err);
      res.status(500).send('Internal Server Error');
      return;
    }
    res.send('Form submitted successfully');
  });
});

// Default route for testing
app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, '0.0.0.0', () => {
  console.log('Server started on port 3000');
});