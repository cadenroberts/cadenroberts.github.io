# DESIGN DECISIONS

Architecture Decision Records (ADR) documenting key design choices.

---

## ADR-001: Use Static HTML Instead of React/Vue Framework

**Context:**
Need to build a simple personal website to host resume and transcript PDFs with minimal maintenance overhead and maximum reliability.

**Decision:**
Use pure static HTML + CSS with no JavaScript framework.

**Rationale:**
- Site has zero dynamic functionality requirements
- No state management needed
- No client-side routing needed
- No API calls or data fetching
- Smaller payload: 3.4 KB HTML vs 200+ KB for framework + dependencies
- Instant page loads: no JavaScript parsing/execution overhead
- Zero build step: edit HTML and push
- Zero framework upgrade maintenance burden
- Works without JavaScript enabled in browser

**Consequences:**
- **Positive:** Ultra-fast load times, zero dependencies, trivial deployment
- **Positive:** No build tooling to maintain or debug
- **Positive:** No npm vulnerabilities or framework CVEs to patch
- **Positive:** Works on ancient browsers
- **Negative:** Adding interactivity later requires refactoring
- **Negative:** No component reusability (CSS duplicated between pages)
- **Mitigation:** For this use case, no interactivity planned; CSS duplication acceptable for 2 pages

**Status:** Accepted

---

## ADR-002: Host on GitHub Pages Instead of Vercel/Netlify/AWS

**Context:**
Need reliable, low-cost hosting for static site with HTTPS and custom domain support.

**Decision:**
Use GitHub Pages with cadenroberts.github.io domain.

**Rationale:**
- Free for public repositories
- Automatic HTTPS via Let's Encrypt
- Automatic deployment on git push (no CI configuration required)
- 99.9%+ uptime backed by GitHub infrastructure
- Global CDN distribution
- No credit card required
- No vendor lock-in (static files easily portable)
- Repository already exists for version control

**Alternatives Considered:**
- **Vercel:** Overkill for static HTML; designed for Next.js/React apps
- **Netlify:** Similar to GitHub Pages but adds unnecessary abstraction layer
- **AWS S3 + CloudFront:** Requires manual setup, billing, more operational overhead
- **Custom VPS:** Highest operational burden, requires security updates

**Consequences:**
- **Positive:** Zero cost, automatic deployment, high reliability
- **Positive:** Repository doubles as version control and hosting
- **Negative:** Limited to static content (no serverless functions)
- **Negative:** github.io domain instead of custom domain (acceptable)
- **Negative:** No build step support (not needed for this use case)

**Status:** Accepted

---

## ADR-003: Embed PDFs via iframe Instead of PDF.js Library

**Context:**
Need to display PDF documents inline on web pages.

**Decision:**
Use browser-native `<iframe>` embedding with PDF URL as src.

**Rationale:**
- Zero JavaScript required
- No external library dependencies
- Works in all modern browsers with native PDF support
- Smaller page size: no 500+ KB PDF.js library
- Browser's native PDF viewer provides zoom, search, print controls
- No custom UI to build or maintain
- PDF loading offloaded to browser's optimized rendering engine

**Alternatives Considered:**
- **PDF.js:** 500 KB library, requires build step, custom UI needed
- **Embed tag:** Less consistent cross-browser support than iframe
- **Canvas rendering:** Requires significant JavaScript, poor performance on large PDFs
- **Link to PDF only:** No inline preview, poor UX

**Consequences:**
- **Positive:** Minimal code, fast loading, no dependencies
- **Positive:** Browser handles zoom, navigation, text selection
- **Negative:** Inconsistent rendering across browsers (Chrome vs Firefox vs Safari)
- **Negative:** No fallback for browsers without PDF support (IE11, very old mobile)
- **Negative:** No control over PDF viewer UI (toolbar, navigation)
- **Mitigation:** Provide download links for users with unsupported browsers

**Status:** Accepted

---

## ADR-004: No Build Process or CSS Preprocessing

**Context:**
CSS is duplicated across two HTML files. Could use Sass, PostCSS, or build tools to reduce duplication.

**Decision:**
Inline CSS directly in `<style>` tags with duplication across pages.

**Rationale:**
- Only two pages with nearly identical styles (~60 lines CSS each)
- Adding build tooling introduces dependencies: Node.js, npm, build scripts, CI integration
- Build failures become potential deployment blockers
- CSS payload is negligible: 1.7 KB per page
- Maintenance burden of duplicated CSS is minimal for 2-page site
- No CSS minification needed at this scale

**Alternatives Considered:**
- **Sass/SCSS:** Requires Node.js, build step, file watching during development
- **PostCSS:** Same overhead as Sass for minimal benefit
- **External stylesheet:** One HTTP request saved, but cache benefit negligible for tiny CSS
- **Tailwind CSS:** 3 MB framework for 60 lines of custom CSS is absurd

**Consequences:**
- **Positive:** Zero build complexity, edit HTML and push
- **Positive:** No Node.js or npm required
- **Positive:** No build failures or toolchain maintenance
- **Negative:** CSS duplicated across files (120 lines total vs 60 shared)
- **Negative:** CSS changes require updating both files
- **Mitigation:** For 2-page site, duplication is acceptable maintenance burden

