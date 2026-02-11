# DEMO

Complete demonstration and testing instructions for cadenroberts.github.io.

## Prerequisites

**Required:**
- Git
- Bash shell
- Python 3 (for local HTTP server)

**Optional:**
- Node.js + npm (for HTML validation via html-validate)
- curl (for HTTP testing)
- Modern web browser (Chrome, Firefox, Safari, Edge)

## Local Demo

### Step 1: Clone Repository

```bash
git clone git@github.com:cadenroberts/cadenroberts.github.io.git
cd cadenroberts.github.io
```

### Step 2: Verify Files

```bash
ls -lh index.html resume.pdf
```

**Expected Output:**
```
-rw-r--r--  1 user  staff   1.7K  index.html
-rw-r--r--  1 user  staff   152K  resume.pdf
```

### Step 3: Run Automated Demo Script

```bash
./scripts/demo.sh
```

**Expected Output:**
```
=== cadenroberts.github.io Demo ===

[1/3] Checking file presence...
✓ index.html found
✓ resume.pdf found

[2/3] Validating PDF integrity...
✓ resume.pdf is valid PDF

[3/3] Validating HTML structure...
✓ index.html contains required elements

SMOKE_OK
```

**If script fails:** See Troubleshooting section below.

### Step 4: Manual Browser Test

**Start local server:**
```bash
python3 -m http.server 8000
```

**Open in browser:**
- Main page: http://localhost:8000/

**Verify:**
1. Resume PDF displays in iframe
2. "Download Resume" button works
3. Layout is centered and responsive

**Stop server:**
```
Ctrl+C
```

---

## Live Site Demo

### Verify Deployment

**Check GitHub Pages status:**
```bash
curl -I https://cadenroberts.github.io/
```

**Expected:**
```
HTTP/2 200
content-type: text/html; charset=utf-8
...
```

**Open in browser:**
https://cadenroberts.github.io/

**Verify:**
1. Site loads over HTTPS (padlock icon in address bar)
2. Resume displays correctly
3. Download button functions
4. Footer shows correct copyright

---

## Update Workflow Demo

### Make a Change

```bash
# Edit HTML (example: update footer year)
sed -i '' 's/2025/2026/g' index.html

# Review changes
git diff
```

### Deploy Change

```bash
# Using sync.sh script
./sync.sh "Clarifying: update copyright year"

# Wait 1-2 minutes for GitHub Pages deployment
sleep 120

# Verify live site updated
curl -s https://cadenroberts.github.io/ | grep 2026
```

**Expected:** Output includes updated copyright year

### Rollback (if needed)

```bash
# View commit history
git log --oneline

# Revert to previous commit
git revert HEAD

# Push revert
./sync.sh "Cleaning: revert copyright change"
```

---

## PDF Replacement Demo

### Replace Resume PDF

```bash
# Backup current resume
cp resume.pdf resume_backup.pdf

# Copy new resume (replace with actual file)
cp /path/to/new_resume.pdf resume.pdf

# Verify PDF is valid
file resume.pdf

# Commit and push
./sync.sh "Refactoring: update resume PDF"
```

**Wait 1-2 minutes, then verify:**
```bash
curl -I https://cadenroberts.github.io/resume.pdf
```

Expected: HTTP 200 with new file size in Content-Length header

---

## CI Workflow Demo

### Trigger CI

```bash
# Make any change
touch .test_ci

# Push to trigger GitHub Actions
./sync.sh "Clarifying: test CI workflow"
```

### Monitor CI

```bash
# View workflow status via gh CLI (if installed)
gh run list --limit 1

# Or visit GitHub Actions page
open https://github.com/cadenroberts/cadenroberts.github.io/actions
```

**Expected:** Workflow completes successfully (green checkmark)

---

## Troubleshooting

### Issue: demo.sh fails on "file presence"

**Diagnosis:**
```bash
ls -la index.html resume.pdf
```

**Fix:** Ensure you're in repository root directory

---

### Issue: demo.sh fails on "PDF validation"

**Diagnosis:**
```bash
file resume.pdf
```

**Fix:** If output is not "PDF document", PDF is corrupt. Re-download or restore from backup.

---

### Issue: Local server port 8000 already in use

**Diagnosis:**
```bash
lsof -i :8000
```

**Fix:**
```bash
# Kill existing server
kill $(lsof -t -i :8000)

# Or use different port
python3 -m http.server 8001
```

---

### Issue: Live site shows old content

**Diagnosis:**
```bash
# Check if push succeeded
git log origin/main -1

# Check GitHub Pages deployment status
gh api repos/cadenroberts/cadenroberts.github.io/pages/builds/latest
```

**Fix:**
- Wait 2-5 minutes for GitHub Pages to deploy
- Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+R)
- Clear browser cache
- Check GitHub Actions for deployment errors

---

### Issue: PDF doesn't display in browser

**Diagnosis:**
- Check browser console for errors (F12 → Console tab)
- Verify file exists: `curl -I http://localhost:8000/resume.pdf`

**Fix:**
- Ensure PDF is not corrupted: `file resume.pdf`
- Try different browser (PDF iframe support varies)
- Use download button to verify PDF is valid

---

## Smoke Test vs Full Demo

### Smoke Test (SMOKE_OK)

**What it tests:**
- File presence
- PDF integrity
- HTML basic structure

**What it doesn't test:**
- Live site deployment
- Cross-browser rendering
- PDF iframe display
- Mobile responsiveness

**When to use:** Quick validation after local changes

### Full Demo (manual)

**Additional verification:**
- Live site accessibility
- Visual rendering in multiple browsers
- Download functionality
- Mobile/tablet views

**When to use:** Before announcing site updates or major changes

---

## Expected Outputs Summary

**scripts/demo.sh:**
```
Final line: SMOKE_OK
Exit code: 0
```

**Local browser test:**
- Resume PDF visible in iframe
- Download button functional
- Layout centered and responsive

**Live site test:**
```
curl -s https://cadenroberts.github.io/ | head -1
<!DOCTYPE html>
```

**CI workflow:**
- GitHub Actions badge: passing
- Workflow duration: < 2 minutes

---

## Limitations

**Cannot fully demo locally:**
- GitHub Pages deployment (requires push to main)
- HTTPS certificate validation (local server is HTTP only)
- CDN caching behavior (local server has no CDN)
- Global availability (local server is localhost only)

**Best-effort local simulation:**
- Local HTTP server simulates file serving
- Manual browser test simulates user experience
- Smoke test validates core functionality

**Full validation requires:**
- Deploying to GitHub Pages
- Testing live site at https://cadenroberts.github.io/
- Waiting for CDN propagation (1-5 minutes)

**Why SMOKE_OK instead of DEMO_OK:**
- Full demo requires external infrastructure (GitHub Pages)
- Cannot deterministically test live deployment from local machine
- Smoke test provides best-possible local validation
- Full demo requires manual verification of live site
