const fs = require("fs");
const csv = require("csv-parser");

const seedDatabase = async (client) => {
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS nhl_stats (
        playername VARCHAR(255),
        team VARCHAR(255),
        pos VARCHAR(255),
        games INT,
        g INT,
        a INT,
        pts INT,
        plusminus INT,
        pim INT,
        sog INT,
        gwg INT,
        pp_g INT,
        pp_a INT,
        sh_g INT,
        sh_a INT,
        def_hits INT,
        def_bs INT
      )
    `);

    console.log("Table created successfully");

    // Read data from CSV file
    fs.createReadStream("./data/nhl-stats.csv")
      .pipe(csv())
      .on("data", async (row) => {
        // Insert data into the database
        const values = Object.values(row);
        await client.query(
          'INSERT INTO nhl_stats ("playername", "team", "pos", "games", "g", "a", "pts", "plusminus", "pim", "sog", "gwg", "pp_g", "pp_a", "sh_g", "sh_a", "def_hits", "def_bs") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)',
          values
        );
      })
      .on("end", () => {
        console.log("CSV file successfully processed");
      });
  } catch (error) {
    console.error("Error seeding database:", error);
  }
};

module.exports = seedDatabase;
