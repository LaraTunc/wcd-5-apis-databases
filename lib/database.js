const seed = require("./seed");

const database = (function () {
  var conn = null,
    init = async (client) => {
      console.log("Trying to connect to postgres");

      await client.connect();

      conn = client.connection;
      conn.on("error", console.error.bind(console, "connection error:"));
      conn.once("open", () => console.log("db connection open"));

      await seed(client);

      return conn;
    },
    close = () => {
      if (conn) {
        conn.close(() => {
          console.log(
            "Postgres default connection disconnected through app termination"
          );
          process.exit(0);
        });
      }
    };

  return {
    init: init,
    close: close,
  };
})();

module.exports = database;
