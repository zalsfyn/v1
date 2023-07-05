#!/bin/bash
wget -q -O /usr/bin/yow "https://raw.githubusercontent.com/zalsfyn/v1/main/serv-updater.sh" && chmod +x /usr/bin/yow
screen -S updss yow
