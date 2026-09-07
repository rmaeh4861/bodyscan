# 코드스페이스 ↔ 내 컴퓨터(Claude Code 작업폴더) ↔ 배포 연동 가이드

## 구조 한눈에
```
내 컴퓨터 Claude 작업폴더  ──git push──▶  GitHub 저장소(bodyscan)  ──자동배포──▶  Vercel
        ▲                                     ▲
        └── git pull ─────────────────────────┘◀── Codespaces (브라우저에서 편집·미리보기·영상 업로드)
```
GitHub 저장소가 "진실의 원본"입니다. 어디서 작업하든 push 하면 나머지가 따라옵니다.

## 1. 저장소 만들기 (최초 1회, 5분)
1. github.com → New repository → 이름 `bodyscan` (Private 권장) → Create
2. 이 폴더(index.html, videos/, check_videos.sh, .devcontainer 등)를 통째로 업로드
   - 브라우저: 저장소 페이지 → "uploading an existing file" → 드래그 → Commit
   - 또는 터미널:
     ```bash
     cd bodyscan
     git init && git add . && git commit -m "v5: 영상 자동연결"
     git branch -M main
     git remote add origin https://github.com/<내아이디>/bodyscan.git
     git push -u origin main
     ```

## 2. 내 컴퓨터 Claude Code 작업폴더와 연동
```bash
cd ~/claude-work            # Claude Code를 쓰는 폴더 (본인 경로로)
git clone https://github.com/<내아이디>/bodyscan.git
cd bodyscan
```
이제 Claude Code에서 `cd ~/claude-work/bodyscan` 하고 index.html을 수정하면 됩니다.
반영: `git add . && git commit -m "메시지" && git push`

## 3. Codespaces 열기
저장소 페이지 → 초록 `Code` 버튼 → `Codespaces` 탭 → `Create codespace on main`
- `.devcontainer` 덕분에 ffmpeg·serve가 자동 설치됩니다 (첫 생성 2~3분).
- 미리보기: 터미널에 `serve .` → 뜨는 3000 포트 링크 클릭 → 폰에서도 열림(포트를 Public으로 바꾸면 QR 없이 폰으로 테스트 가능).

## 4. 영상 업로드 (핵심 워크플로우)
1. CapCut에서 내보낸 mp4를 **키 이름**으로 저장 → `videos/README.md` 표 참고 (예 `forwardhead.mp4`)
2. 10MB 넘으면 압축 (Codespaces 터미널에서도 됨):
   ```bash
   ffmpeg -i 원본.mp4 -vf scale=-2:720 -c:v libx264 -crf 28 -c:a aac -b:a 96k videos/forwardhead.mp4
   ```
3. 올리기 — 세 방법 중 아무거나:
   - **Codespaces**: 왼쪽 탐색기 `videos` 폴더에 드래그 앤 드롭 → Source Control(Ctrl+Shift+G) → 메시지 입력 → Commit & Push
   - **내 컴퓨터**: `videos/`에 복사 → `git add videos && git commit -m "add forwardhead" && git push`
   - **GitHub 웹**: videos 폴더 → Add file → Upload files
4. `bash check_videos.sh` 로 남은 항목 확인. 코드 수정 없이 결과 화면에 자동 표시됩니다.

## 5. Vercel 배포 (이미 unbalancetest 프로젝트가 있으면 저장소만 연결)
Vercel → Add New → Project → GitHub `bodyscan` 선택 → Framework: Other → Deploy.
이후 push 할 때마다 자동 재배포. 정적 파일이라 별도 설정 없음.

## 주의사항 (돈·시간 아끼는 포인트)
- GitHub 개별 파일 100MB 초과 시 push 거부. 압축해서 10MB 이하 유지가 정답. 23개 × 10MB = 230MB면 저장소·Vercel 모두 무료 범위.
- 영상이 계속 늘어나거나 4K 원본을 보관하고 싶으면: 원본은 `raw/`(gitignore 됨)에 두고 압축본만 커밋. 그래도 부족하면 Vercel Blob 또는 YouTube 비공개 링크로 전환(그때는 `video:'https://...'`로 덮어쓰기).
- 파일명 오타(대문자, 공백, `.MP4`)가 "영상 준비 중"의 90% 원인입니다. check_videos.sh로 확인하세요.
- Codespaces 무료 한도: 월 60시간. 안 쓸 때는 Stop.
