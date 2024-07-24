#!/bin/bash

LOG_FILE="/var/log/resource_usage.log"
REMOTE_LOG_SERVER="10.0.1.59"
REMOTE_LOG_PATH="/home/ubuntu/logs-1"

# 현재 날짜 및 시간
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# 애플리케이션 프로세스 ID 찾기
app_pid=$(pgrep -f app)
app2_pid=$(pgrep -f app2)

if [ -n "$app_pid" ]; then
    # app의 CPU 및 메모리 사용량
    cpu_usage=$(ps -p $app_pid -o %cpu=)
    mem_usage=$(ps -p $app_pid -o %mem=)
else
    cpu_usage="N/A"
    mem_usage="N/A"
fi

if [ -n "$app2_pid" ]; then
    # app2의 CPU 및 메모리 사용량
    cpu_usage2=$(ps -p $app2_pid -o %cpu=)
    mem_usage2=$(ps -p $app2_pid -o %mem=)
else
    cpu_usage2="N/A"
    mem_usage2="N/A"
fi

# 로그 파일에 기록
echo "$timestamp, app CPU: $cpu_usage%, app Memory: $mem_usage%, app2 CPU: $cpu_usage2%, app2 Memory: $mem_usage2%" >> $LOG_FILE

# 로그 파일을 원격 서버로 전송
scp $LOG_FILE user@$REMOTE_LOG_SERVER:$REMOTE_LOG_PATH
