#!/bin/bash

sudo pacman -Qtdq | sudo pacman -Rns -
sudo pacman -Scc
