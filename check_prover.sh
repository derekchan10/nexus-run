#!/bin/bash

# 设置日志文件
LOG_FILE="check_prover.log"

# 记录日志的函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# 检查是否提供了 group 参数
if [ $# -ne 1 ]; then
    log "请提供 group 参数"
    echo "使用方法: $0 <group>"
    exit 1
fi

GROUP="$1"
log "使用 Group: $GROUP"

# 检查 prover-id 文件是否存在
PROVER_FILE="$HOME/.nexus/prover-id"
if [ ! -f "$PROVER_FILE" ]; then
    log "未找到 prover-id 文件"
    exit 1
fi

# 读取 prover-id
PROVER_ID=$(cat "$PROVER_FILE")
if [ -z "$PROVER_ID" ]; then
    log "prover-id 为空"
    exit 1
fi

# 获取主机名
HOSTNAME=$(hostname)

# 组装消息内容
MESSAGE="主机: ${HOSTNAME}, Prover ID: ${PROVER_ID}"

# URL编码消息内容
ENCODED_MESSAGE=$(echo "$MESSAGE" | sed 's/ /%20/g')

# 推送到 API
PUSH_URL="https://api.day.app/d46cXUJyJ6HesiUJTPXXTd/${ENCODED_MESSAGE}?group=${GROUP}"
RESPONSE=$(curl -s "$PUSH_URL")

# 检查推送结果
if echo "$RESPONSE" | grep -q '"code":200'; then
    log "推送成功"
else
    log "推送失败: $RESPONSE"
    exit 1
fi 