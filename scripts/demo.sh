#!/usr/bin/env bash
set -euo pipefail

echo "=== cadenroberts.github.io Demo ==="
echo

# Test 1: File presence
echo "[1/4] Checking file presence..."
for file in index.html transcript.html resume.pdf transcript.pdf; do
  if [ ! -f "$file" ]; then
    echo "✗ Missing: $file"
    exit 1
  fi
  echo "✓ $file found"
done
echo

# Test 2: PDF integrity
echo "[2/4] Validating PDF integrity..."
for pdf in resume.pdf transcript.pdf; do
  if ! file "$pdf" | grep -q "PDF document"; then
    echo "✗ Invalid PDF: $pdf"
    exit 1
  fi
  echo "✓ $pdf is valid PDF"
done
echo

# Test 3: HTML structure validation
echo "[3/4] Validating HTML structure..."

# Check index.html
if ! grep -q "<!DOCTYPE html>" index.html; then
  echo "✗ index.html missing DOCTYPE"
  exit 1
fi
if ! grep -q 'src="resume.pdf' index.html; then
  echo "✗ index.html missing resume.pdf iframe"
  exit 1
fi
if ! grep -q 'href="transcript.html"' index.html; then
  echo "✗ index.html missing transcript link"
  exit 1
fi
echo "✓ index.html contains required elements"

# Check transcript.html
if ! grep -q "<!DOCTYPE html>" transcript.html; then
  echo "✗ transcript.html missing DOCTYPE"
  exit 1
fi
if ! grep -q 'src="transcript.pdf' transcript.html; then
  echo "✗ transcript.html missing transcript.pdf iframe"
  exit 1
fi
if ! grep -q 'href="index.html"' transcript.html; then
  echo "✗ transcript.html missing back link"
  exit 1
fi
echo "✓ transcript.html contains required elements"
echo

# Test 4: Local server test
echo "[4/4] Testing local server..."

# Start server in background
python3 -m http.server 8000 > /dev/null 2>&1 &
SERVER_PID=$!
echo "✓ Server started on port 8000"

# Wait for server to be ready
sleep 2

# Test HTTP request
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/ | grep -q "200"; then
  echo "✗ Server did not respond with HTTP 200"
  kill $SERVER_PID 2>/dev/null || true
  exit 1
fi
echo "✓ index.html loads successfully"

# Stop server
kill $SERVER_PID 2>/dev/null || true
sleep 1
echo "✓ Server stopped"
echo

# All tests passed
echo "SMOKE_OK"
