#!/bin/bash
#
# EC2 自動關機腳本
# 監控 HTTP 連接，閒置 30 分鐘後自動關機
#
# 安裝方式：
#   sudo cp scripts/auto_shutdown.sh /usr/local/bin/
#   sudo chmod +x /usr/local/bin/auto_shutdown.sh
#   sudo crontab -e
#   # 加入: */5 * * * * /usr/local/bin/auto_shutdown.sh >> /var/log/auto_shutdown.log 2>&1
#

# 設定
IDLE_THRESHOLD_MINUTES=30
STATE_FILE="/tmp/ec2_last_activity"
LOG_PREFIX="[auto-shutdown]"

# 取得當前時間戳
NOW=$(date +%s)

# 檢查是否有 HTTP 連接（排除監控檢查）
check_activity() {
    # 方法 1: 檢查 nginx/docker 的連接數
    local connections=$(netstat -an 2>/dev/null | grep -E ':80|:443' | grep ESTABLISHED | wc -l)

    # 方法 2: 檢查 docker logs 最近的請求（排除健康檢查）
    local recent_logs=$(docker logs home_stock_web_1 --since 5m 2>/dev/null | grep -v '__health' | grep -v 'health_check' | grep -E 'GET|POST|PUT|DELETE' | wc -l)

    # 如果有連接或最近有請求，視為活動中
    if [ "$connections" -gt 0 ] || [ "$recent_logs" -gt 0 ]; then
        return 0  # 有活動
    fi

    return 1  # 無活動
}

# 主邏輯
main() {
    echo "$LOG_PREFIX $(date '+%Y-%m-%d %H:%M:%S') - Checking activity..."

    if check_activity; then
        # 有活動，更新最後活動時間
        echo "$NOW" > "$STATE_FILE"
        echo "$LOG_PREFIX Activity detected, reset timer"
        exit 0
    fi

    # 無活動，檢查上次活動時間
    if [ -f "$STATE_FILE" ]; then
        LAST_ACTIVITY=$(cat "$STATE_FILE")
    else
        # 首次運行，初始化
        echo "$NOW" > "$STATE_FILE"
        echo "$LOG_PREFIX First run, initialized state file"
        exit 0
    fi

    # 計算閒置時間
    IDLE_SECONDS=$((NOW - LAST_ACTIVITY))
    IDLE_MINUTES=$((IDLE_SECONDS / 60))

    echo "$LOG_PREFIX No activity for ${IDLE_MINUTES} minutes (threshold: ${IDLE_THRESHOLD_MINUTES})"

    # 檢查是否超過閾值
    if [ "$IDLE_MINUTES" -ge "$IDLE_THRESHOLD_MINUTES" ]; then
        echo "$LOG_PREFIX Idle threshold reached, shutting down..."

        # 確保不是在部署中
        if pgrep -f "docker pull" > /dev/null || pgrep -f "docker compose" > /dev/null; then
            echo "$LOG_PREFIX Deployment in progress, skipping shutdown"
            exit 0
        fi

        # 關機前的清理
        echo "$LOG_PREFIX Stopping containers gracefully..."
        docker compose -f ~/docker-compose.yml down 2>/dev/null || true

        echo "$LOG_PREFIX Initiating shutdown..."
        sudo shutdown -h now
    fi
}

main
