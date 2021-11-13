#!/bin/bash
echo "> get process id"
ID=$(ps -aux | grep "su rstpusr -c" | awk '{ print $2 }')

kill $ID && kill -15 1