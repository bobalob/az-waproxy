#!/bin/bash

sudo apt update
sudo apt -y install docker docker-compose htop tmux
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
cd /opt
sudo git clone https://github.com/WhatsApp/proxy/
cd
sudo docker build /opt/proxy/proxy/ -t whatsapp_proxy:1.0
sudo sed -i 's/\/root\/whatsapp_proxy\/docker-compose.yml/\/opt\/proxy\/proxy\/ops\/docker-compose.yml/g' /opt/proxy/proxy/ops/docker_boot.service
sudo sed -i 's/\/root\/wa/\/opt\/proxy\/proxy/g' /opt/proxy/proxy/ops/docker_boot.service
sudo sed -i 's/docker compose/docker-compose/g' /opt/proxy/proxy/ops/docker_boot.service
sudo cp -v /opt/proxy/proxy/ops/docker_boot.service /etc/systemd/system/
sudo systemctl enable docker_boot.service
sudo systemctl start docker_boot.service
sudo systemctl status docker_boot.service
