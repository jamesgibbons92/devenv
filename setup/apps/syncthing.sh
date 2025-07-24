#!/bin/bash

systemctl enable syncthing@$(whoami).service
systemctl start syncthing@$(whoami).service
