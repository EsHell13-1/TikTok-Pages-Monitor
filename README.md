# TikTok Public Monitor — Cloudflare Pages + D1

## Архитектура
- UI: Cloudflare Pages static assets (`public/`)
- API: Cloudflare Pages Functions (`functions/api/[[path]].js`)
- Storage: Cloudflare D1 (`migrations/0001_init.sql`)
- Scheduler: GitHub Actions scheduled workflow every 5 minutes, which calls the Pages API. Thus no separate scheduled Worker is required. GitHub may delay scheduled workflows; the cadence is best-effort, not hard real-time.
- Collector: best-effort parser of public TikTok profile HTML in `src/worker.js`.

## Important limitations
This collector is experimental and not an official TikTok API. TikTok may serve CAPTCHA, block requests, change HTML, or omit metrics. It cannot guarantee all historical videos, 5-minute refreshes, favorites, or stable collection of third-party public profiles. Do not attempt to bypass authentication, CAPTCHA, or access controls. Test with one profile before scaling to ten.

## Deploy
1. Create a GitHub repository and upload these files.
2. In Cloudflare Dashboard, create a Pages project connected to this repository. Framework preset: None; build command empty; output directory `public`. The `functions/` folder must be at the repository root.
3. Create D1 database:
   `npx wrangler d1 create tiktok-monitor`
4. Replace `REPLACE_WITH_DATABASE_ID` in `wrangler.toml` with the returned ID.
5. Apply schema:
   `npx wrangler d1 migrations apply tiktok-monitor --remote`
6. In Pages project Settings → Variables and Secrets, add secret `APP_TOKEN` with a long random value. In Settings → Functions → D1 database bindings, bind `DB` to `tiktok-monitor` (binding name exactly `DB`). If using Wrangler configuration as the source of truth, redeploy after updating `wrangler.toml`.
7. Deploy/redeploy Pages. Open the `*.pages.dev` URL and use “Установить API-токен” with the same `APP_TOKEN`.
8. In GitHub repository → Settings → Secrets and variables → Actions, add repository secrets:
   - `PAGES_URL`: full URL, e.g. `https://your-project.pages.dev` (no trailing slash)
   - `APP_TOKEN`: same value as Cloudflare Pages secret
9. Run Actions → TikTok collection → Run workflow once. Then check the workflow runs. Scheduled execution may be delayed by GitHub and is not guaranteed exactly every five minutes.
10. Add one public username in the UI and click “Собрать сейчас”. Verify the channel error/status and whether videos are found.

## Why not Google Sheets as primary database?
D1 is easier to query for time-series charts, avoids Google OAuth/service-account setup, and is directly bindable to Pages Functions. Google Sheets can be added later for export. Google Apps Script has per-execution and daily trigger-runtime quotas, so frequent collection and long history may be less predictable.

## API
All `/api/*` routes require `Authorization: Bearer <APP_TOKEN>`.
- `GET /api/channels`
- `POST /api/channels` JSON `{ "username": "example" }`
- `DELETE /api/channels/:id`
- `POST /api/collect`
- `GET /api/videos`
- `GET /api/videos?channel_id=1`
- `GET /api/videos/:id/history`
- `GET /api/channels/history?id=1`

## Free-tier considerations
Pages static asset requests are free/unlimited. Pages Functions invocations count against the Workers Free request quota. D1 free limits currently include 5 million rows read/day, 100,000 rows written/day, 5 GB total storage per account, and 500 MB maximum per database; confirm current values in Cloudflare's official pricing/limits docs before launch. GitHub Actions scheduled workflows are best-effort and can be delayed.
