#!/usr/bin/env python3

import os
import pymysql
import boto3

s3 = boto3.client("s3")

s3.download_file("lara-2023-02-03-bucket", "nhl-stats.csv", "/usr/local/bin/nhl-stats.csv")

# MySQL connection settings
connection = pymysql.connect(host= os.environ.get('MYSQL_HOST') or 'localhost',
                             user= os.environ.get('MYSQL_USER'), 
                             password= os.environ.get('MYSQL_PASSWORD'),
                             database= os.environ.get('MYSQL_DATABASE'))

try:
    with connection.cursor() as cursor:
        # Create temporary table
        cursor.execute('''CREATE TEMPORARY TABLE temp_nhl_stats (
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
                        );''')

        # Read data from CSV file and insert into temporary table
        with open('/usr/local/bin/nhl-stats.csv', 'r') as file:
            next(file)  # Skip header row
            for line in file:
                values = line.strip().split(',')
                cursor.execute('''INSERT INTO temp_nhl_stats
                                    (playername, team, pos, games, g, a, pts, plusminus, pim, sog, gwg, pp_g, pp_a, sh_g, sh_a, def_hits, def_bs)
                                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);''', values)

        # Move data from temporary table to permanent table
        cursor.execute('''INSERT INTO nhl_stats
                            SELECT * FROM temp_nhl_stats;''')

        # Drop temporary table
        cursor.execute('''DROP TABLE IF EXISTS temp_nhl_stats;''')

    connection.commit()

finally:
    connection.close()
