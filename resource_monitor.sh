#!/bin/bash

# 홈 디렉토리 아래의 로그 파일
USER_LOG_DIR="/home/ubuntu/logs"
LOG_FILE="${USER_LOG_DIR}/resource_usage_${HOSTNAME}.log"
LOG_ROTATE_CONFIG="/home/ubuntu/logrotate.conf"

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

# 사용자 디렉토리 아래의 로그 디렉토리 생성
mkdir -p $USER_LOG_DIR

# 로그 파일에 기록
echo "$timestamp, app CPU: $cpu_usage%, app Memory: $mem_usage%" >> $LOG_FILE

# 사용자 홈 디렉토리에 로그 로테이션 설정 파일 생성
cat <<EOF > $LOG_ROTATE_CONFIG
$USER_LOG_DIR/resource_usage_*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0644 ubuntu ubuntu
}
EOF

# 로그 로테이션 수행
logrotate -f $LOG_ROTATE_CONFIG

# 로테이션된 로그 파일을 원격 서버로 전송
# 새로 생성된 로그 파일을 전송
scp $LOG_FILE ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/${HOSTNAME}/

# 로테이션된 로그 파일을 전송
for log_file in $(find $USER_LOG_DIR -name "resource_usage_${HOSTNAME}.log.*" ! -name "resource_usage_${HOSTNAME}.log"); do
    scp $log_file ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/${HOSTNAME}/
done
