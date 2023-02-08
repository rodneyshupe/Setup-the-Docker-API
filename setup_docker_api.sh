#!/usr/bin/env bash

#Check if script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "ERROR: This script must be run as root" 1>&2
   exit 1
fi

echo "This script is to setup the Docker API"

if [ -f /lib/systemd/system/docker.service ]; then
    echo "Update Docker Service File to start http API..."
    if egrep -q '^\w*ExecStart=' /lib/systemd/system/docker.service \
    && ! sudo egrep -q '^\w*ExecStart=.* -H=tcp://0.0.0.0:2375.*' /lib/systemd/system/docker.service; then
        sudo sed -i -e 's/^\(\w*ExecStart=.*\)$/\1 -H=tcp:\/\/0.0.0.0:2375/' /lib/systemd/system/docker.service
    fi

    echo "Reload and Restart Service..."
    sudo systemctl daemon-reload
    sudo service docker restart
else
    echo "ERROR:Docker Service not found!"
    exist 404
fi

echo "Docker API setup."
echo
echo "Check service status with: sudo ${status_cmd}"
echo "Test with: curl http://localhost:2375/images/json"
