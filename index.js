const express = require("express");
const mysql = require("mysql");
const seedDatabase = require("./lib/db_seed");
const createTable = require("./lib/db_create_table");
const favicon = require("serve-favicon");
const router = express.Router();

const app = express();

// Create MySQL connection pool
const pool = mysql.createPool({
  host: "mysql", // Docker container hostname
  user: "myuser",
  password: "mypassword",
  database: "mydb",
});

seedDatabase(pool);

// favicon
app.use(favicon(__dirname + "/public/images/favicon.ico"));

// Mount the router
app.use("/", router);

// Route for /
router.get("/", (req, res) => {
  res.status(200).send("Hello, world!");
  // pool.query("SELECT * FROM nhl_stats LIMIT 10", (error, results, fields) => {
  //   if (error) {
  //     console.error("Error retrieving data:", error);
  //     res.status(500).send("Error retrieving data from database");
  //   } else {
  //     res.status(200).json(results);
  //   }
  // });
});

// Route for /players
router.get("/players", (req, res) => {
  pool.query("SELECT * FROM nhl_stats", (error, results, fields) => {
    if (error) {
      console.error("Error retrieving data:", error);
      res.status(500).send("Error retrieving data from database");
    } else {
      res.status(200).json(results);
    }
  });
});

// Route for /toronto
router.get("/toronto", (req, res) => {
  pool.query(
    "SELECT * FROM nhl_stats WHERE Team = ?",
    ["TOR"],
    (error, results, fields) => {
      if (error) {
        console.error("Error retrieving data:", error);
        res.status(500).send("Error retrieving data from database");
      } else {
        res.status(200).json(results);
      }
    }
  );
});

// catch 404 and forward to error handler
app.use((req, res, next) => {
  var err = new Error("Not Found");
  err.status = 404;
  next(err);
});

// error handlers
app.use((err, req, res, next) => {
  res.status(err.status || 500).json({
    message: err.message,
    error: err,
  });
});

// Start the Express server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
