const fs = require("fs");
const csv = require("csv-parser");

function seedDatabase(pool) {
  pool.query(
    `
    CREATE TABLE IF NOT EXISTS nhl_stats (
      PlayerName VARCHAR(255),
      Team VARCHAR(255),
      Pos VARCHAR(255),
      Games INT,
      G INT,
      A INT,
      Pts INT,
      PlusMinus INT,
      PIM INT,
      SOG INT,
      GWG INT,
      PP_G INT,
      PP_A INT,
      SH_G INT,
      SH_A INT,
      Def_Hits INT,
      Def_BS INT
    )
  `,
    (error) => {
      if (error) {
        console.error("Error creating table:", error);
      } else {
        console.log("Table created successfully");
        // Read the CSV file and insert data into the database
        fs.createReadStream("./data/nhl-stats.csv")
          .pipe(csv())
          .on("data", (row) => {
            pool.query(
              "INSERT INTO nhl_stats (PlayerName, Team, Pos, Games, G, A, Pts, PlusMinus, PIM, SOG, GWG, PP-G, PP-A, SH-G, SH-A, Def-Hits, Def-BS) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
              [
                row["Player Name"],
                row["Team"],
                row["Pos"],
                row["Games"],
                row["G"],
                row["A"],
                row["Pts"],
                row["+/-"],
                row["PIM"],
                row["SOG"],
                row["GWG"],
                row["PP-G"],
                row["PP-A"],
                row["SH-G"],
                row["SH-A"],
                row["Def-Hits"],
                row["Def-BS"],
              ],
              (error, results, fields) => {
                if (error) {
                  console.error("Error inserting data:", error);
                } else {
                  console.log("Data inserted successfully");
                }
              }
            );
          })
          .on("end", () => {
            console.log("Database seeded successfully");
          });
      }
    }
  );
}

module.exports = seedDatabase;
