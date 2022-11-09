#!/bin/bash

sudo apt update && sudo apt upgrade -y /
sudo timedatectl set-timezone Europe/Berlin /
sudo apt install htop btop speedtest-cli -y /
curl -sfL https://get.k3s.io | sh -