**Status:** Accepted

---

## ADR-005: Inline CSS Instead of External Stylesheet

**Context:**
CSS could be moved to external `style.css` file and linked via `<link>` tag.

**Decision:**
Keep CSS inline in `<style>` tags within each HTML file.

**Rationale:**
- Eliminates one HTTP request (CSS loaded with HTML in single roundtrip)
- No caching complexity for first-time visitors
- Simpler mental model: all page code in one file
- CSS is small (60 lines): inline size cost is negligible
- No FOUC (Flash of Unstyled Content) risk
- Easier to audit: view-source shows complete page

**Alternatives Considered:**
- **External stylesheet:** Requires additional HTTP request on first load
- **Shared stylesheet:** Benefit only realized on second page visit; requires cache management

**Consequences:**
- **Positive:** Faster first load (one fewer HTTP request)
- **Positive:** No FOUC issues
- **Positive:** Self-contained HTML files
- **Negative:** CSS duplicated (already accepted in ADR-004)
- **Negative:** No cross-page cache benefit
- **Trade-off:** First load optimization prioritized over repeat visit optimization

**Status:** Accepted

---

## ADR-006: Use sync.sh Script Instead of Direct Git Commands

**Context:**
Need to commit and push changes to repository. Could use raw `git add`, `git commit`, `git push` commands.

**Decision:**
Provide `sync.sh` wrapper script that handles full git workflow with single command.

**Rationale:**
- Reduces deployment errors: script enforces consistent workflow
- Prevents common mistakes: forgetting to push, incorrect branch
- Provides better UX: single command with descriptive message
- Handles edge cases: first push to new branch with `-u` flag
- Validation: checks if there are changes before committing
- Default message includes timestamp if none provided

**Script Behavior:**
1. Stage all changes (`git add -A`)
2. Check if anything staged (exit early if nothing to commit)
3. Commit with provided message or timestamped default
4. Detect if branch has remote tracking
5. Push with `-u` flag if needed, standard push otherwise
6. Confirm push success

**Consequences:**
- **Positive:** Simpler deployment workflow for content updates
- **Positive:** Less error-prone than manual git commands
- **Positive:** Consistent commit/push pattern
- **Negative:** Abstracts git operations (less educational)
- **Negative:** Auto-staging all changes might include unintended files
- **Mitigation:** .gitignore prevents accidental commits of unwanted files

**Status:** Accepted

---

## ADR-007: No Analytics or Tracking Beyond GitHub Insights

**Context:**
Could add Google Analytics, Plausible, or other analytics to track visitors, page views, behavior.

**Decision:**
No custom analytics. Rely solely on GitHub repository traffic insights.

**Rationale:**
- Site is personal resume host, not business application
- No A/B testing or conversion optimization needed
- No user behavior analysis required
- Privacy-first: no third-party tracking scripts
- Faster page loads: no analytics JavaScript overhead
- GitHub Insights provides sufficient data: unique visitors, page views, referrers (14-day window)
- GDPR/privacy compliance: no cookies, no tracking, no consent banner needed

**Alternatives Considered:**
- **Google Analytics:** Most comprehensive but requires cookie consent, adds ~50 KB JS
- **Plausible:** Privacy-friendly but costs $9/month for personal site
- **Simple Analytics:** Similar to Plausible, still costs money
- **Self-hosted Matomo:** Requires server infrastructure, operational overhead

**Consequences:**
- **Positive:** Zero tracking overhead, fastest possible page loads
- **Positive:** No privacy concerns, no GDPR compliance burden
- **Positive:** No third-party dependencies
- **Negative:** Limited analytics data (14-day window, no detailed behavior)
- **Negative:** No visibility into PDF downloads, time on page, scroll depth
- **Trade-off:** Privacy and performance prioritized over detailed analytics

**Status:** Accepted

---

## ADR-008: No Automated Testing or CI Validation Initially

**Context:**
Could add HTML validation, link checking, PDF integrity tests via GitHub Actions.

**Decision:**
Add minimal CI validation as part of repository overhaul (PHASE 5), but keep scope limited.

**Rationale:**
- Site is extremely simple: 2 HTML pages, 2 PDF files
- Manual testing takes < 30 seconds
- Breaking changes are immediately visible (site broken is obvious)
- Over-engineering CI for 2-file site adds more complexity than value
- However, CI provides automated smoke test and demonstrates good practice

**CI Scope (Minimal):**
- Validate HTML files exist
- Validate PDF files exist
- Optionally validate HTML syntax
- Run `scripts/demo.sh` smoke test

**Not Included:**
- Visual regression testing (overkill)
- Performance testing (unnecessary for static site)
- Security scanning (no dependencies, no attack surface)
- Link checking (only 4 internal links, manually verifiable)

**Consequences:**
- **Positive:** Simple CI provides safety net without complexity
- **Positive:** Demonstrates good engineering practice
- **Negative:** CI doesn't catch visual regressions or cross-browser issues
- **Negative:** CI overhead (1-2 min per push) for negligible benefit
- **Mitigation:** Manual testing remains primary validation method

**Status:** Accepted (implemented in PHASE 5)
