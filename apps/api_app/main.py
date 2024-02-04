import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pymysql
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class MyApi(BaseModel):
    name: str

@app.get("/")
async def get_all():
    logger.info("Handling GET request to /")
    connection = pymysql.connect(host= os.environ.get('MYSQL_HOST') or "localhost", 
                                 port=3306, 
                                 user= os.environ.get('MYSQL_USER'),
                                 password= os.environ.get('MYSQL_PASSWORD'),
                                 database= os.environ.get('MYSQL_DATABASE'))
    
    try:
        # Execute SQL query to retrieve all items from the table
        with connection.cursor() as cursor:
            sql = "SELECT * FROM nhl_stats LIMIT 10"
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.info("Successfully retrieved 10 items from the database", result)
    except pymysql.MySQLError as e:
        logger.error(f"MySQL Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"MySQL Error: {str(e)}")
    finally:
        connection.close()

    return result 

@app.get("/players")
async def get_players():
    logger.info("Handling GET request to /players")
    connection = pymysql.connect(host= os.environ.get('MYSQL_HOST') or "localhost", 
                                 port=3306, 
                                 user= os.environ.get('MYSQL_USER'),
                                 password= os.environ.get('MYSQL_PASSWORD'),
                                 database= os.environ.get('MYSQL_DATABASE'))
    
    try:
        # Execute SQL query to retrieve all items from the table
        with connection.cursor() as cursor:
            sql = "SELECT playername FROM nhl_stats LIMIT 10"
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.info("Successfully retrieved 10 players from the database", result)
    except pymysql.MySQLError as e:
        logger.error(f"MySQL Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"MySQL Error: {str(e)}")
    finally:
        connection.close()

    return result

@app.get("/toronto")
async def get_toronto():
    logger.info("Handling GET request to /toronto")
    connection = pymysql.connect(host= os.environ.get('MYSQL_HOST') or "localhost", 
                                 port=3306, 
                                 user= os.environ.get('MYSQL_USER'),
                                 password= os.environ.get('MYSQL_PASSWORD'),
                                 database= os.environ.get('MYSQL_DATABASE'))
    
    try:
        # Execute SQL query to retrieve all items from the table
        with connection.cursor() as cursor:
            sql = "SELECT playername FROM nhl_stats WHERE team = 'TOR'"
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.info("Successfully retrieved Toronto players from the database", result)
    except pymysql.MySQLError as e:
        logger.error(f"MySQL Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"MySQL Error: {str(e)}")
    finally:
        connection.close()

    return result

@app.get("/points")
async def get_points():
    logger.info("Handling GET request to /points")
    connection = pymysql.connect(host= os.environ.get('MYSQL_HOST') or "localhost", 
                                 port=3306, 
                                 user= os.environ.get('MYSQL_USER'),
                                 password= os.environ.get('MYSQL_PASSWORD'),
                                 database= os.environ.get('MYSQL_DATABASE'))
    
    try:
        # Execute SQL query to retrieve all items from the table
        with connection.cursor() as cursor:
            sql = "SELECT playername, pts FROM nhl_stats ORDER BY pts LIMIT 10"
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.info("Successfully retrieved players with the most amount of points from the database", result)
    except pymysql.MySQLError as e:
        logger.error(f"MySQL Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"MySQL Error: {str(e)}")
    finally:
        connection.close()

    return result


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)

# --host 0.0.0.0: Uvicorn binds to all available network interfaces on the EC2 instance, allowing it to listen for incoming connections from any source. This means that Uvicorn will listen for connections on all network interfaces, including the public IP address of the public EC2 instance.
# port 80 connects it to the root url of the ec2 instance

