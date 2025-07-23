#!/bin/bash

mkdir -p ~/.config
stow -R -v -t ~ -d ~/.devenv/dot .
