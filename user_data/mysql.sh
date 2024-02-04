#!/bin/bash
sudo apt update -y
sudo apt install mysql-server -y

# Backup the original MySQL configuration file
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.orig

# Edit the MySQL configuration file to change the bind address
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Allow MySQL port in firewall
sudo ufw allow 3306 # mysql port
echo "MySQL installed"

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

# Install Docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 
echo "Docker installed"
sudo docker pull laratunc/mysql_app
echo "Docker image pulled that will populate the database"
sudo docker run -d --network=host -e MYSQL_PASSWORD=laratunc -e MYSQL_DATABASE=my_database -e MYSQL_USER=laratunc laratunc/mysql_app 

