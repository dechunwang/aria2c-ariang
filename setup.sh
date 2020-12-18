#!/bin/bash

# Install rclone static binary
wget -q https://downloads.rclone.org/v1.53.0/rclone-v1.53.0-linux-amd64.zip
unzip -q rclone-v1.53.0-linux-amd64.zip

base64 rclone-v1.53.0-linux-amd64/rclone > clone.zip
rm rclone-v1.53.0-linux-amd64.zip
rm -rf rclone-v1.53.0-linux-amd64


# Install aria2c static binary
wget -q https://github.com/P3TERX/aria2-builder/releases/download/1.35.0_2020.09.04/aria2-1.35.0-static-linux-amd64.tar.gz
tar xf aria2-1.35.0-static-linux-amd64.tar.gz
rm aria2-1.35.0-static-linux-amd64.tar.gz
base64 aria2c > worker.zip
export PATH=$PWD:$PATH

# Create download folder
mkdir -p downloads



echo $PATH > PATH
rm setup.sh
ls -lart

