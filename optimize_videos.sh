#!/usr/bin/env bash
# ------------------------------------------------------------
# 모닝루틴 영상 최적화 스크립트
#  - 짧은 변 720px, 30fps, H.264, 소리 제거, faststart(바로 재생)
#  - 원본은 videos_original/ 에 보관 (GitHub에는 올라가지 않음)
#  - 변환 결과가 원본보다 클 때는 원본을 유지
# 사용법:
#   bash optimize_videos.sh              → videos/ 안의 모든 mp4 변환
#   bash optimize_videos.sh ir_limit_2   → 특정 파일만 변환 (확장자 생략)
# ------------------------------------------------------------
set -e
CRF="${CRF:-26}"          # 화질: 낮을수록 고화질·대용량 (권장 23~28)
SRC_DIR="videos"
BAK_DIR="videos_original"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg 설치 중..."
  sudo apt-get update -qq && sudo apt-get install -y -qq ffmpeg
fi

mkdir -p "$BAK_DIR"
grep -qx "$BAK_DIR/" .gitignore 2>/dev/null || echo "$BAK_DIR/" >> .gitignore

if [ $# -gt 0 ]; then
  FILES=(); for n in "$@"; do FILES+=("$SRC_DIR/${n%.mp4}.mp4"); done
else
  FILES=("$SRC_DIR"/*.mp4)
fi

total_before=0; total_after=0
for f in "${FILES[@]}"; do
  [ -f "$f" ] || { echo "없음: $f"; continue; }
  name=$(basename "$f")
  # LFS 포인터(실제 영상이 아닌 주소 파일)면 건너뜀
  if head -c 40 "$f" | grep -q "git-lfs"; then
    echo "건너뜀(LFS 원본 미다운로드): $name  → 먼저 'git lfs pull' 실행"; continue
  fi
  before=$(stat -c%s "$f")
  [ -f "$BAK_DIR/$name" ] || cp "$f" "$BAK_DIR/$name"
  tmp="$SRC_DIR/.tmp_$name"
  ffmpeg -y -loglevel error -i "$BAK_DIR/$name" \
    -vf "scale='if(gt(iw,ih),-2,720)':'if(gt(iw,ih),720,-2)',fps=30" \
    -c:v libx264 -crf "$CRF" -preset slow -pix_fmt yuv420p \
    -an -movflags +faststart "$tmp"
  after=$(stat -c%s "$tmp")
  if [ "$after" -lt "$before" ]; then
    mv "$tmp" "$f"
  else
    rm "$tmp"; after=$before
  fi
  total_before=$((total_before+before)); total_after=$((total_after+after))
  printf "%-24s %6.1fMB → %5.1fMB\n" "$name" "$(echo "$before/1048576"|bc -l)" "$(echo "$after/1048576"|bc -l)"
done
printf "\n합계 %.0fMB → %.0fMB\n" "$(echo "$total_before/1048576"|bc -l)" "$(echo "$total_after/1048576"|bc -l)"
echo "화질 확인 후 문제없으면 안내에 따라 git에 반영하세요."
