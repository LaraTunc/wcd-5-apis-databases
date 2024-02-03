#!/bin/bash
sudo apt update -y 
sudo apt install python3-pip -y --assume-yes
sudo pip3 install fastapi 
sudo pip3 install uvicorn 
sudo pip install pymysql
echo "Fastapi and Uvicorn installed"


