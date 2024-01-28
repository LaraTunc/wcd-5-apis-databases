const express = require("express");
const database = require("./lib/database");
const favicon = require("serve-favicon");
const router = express.Router();
require("dotenv").config();
const { Client } = require("pg");

const app = express();

console.log("process.env.HOST", process.env.HOST ?? "localhost");
console.log("process.env.PASSWORD", process.env.PASSWORD ?? "mypassword");

// Create postgresql client
const client = new Client({
  user: process.env.POSTGRES_USER ?? "postgres",
  host: process.env.HOST ?? "localhost",
  database: process.env.POSTGRES_DB ?? "postgres",
  password: process.env.PASSWORD ?? "lara2021",
  port: 5432,
});

database.init(client);

// favicon
app.use(favicon(__dirname + "/public/images/favicon.ico"));

// Mount the router
app.use("/", router);

// Route for /
// Returns the first 10 rows from the data
router.get("/", (req, res) => {
  client.query("SELECT * FROM nhl_stats LIMIT 10", (error, results) => {
    if (error) {
      console.error("Error retrieving data:", error);
      res.status(500).send("Error retrieving data from database");
    } else {
      res.status(200).json(results.rows);
    }
  });
});

// Route for /players
// Returns the first 10 players from the data
router.get("/players", (req, res) => {
  client.query(
    "SELECT playername FROM nhl_stats LIMIT 10",
    (error, results) => {
      if (error) {
        console.error("Error retrieving data:", error);
        res.status(500).send("Error retrieving data from database");
      } else {
        res.status(200).json(results.rows);
      }
    }
  );
});

// Route for /toronto
// Returns all players from the Toronto Maple Leafs
router.get("/toronto", (req, res) => {
  client.query(
    "SELECT playername FROM nhl_stats WHERE team = 'TOR'",
    (error, results, fields) => {
      if (error) {
        console.error("Error retrieving data:", error);
        res.status(500).send("Error retrieving data from database");
      } else {
        res.status(200).json(results.rows);
      }
    }
  );
});

// Route for /points
// Returns top 10 players leading in points scored
router.get("/points", (req, res) => {
  client.query(
    "SELECT playername, pts FROM nhl_stats ORDER BY pts LIMIT 10",
    (error, results, fields) => {
      if (error) {
        console.error("Error retrieving data:", error);
        res.status(500).send("Error retrieving data from database");
      } else {
        res.status(200).json(results.rows);
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
