# EVALUATION

## Correctness Definition

The site is correct if:

1. **HTML Validity:** index.html conforms to HTML5 specification
2. **Resource Availability:** resume.pdf is present and accessible
3. **Navigation Integrity:** All navigation links resolve correctly
4. **HTTPS Delivery:** Site is served over HTTPS without certificate errors
5. **PDF Rendering:** PDF displays in modern browsers via iframe

## Measurable Commands

### 1. HTML Validation

**Command:**
```bash
npx html-validate index.html
```

**Expected Output:**
```
✔ index.html

1 file validated
```

**Pass Criteria:** Zero errors, zero warnings

**Alternative (W3C Validator):**
```bash
curl -H "Content-Type: text/html; charset=utf-8" \
     --data-binary @index.html \
     https://validator.w3.org/nu/?out=text
```

Expected: No errors or warnings

---

### 2. File Presence Check

**Command:**
```bash
test -f index.html && \
test -f resume.pdf && \
echo "PASS: All files present" || echo "FAIL: Missing files"
```

**Expected Output:**
```
PASS: All files present
```

**Pass Criteria:** Exit code 0

---

### 3. PDF Integrity Check

**Command:**
```bash
file resume.pdf
```

**Expected Output:**
```
resume.pdf: PDF document, version 1.X
```

**Pass Criteria:** File identified as valid PDF document

**Alternative (detailed check):**
```bash
pdfinfo resume.pdf && echo "PASS"
```

---

### 4. Link Integrity Check

**Command:**
```bash
grep -E 'href="[^"]*"' index.html | \
grep -v 'http' | \
sed 's/.*href="\([^"]*\)".*/\1/' | \
while read link; do
  base=$(echo "$link" | sed 's/#.*//')
  if [ -n "$base" ] && [ ! -f "$base" ]; then
    echo "FAIL: Missing $base"
    exit 1
  fi
done && echo "PASS: All local links valid"
```

**Expected Output:**
```
PASS: All local links valid
```

**Pass Criteria:** No missing link targets

---

### 5. Local Server Test

**Command:**
```bash
python3 -m http.server 8000 &
SERVER_PID=$!
sleep 2
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/ | \
  grep -q "200" && echo "PASS: Server responds" || echo "FAIL"
kill $SERVER_PID
```

**Expected Output:**
```
PASS: Server responds
```

**Pass Criteria:** HTTP 200 response

---

### 6. Live Site Availability

**Command:**
```bash
curl -s -o /dev/null -w "%{http_code}" https://cadenroberts.github.io/ | \
  grep -q "200" && echo "PASS: Live site accessible" || echo "FAIL"
```

**Expected Output:**
```
PASS: Live site accessible
```

**Pass Criteria:** HTTP 200 response over HTTPS

---

### 7. PDF Resource Loading

**Command:**
```bash
curl -s -I https://cadenroberts.github.io/resume.pdf | head -1 | grep -q "200"
echo "PASS: PDF accessible"
```

**Expected Output:**
```
PASS: PDF accessible
```

**Pass Criteria:** PDF returns HTTP 200

---

## Performance Expectations

### Load Time Targets

| Resource | Size | Target Load Time | Network |
|----------|------|------------------|---------|
| index.html | 1.7 KB | < 100ms | Broadband |
| resume.pdf | 152 KB | < 500ms | Broadband |

### Performance Measurement

**Command (requires Chrome/Chromium):**
```bash
npx lighthouse https://cadenroberts.github.io/ \
  --only-categories=performance \
  --output=json \
  --quiet | \
  jq '.categories.performance.score * 100'
```

**Pass Criteria:** Performance score >= 90

**Manual Test:**
1. Open Chrome DevTools (F12)
2. Navigate to Network tab
3. Hard reload (Cmd+Shift+R / Ctrl+Shift+R)
4. Check "DOMContentLoaded" event time (should be < 300ms)
5. Check "Load" event time (should be < 1s)

---

## Pass/Fail Criteria

### Automated Smoke Test

**Command:**
```bash
./scripts/demo.sh
```

**Pass Criteria:**
- Exit code 0
- Final line of output: `SMOKE_OK`

**Failure Modes:**
- Exit code 1: Critical test failure
- Missing `SMOKE_OK`: Incomplete execution
- Error messages in output: Specific test failure

### Full Manual Verification Checklist

- [ ] HTML validates without errors (npx html-validate)
- [ ] All files present (test -f)
- [ ] PDF is valid (file command)
- [ ] Local links resolve (grep + test)
- [ ] Local server serves pages (python3 -m http.server)
- [ ] Live site returns HTTP 200
- [ ] PDF loads on live site
- [ ] Download button triggers download
- [ ] Page layout renders correctly in Chrome
- [ ] Page layout renders correctly in Firefox
- [ ] Page layout renders correctly in Safari
- [ ] PDF renders in iframe on desktop
- [ ] PDF renders in iframe on mobile

### Acceptance Criteria

**Minimum (SMOKE_OK):**
- HTML file valid
- PDF file present and valid
- Local server test passes

**Full (DEMO_OK - not achievable without live deployment):**
- All minimum criteria
- Live site accessible
- Cross-browser rendering verified
- Mobile rendering verified

---

## Regression Testing

After any change, run:

```bash
# Quick validation
./scripts/demo.sh

# Full validation
npx html-validate index.html
test -f resume.pdf && echo "OK"
python3 -m http.server 8000 &
sleep 2
curl -s http://localhost:8000/ | grep -q "Caden Roberts" && echo "OK"
killall python3
```

**Expected:** All checks pass

---

## Known Limitations

**Cannot Test Automatically:**
- Visual rendering (requires screenshot comparison)
- Cross-browser compatibility (requires multiple browser instances)
- Mobile responsiveness (requires device or emulator)
- PDF rendering quality (subjective, browser-dependent)
- Accessibility (requires screen reader or automated tools like axe)

**Not Tested:**
- User interactions (button clicks - requires browser automation)
- Download functionality (download attribute behavior)
- Print styling (CSS @media print)
- Dark mode rendering (depends on OS/browser settings)

**Workarounds:**
- Manual testing for visual/UX validation
- Browser DevTools for responsive design testing
- Lighthouse CI for accessibility baseline
