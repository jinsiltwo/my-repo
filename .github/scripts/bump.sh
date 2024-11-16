#!/usr/bin/env bash

# 깃허브에서 깃 태그를 모두 불러와서 최신 버전 산출
git fetch --tag 2>/dev/null
version="$(git tag --sort=-v:refname | head -1 | sed 's/^v//')"

# 지정한 버전 업데이트 정도에 근건해서 새 버전 산출
IFS='.' read -ra tokens <<<"${version:-0.0.0}"
major="${tokens[0]}"; minor="${tokens[1]}"; patch="${tokens[2]}"
case "$1" in
  major) major="$((major + 1))"; minor=0; patch=0 ;;
  minor) minor="$((minor + 1))"; patch=0 ;;
  patch) patch="$((patch + 1))" ;;
esac

# 깃허브에 풀 버전 태그와 주요 버전 태그를 푸시
git tag "v${major}.${minor}.${patch}"
git tag --force "v${major}" >/dev/null 2>&1
git push --force --tags >/dev/null 2>&1
echo "v${major}.${minor}.${patch}"
