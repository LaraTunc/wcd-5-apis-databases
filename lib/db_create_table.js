const mysql = require("mysql");

function createTable(pool) {
  const createTableQuery = `
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
  `;
  pool.query(createTableQuery, (error, results, fields) => {
    if (error) {
      console.error("Error creating table:", error);
    } else {
      console.log("Table created successfully");
    }
  });
}

module.exports = createTable;
