set -e

BRANCH="main"
REPO_URL="https://github.com/Guzxx92/Anby-MD.git"

VERSION=$1
MSG=${2:-"Release $VERSION"}

if [ -z "$VERSION" ]; then
  echo "Usage: bash deploy.sh v1.0.0 \"message\""
  exit 1
fi

read -rsp "GitHub Token: " GITHUB_TOKEN
echo

if [ -z "$GITHUB_TOKEN" ]; then
  echo "[!] Token cannot be empty"
  exit 1
fi

export GITHUB_TOKEN
export GIT_TERMINAL_PROMPT=0

ASKPASS=$(mktemp)
trap 'rm -f "$ASKPASS"' EXIT

cat > "$ASKPASS" <<'EOF'
#!/bin/sh
case "$1" in
  *Username*) echo "x-access-token" ;;
  *Password*) echo "$GITHUB_TOKEN" ;;
esac
EOF

chmod 700 "$ASKPASS"
export GIT_ASKPASS="$ASKPASS"

echo "AUTO PUSH PROJECT (GITHUB)"
echo "Repo    : $REPO_URL"
echo "Version : $VERSION"
echo "-------------------------"

if [ ! -d ".git" ]; then
  echo "[+] Initializing new project"
  git init
fi

git branch -M "$BRANCH"

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REPO_URL"
else
  git remote set-url origin "$REPO_URL"
fi

echo "[+] Fetching repository"

if git ls-remote --heads origin "$BRANCH" | grep -q .; then
  git fetch origin "$BRANCH"
  REMOTE_EXISTS=1
else
  REMOTE_EXISTS=0
fi

if git tag -l "$VERSION" | grep -q .; then
  git tag -d "$VERSION"
fi

if git ls-remote --tags origin "refs/tags/$VERSION" | grep -q .; then
  echo "[•••] Removing old remote tag"
  git push origin ":refs/tags/$VERSION"
fi

if command -v gh >/dev/null 2>&1; then
  if GH_TOKEN="$GITHUB_TOKEN" gh release view "$VERSION" >/dev/null 2>&1; then
    echo "[•••] Removing old release"
    GH_TOKEN="$GITHUB_TOKEN" gh release delete "$VERSION" -y
  fi
fi

echo "[+] Adding project files"

git add .

if ! git diff --cached --quiet; then
  git commit -m "$MSG"
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  if [ "$REMOTE_EXISTS" = 1 ]; then
    git checkout -B "$BRANCH" "origin/$BRANCH"
  else
    echo "[!] No files to commit"
    exit 1
  fi
fi

if [ "$REMOTE_EXISTS" = 1 ]; then
  echo "[+] Syncing with GitHub"

  if git merge-base HEAD "origin/$BRANCH" >/dev/null 2>&1; then
    git pull --rebase origin "$BRANCH"
  else
    git merge "origin/$BRANCH" --allow-unrelated-histories --no-edit
  fi
fi

echo "[+] Pushing project"

git push -u origin "$BRANCH"

echo "[+] Creating tag"

git tag -a "$VERSION" -m "$MSG"
git push origin "$VERSION"

if command -v gh >/dev/null 2>&1; then
  GH_TOKEN="$GITHUB_TOKEN" gh release create "$VERSION" \
    --title "$MSG" \
    --notes "Release $VERSION"

  echo "[✓] GitHub Release created"
fi

echo "-------------------------"
echo "[✓] Deployment complete"