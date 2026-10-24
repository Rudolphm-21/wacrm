@AGENTS.md
## Easypanel
Project: `evapi` | Service: `wacrm`
### Deploy
- Source: GitHub `Rudolphm-21/wacrm`, branch `main`, built from `Dockerfile` (app listens on `PORT=3100`).
- `autoDeploy` is on: a push to `main` triggers a full Docker build + deploy (~4 min). Check build logs in Easypanel.
- A manual "Deploy" of an already-built commit does NOT rebuild (it reuses the image in ~1s).
- `NEXT_PUBLIC_*` vars are inlined at build time (Easypanel passes env as build args). After changing one, push a new commit (e.g. `git commit --allow-empty`) so the image is rebuilt; redeploy/restart alone won't apply it. Locale: `NEXT_PUBLIC_APP_LOCALE` (`en|es|pt|ko`).
- Supabase migrations (`supabase/migrations/*.sql`) are NOT applied by CI or by the deploy. Apply new ones manually, in filename order, in the Supabase SQL editor before deploying code that needs them.
