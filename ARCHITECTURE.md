# ARCHITECTURE

## System Overview

cadenroberts.github.io is a static website consisting of two HTML pages that embed PDF documents. The site is hosted on GitHub Pages and requires no server-side processing or build step.

## Component Diagram

```
┌────────────────────────────────────────────────────────────┐
│                      GitHub Repository                      │
│                cadenroberts/cadenroberts.github.io          │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  index.html  │  │transcript.htm│  │   *.pdf      │     │
│  │              │  │              │  │   files      │     │
│  │  (1.7 KB)    │  │  (1.7 KB)    │  │  (3.5 MB)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└────────────────────────────────────────────────────────────┘
                            │
                            │ Git push to main
                            ▼
┌────────────────────────────────────────────────────────────┐
│                    GitHub Pages Service                     │
│                                                              │
│  - Automatic build trigger on push to main                  │
│  - Serves static files via CDN                              │
│  - HTTPS via github.io domain                               │
│                                                              │
└────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS requests
                            ▼
┌────────────────────────────────────────────────────────────┐
│                       End User Browser                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐   │
│  │           HTML Parser & CSS Engine                  │   │
│  │                                                      │   │
│  │  Renders: headers, navigation, footer, iframe       │   │
│  └────────────────────────────────────────────────────┘   │
│                            │                                │
│                            │ iframe src attribute           │
│                            ▼                                │
│  ┌────────────────────────────────────────────────────┐   │
│  │          Native PDF Renderer                        │   │
│  │                                                      │   │
│  │  Displays: resume.pdf or transcript.pdf             │   │
│  └────────────────────────────────────────────────────┘   │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

## Execution Flow

### Initial Page Load (index.html)

1. **Request:** User navigates to https://cadenroberts.github.io
2. **DNS Resolution:** Browser resolves domain to GitHub Pages CDN
3. **TLS Handshake:** HTTPS connection established
4. **HTML Fetch:** Browser requests index.html (default document)
5. **HTML Parse:** Browser parses HTML structure
6. **CSS Parse:** Browser parses inline `<style>` block
7. **Layout:** Browser computes layout for flexbox-based structure
8. **Paint:** Browser renders header, navigation buttons, iframe placeholder, footer
9. **Subresource Load:** Browser initiates fetch for `resume.pdf` (iframe src)
10. **PDF Render:** Browser's native PDF plugin renders document in iframe
11. **Complete:** Page is interactive

### Navigation to Transcript

1. **Click Event:** User clicks "View Transcript" button
2. **Navigation:** Browser navigates to transcript.html
3. **Repeat Steps 4-11:** Same flow as above, but loading transcript.pdf

### Download Action

1. **Click Event:** User clicks "Download Resume" or "Download Transcript"
2. **Download API:** Browser triggers download via `download` attribute
3. **File Save:** Browser saves PDF to user's download directory

## Contracts Between Components

### HTML → PDF Contract

**Interface:** HTML `<iframe>` element  
**Attributes:**
- `src`: Path to PDF file (relative URL)
- `class`: CSS class for styling
- URL fragment: `#toolbar=0&navpanes=0&scrollbar=0` (PDF.js parameters)

**Expectations:**
- PDF file must exist at specified path
- PDF must be valid format
- Browser must support native PDF rendering

**Failure Mode:**
- Missing PDF: Browser shows 404 error in iframe
- Corrupt PDF: Browser shows error message or blank iframe
- Unsupported browser: No fallback, empty iframe

### HTML → GitHub Pages Contract

**Interface:** Git repository files in `main` branch  
**Expectations:**
- Files must be UTF-8 encoded (HTML) or binary (PDF)
- index.html must exist in repository root
- No build configuration required

**Behavior:**
- Deployment triggered automatically on push to main
- Deployment completes within 1-5 minutes
- All files in repository root are publicly accessible

**Failure Mode:**
- Invalid HTML: GitHub Pages still serves it; browser handles errors
- Missing index.html: GitHub Pages shows 404
- Repository disabled: Site returns 404

### CSS → Browser Contract

**Interface:** Inline `<style>` block with CSS3 rules  
**Features Used:**
- CSS custom properties (`:root`, `var()`)
- Flexbox layout
- Media queries (implicit via `color-scheme`)
- Pseudo-classes (`:hover`)
- Modern units (`rem`, `vh`, `aspect-ratio`)

