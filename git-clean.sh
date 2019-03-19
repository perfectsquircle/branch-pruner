#!/bin/bash

git branch --merged | grep -v master | grep -v develop | xargs git branch -d