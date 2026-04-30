#!/bin/bash

# ==========================================
# Banana Pi (bpi) Remote Execution Script
# ==========================================

REMOTE_HOST="bpi"
REMOTE_DIR="~/ime_workspace/example"
LOCAL_DIR="./example"
FILES="vmadot.c Makefile"

echo "=========================================="
echo "🚀 Transferring source code to Banana Pi (bpi) board..."
echo "=========================================="

# 1. Create working directory on the board
ssh $REMOTE_HOST "mkdir -p $REMOTE_DIR"

# 2. Transfer files (scp)
for file in $FILES; do
    echo "  -> Sending $file..."
    scp $LOCAL_DIR/$file $REMOTE_HOST:$REMOTE_DIR/
done

echo ""
echo "=========================================="
echo "⚙️  Starting native compilation and execution on the board..."
echo "=========================================="

# 3. Compile (make) and execute (make run) on the board
ssh $REMOTE_HOST "cd $REMOTE_DIR && make clean && make run"

echo "=========================================="
echo "✅ Remote execution completed"
echo "=========================================="
