#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./clean_latex_aux.sh [target_dir] [--dry-run]

Removes common LaTeX auxiliary/build files recursively.
- target_dir: Directory to clean (default: current directory)
- --dry-run: Show what would be removed without deleting

Examples:
  ./clean_latex_aux.sh
  ./clean_latex_aux.sh acad
  ./clean_latex_aux.sh "acad/opportunities/Job Application - Researcher" --dry-run
EOF
}

TARGET_DIR="."
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    *)
      TARGET_DIR="$arg"
      ;;
  esac
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: target directory not found: $TARGET_DIR" >&2
  exit 1
fi

patterns=(
  "*.aux" "*.bbl" "*.bcf" "*.blg" "*.fdb_latexmk" "*.fls"
  "*.idx" "*.ilg" "*.ind" "*.lof" "*.log" "*.lot" "*.out"
  "*.run.xml" "*.synctex.gz" "*.toc" "*.xdv" "*.nav" "*.snm"
  "*.vrb" "*.acn" "*.acr" "*.alg" "*.glg" "*.glo" "*.gls" "*.ist"
)

find_args=("$TARGET_DIR" "-type" "f" "-not" "-path" "*/.git/*" "(")
for i in "${!patterns[@]}"; do
  if [[ "$i" -gt 0 ]]; then
    find_args+=("-o")
  fi
  find_args+=("-name" "${patterns[$i]}")
done
find_args+=(")" "-print0")

files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find "${find_args[@]}")

minted_dirs=()
while IFS= read -r -d '' d; do
  minted_dirs+=("$d")
done < <(find "$TARGET_DIR" -type d -name "_minted-*" -not -path "*/.git/*" -print0)

file_count=${#files[@]}
dir_count=${#minted_dirs[@]}

echo "Target: $TARGET_DIR"
echo "Aux files found: $file_count"
echo "Minted dirs found: $dir_count"

if [[ "$file_count" -eq 0 && "$dir_count" -eq 0 ]]; then
  echo "Nothing to clean."
  exit 0
fi

if [[ "$DRY_RUN" == true ]]; then
  echo
  echo "Dry run: these items would be removed:"
  if [[ "$file_count" -gt 0 ]]; then
    for f in "${files[@]}"; do
      echo "  FILE $f"
    done
  fi
  if [[ "$dir_count" -gt 0 ]]; then
    for d in "${minted_dirs[@]}"; do
      echo "  DIR  $d"
    done
  fi
  exit 0
fi

if [[ "$file_count" -gt 0 ]]; then
  for f in "${files[@]}"; do
    rm -f "$f"
  done
fi

if [[ "$dir_count" -gt 0 ]]; then
  for d in "${minted_dirs[@]}"; do
    rm -rf "$d"
  done
fi

echo "Cleanup complete. Removed $file_count files and $dir_count directories."
