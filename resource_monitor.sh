#!/bin/bash

# 리소스 사용량을 기록할 로그 파일
LOG_FILE="/var/log/resource_usage.log"
LOG_ROTATE_CONFIG="/etc/logrotate.d/resource_usage"

# 원격 서버 설정
REMOTE_USER="ubuntu"
REMOTE_HOST="10.0.1.59"
REMOTE_PATH="/home/ubuntu/logs-1"

# 현재 날짜 및 시간
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# 애플리케이션 프로세스 ID 찾기 (JAR 파일 기준)
app_pid=$(ps -ef | grep '[j]ava -jar /home/ubuntu/inclass-spring-security-0.0.1-SNAPSHOT.jar' | awk '{print $2}' | head -n 1)

if [[ -n "$app_pid" && "$app_pid" =~ ^[0-9]+$ ]]; then
    # app의 CPU 및 메모리 사용량
    cpu_usage=$(ps -p $app_pid -o %cpu=)
    mem_usage=$(ps -p $app_pid -o %mem=)
else
    cpu_usage="N/A"
    mem_usage="N/A"
fi

# 로그 파일에 기록
echo "$timestamp, app CPU: $cpu_usage%, app Memory: $mem_usage%" >> $LOG_FILE

# 로그 로테이션 수행
logrotate -f $LOG_ROTATE_CONFIG

# 로테이션된 로그 파일을 원격 서버로 전송
# 새로 생성된 로그 파일을 전송
scp $LOG_FILE ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}

# 로테이션된 로그 파일을 전송
for log_file in $(find /var/log -name 'resource_usage.log.*' ! -name 'resource_usage.log'); do
    scp $log_file ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}
done
