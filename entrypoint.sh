#!/bin/bash
set -e

# server.pidが存在する場合に削除する
rm -f /growth_note/tmp/pids/server.pid

# コンテナのメインプロセスを実行
exec "$@"