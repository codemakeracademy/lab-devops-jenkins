#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

sudo docker-compose up -d

docker update --restart unless-stopped jenkins-docker
docker update --restart unless-stopped sonarqube
docker update --restart unless-stopped socat
docker update --restart unless-stopped postgres