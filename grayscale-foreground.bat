@echo off
REM foreground grayscale (capture crash output)
cd /d C:\ninfer-ada\fusion-kvmem\src-tree\fusion-engine-src\build-sm89\grayscale
ninfer-serve.exe E:\ninfer-win\models\Ternary-Bonsai-2-27B-ninfer-v3.ninfer --host 127.0.0.1 --port 8096 --model-id qwen3.8-27b --max-context 262144 --kv-capacity 262144 --kv-dtype rk4v4 --host-kv-mib 8192 --prefill-chunk 1024 --spec dflash2 --draft-tokens 6 --lm-head-draft --ngram-draft-tokens 8 --default-max-tokens 32768 --default-reasoning-effort none --max-concurrency 1 --max-shared-prefixes 0 --presence-penalty 0 --temperature 0.7 --top-p 0.9 --top-k 20 --thinking-presence-penalty 1.0
echo ENGINE_EXIT=%ERRORLEVEL%
