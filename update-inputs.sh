#!/bin/sh

cp flake.lock "flake.lock.bk.$(date +%s)"

nix flake update hardware
nix flake update home-manager
nix flake update nixpkgs
