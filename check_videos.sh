#!/usr/bin/env bash
# 어떤 키에 영상이 있고 없는지 한눈에 확인
cd "$(dirname "$0")"
keys=$(grep -oE "^  [a-z_0-9]+:\{t:" index.html | sed -E 's/^  ([a-z_0-9]+):.*/\1/')
ok=0; miss=0
for k in $keys; do
  if [ -f "videos/$k.mp4" ]; then sz=$(du -h "videos/$k.mp4" | cut -f1); echo "✅ $k.mp4 ($sz)"; ok=$((ok+1));
  else echo "⬜ $k.mp4  (없음)"; miss=$((miss+1)); fi
done
echo; echo "완료 $ok / 미완료 $miss"
