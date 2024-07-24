#!/bin/bash
LOG_FILE=/var/log/resource_usage.log
timestamp=$(date '+%Y-%m-%d %H:%M:%S')
cpu_usage=$(top -b -n1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
disk_usage=$(df -h | grep '/dev/sda1' | awk '{print $5}')
echo "$timestamp, CPU: $cpu_usage%, Memory: $mem_usage%, Disk: $disk_usage" >> $LOG_FILE
chown ubuntu:ubuntu $LOG_FILE
chmod 644 $LOG_FILE
