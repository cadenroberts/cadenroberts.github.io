#!/usr/bin/env bash
set -euo pipefail

echo "=== cadenroberts.github.io Demo ==="
echo

# Test 1: File presence
echo "[1/3] Checking file presence..."
for file in index.html resume.pdf; do
  if [ ! -f "$file" ]; then
    echo "✗ Missing: $file"
    exit 1
  fi
  echo "✓ $file found"
done
echo

# Test 2: PDF integrity
echo "[2/3] Validating PDF integrity..."
if ! file "resume.pdf" | grep -q "PDF document"; then
  echo "✗ Invalid PDF: resume.pdf"
  exit 1
fi
echo "✓ resume.pdf is valid PDF"
echo

# Test 3: HTML structure validation
echo "[3/3] Validating HTML structure..."

# Check index.html
if ! grep -q "<!DOCTYPE html>" index.html; then
  echo "✗ index.html missing DOCTYPE"
  exit 1
fi
if ! grep -q 'src="resume.pdf' index.html; then
  echo "✗ index.html missing resume.pdf iframe"
  exit 1
fi
echo "✓ index.html contains required elements"
echo

# All tests passed
echo "SMOKE_OK"
