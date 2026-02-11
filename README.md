# cadenroberts.github.io

Personal resume hosting via GitHub Pages.

## What It Does

- Serves a static HTML page at https://cadenroberts.github.io
- Displays resume.pdf in an embedded viewer
- Provides a download link for the resume PDF
- Automatically deploys on push to main branch via GitHub Pages

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                   GitHub Pages CDN                   │
│            https://cadenroberts.github.io            │
└──────────────────────────────┬───────────────────────┘
                               │
                               ▼
                    ┌───────────────────┐
                    │   index.html      │
                    │                   │
                    │  ┌─────────────┐  │
                    │  │   <iframe>  │  │
                    │  │             │  │
                    │  │ resume.pdf  │  │
                    │  │             │  │
                    │  └─────────────┘  │
                    │                   │
                    │  [Download]       │
                    └───────────────────┘
```

**Flow:**
1. User navigates to cadenroberts.github.io
2. GitHub Pages serves index.html
3. Browser loads and renders HTML/CSS
4. iframe embeds resume.pdf with native browser PDF viewer

**Components:**
- **index.html**: Landing page with resume viewer
- **resume.pdf**: Resume document
- **sync.sh**: Git commit/push automation script

**Technology:**
- Pure HTML5 + CSS3
- No JavaScript
- No build process
- No external dependencies

## Design Tradeoffs

**Static HTML vs Framework:**
- **Chosen:** Static HTML
- **Rationale:** Zero dependencies, instant load time, no build step, trivial deployment
- **Tradeoff:** No dynamic content or interactivity, but none required for this use case

**GitHub Pages vs Custom Hosting:**
- **Chosen:** GitHub Pages
- **Rationale:** Free, HTTPS by default, automatic deployment, high availability
- **Tradeoff:** Limited to static content, no server-side logic, but sufficient for document hosting

**No Build Tooling:**
- **Chosen:** Direct HTML editing
- **Rationale:** Simplicity, no toolchain maintenance, no build failures
- **Tradeoff:** No CSS preprocessing, no minification, but file sizes negligible

## Evaluation

**Correctness Criteria:**
1. HTML validates against W3C standards
2. resume.pdf is present and accessible
3. All navigation links resolve correctly
4. Page loads successfully over HTTPS
5. PDF iframe renders in modern browsers

**Performance Expectations:**
- index.html: < 2 KB, < 100ms load time
- resume.pdf: 152 KB, < 500ms load time

**Commands:**
```bash
# Validate HTML
npx html-validate index.html

# Check file presence
test -f resume.pdf && echo "PASS" || echo "FAIL"

# Test local serving
python3 -m http.server 8000
# Visit http://localhost:8000
```

## Demo

See DEMO.md for complete demonstration instructions.

**Quick Verification:**
```bash
./scripts/demo.sh
```

Expected final output: `SMOKE_OK`

## Repository Layout

```
cadenroberts.github.io/
├── .git/                    # Git repository metadata
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI workflow
├── scripts/
│   └── demo.sh             # Reproducible demo/test script
├── index.html               # Main landing page (1.7 KB)
├── resume.pdf               # Resume document
├── sync.sh                  # Git automation script
├── .gitignore              # Git ignore patterns
├── README.md               # This file
├── ARCHITECTURE.md         # Detailed architecture documentation
├── DESIGN_DECISIONS.md     # ADR-style design decisions
├── DEMO.md                 # Demonstration instructions
├── EVAL.md                 # Evaluation criteria and commands
├── REPO_AUDIT.md           # Technical audit report
└── PATCHSET_SUMMARY.md     # Change summary
```

## Limitations / Scope

**Browser Compatibility:**
- Requires modern browser with native PDF rendering support
- No fallback for browsers without PDF support (IE11, very old mobile browsers)

**Accessibility:**
- PDF content accessibility depends on source PDF structure
- No screen reader optimization beyond semantic HTML structure

**Mobile Experience:**
- PDF viewing on small screens is suboptimal
- No responsive PDF alternatives provided

**Content Management:**
- PDFs must be manually updated in repository
- No CMS or automated content pipeline

**Analytics:**
- No custom analytics beyond GitHub repository insights
- No tracking of PDF downloads or view durations

**Internationalization:**
- English only
- No multi-language support
