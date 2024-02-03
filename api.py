import logging
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pymysql

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class Item(BaseModel):
    name: str

@app.get("/")
async def get_items():
    logger.info("Handling GET request to /")
    # Connect to MySQL database on private EC2 instance ***** DONT FORGET TO CHANGE THE IP
    connection = pymysql.connect(host='<private_ec2_private_ip>', 
                                 user='',
                                 password='',
                                 database='my_database')
    
    try:
        # Execute SQL query to retrieve all items from the table
        with connection.cursor() as cursor:
            sql = "SELECT * FROM my_table"
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.info("Successfully retrieved items from the database", result)
    except pymysql.MySQLError as e:
        logger.error(f"MySQL Error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"MySQL Error: {str(e)}")
    finally:
        connection.close()

    return [{"id": row[0], "name": row[1]} for row in result]


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)

# --host 0.0.0.0 option, Uvicorn binds to all available network interfaces on the EC2 instance, allowing it to listen for incoming connections from any source. This means that Uvicorn will listen for connections on all network interfaces, including the public IP address of your public EC2 instance.
# port 80 connects it to the root url of the ec2 instance

# Command to run it on ec2 
# sudo uvicorn main:app --host 0.0.0.0 --port 80
# http://<public_ec2_public_ip>/items

