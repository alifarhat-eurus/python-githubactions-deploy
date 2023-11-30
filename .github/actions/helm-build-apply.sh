#!/bin/bash
cd helm/helmfile.d
./helmfile build --environment lower -f $1
./helmfile apply --environment lower -f $1