**Expectations:**
- Modern browser (Chrome 90+, Firefox 88+, Safari 14+, Edge 90+)
- CSS support for flexbox, custom properties, aspect-ratio

**Failure Mode:**
- Old browsers: Degrade gracefully (no aspect-ratio → fixed height, no custom properties → white background)

## Failure Modes

### Deployment Failures

**Scenario:** GitHub Pages deployment fails  
**Detection:** Site serves stale content or 404  
**Recovery:** Inspect GitHub Actions logs, fix issue, re-push  
**Impact:** Site unavailable or outdated during failure  

### PDF Loading Failures

**Scenario:** PDF file missing or corrupt  
**Detection:** Iframe shows error or blank content  
**Recovery:** Replace PDF file, push to repository  
**Impact:** Document not viewable, download link broken  

### Browser Incompatibility

**Scenario:** User on browser without PDF support  
**Detection:** Empty iframe, no error message  
**Recovery:** None automated; user must download PDF  
**Impact:** Degraded experience, PDF not viewable inline  

### CDN/Network Failures

**Scenario:** GitHub Pages CDN unavailable or user network issues  
**Detection:** Browser timeout or connection error  
**Recovery:** Wait for CDN restoration or network recovery  
**Impact:** Site completely unavailable  

### HTML Syntax Errors

**Scenario:** Malformed HTML introduced via manual editing  
**Detection:** Page renders incorrectly or partially  
**Recovery:** Fix HTML, push correction  
**Impact:** Visual layout broken, navigation may fail  

## Observability

### Available Metrics

**GitHub Repository:**
- Commit history (via `git log`)
- File sizes (via `ls -lh`)
- Last modified timestamps (via `git log --format="%ai"`)

**GitHub Pages:**
- Traffic data (via GitHub repository > Insights > Traffic)
- Unique visitors (14-day rolling window)
- Page views (14-day rolling window)
- Referring sites

**Browser DevTools (Client-Side):**
- Network timing (DOMContentLoaded, Load events)
- Resource sizes and load times
- Console errors (JavaScript, CSS, network)
- Lighthouse scores (performance, accessibility, SEO)

### Missing Observability

- No server-side logs
- No real-time analytics
- No error tracking (no JavaScript error reporting)
- No PDF view/download conversion tracking
- No user behavior analytics (heatmaps, scroll depth)

### Monitoring Strategy

**Pre-Deployment:**
1. Validate HTML with W3C validator
2. Test locally with Python HTTP server
3. Verify file sizes and PDF integrity

**Post-Deployment:**
1. Manual smoke test of live site
2. Check GitHub Pages deployment status
3. Review traffic metrics weekly via GitHub Insights

**Continuous:**
- No automated monitoring
- Rely on user reports for issues
- Check repository traffic monthly

### Debugging Approach

**Issue:** Page not loading  
**Steps:**
1. Check GitHub Pages status (Settings > Pages)
2. Verify branch is `main` and source is root
3. Check GitHub Actions for deployment errors
4. Test DNS resolution: `nslookup cadenroberts.github.io`
5. Test HTTPS connection: `curl -I https://cadenroberts.github.io`

**Issue:** PDF not displaying  
**Steps:**
1. Verify file exists: `test -f resume.pdf`
2. Check file size: `ls -lh resume.pdf`
3. Validate PDF: `file resume.pdf`
4. Test in different browser
5. Check browser console for errors

**Issue:** Layout broken  
**Steps:**
1. Validate HTML: `npx html-validate index.html`
2. Check CSS syntax in browser DevTools
3. Test on different screen sizes
4. Review recent commits for HTML changes

## Performance Characteristics

**Page Load (index.html):**
- Time to First Byte (TTFB): 50-200ms (GitHub Pages CDN)
- DOM Content Loaded: 100-300ms
- Fully Loaded (with resume.pdf): 500-1000ms

**Page Load (transcript.html):**
- TTFB: 50-200ms
- DOM Content Loaded: 100-300ms
- Fully Loaded (with transcript.pdf): 2000-4000ms (larger file)

**Resource Sizes:**
- index.html: 1.7 KB (compressed)
- transcript.html: 1.7 KB (compressed)
- resume.pdf: 152 KB
- transcript.pdf: 3.4 MB

**Bandwidth:**
- First visit (index): ~154 KB
- First visit (transcript): ~3.4 MB
- Return visits: Cached, near-zero bandwidth

**Scalability:**
- GitHub Pages serves millions of requests/day
- No server-side processing limits
- CDN handles global traffic distribution
