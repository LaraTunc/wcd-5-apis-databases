#!/bin/bash
sudo apt update -y 
sudo apt install python3-pip -y --assume-yes
sudo pip3 install fastapi 
sudo pip3 install uvicorn 
sudo pip3 install pymysql
echo "Fastapi and Uvicorn installed"

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
sudo docker pull laratunc/fastapi_app
echo "Docker image pulled for fastapi app" 

sudo docker run -d --network=host -p 80:80 -e MYSQL_PASSWORD=laratunc -e MYSQL_DATABASE=my_database -e MYSQL_USER=laratunc -e MYSQL_HOST=${db_private_ip} laratunc/fastapi_app


