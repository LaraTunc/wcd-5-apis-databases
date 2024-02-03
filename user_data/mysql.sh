#!/bin/bash
sudo apt update -y
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
sudo ufw allow 3306 # mysql port
echo "MySQL installed"

echo "mysql status is: "
sudo service mysql status

# Wait for MySQL service to star
sleep 10

# Create MySQL user and grant privileges
sudo mysql -u root -p -e "CREATE USER 'laratunc'@'%' IDENTIFIED BY 'laratunc'; \
    GRANT ALL PRIVILEGES ON *.* TO 'laratunc'@'%' WITH GRANT OPTION; \
    FLUSH PRIVILEGES;"

# MySQL commands to create a table and populate it
sudo mysql -e "CREATE DATABASE IF NOT EXISTS my_database;"
sudo mysql -e "USE my_database; CREATE TABLE IF NOT EXISTS nhl_stats (
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
      );"
echo "Database and table created"
