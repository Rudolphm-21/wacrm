@AGENTS.md
## Easypanel
Project: `evapi` | Service: `wacrm`
### Deploy
- Source: GitHub `Rudolphm-21/wacrm`, branch `main`, built from `Dockerfile` (app listens on `PORT=3100`).
- `autoDeploy` is on, but pushes have NOT been updating the live app (live stayed on an old commit). After pushing, trigger a deploy manually in Easypanel (or via the Easypanel MCP `deploy_service`) and check build logs.
- `NEXT_PUBLIC_*` vars are inlined at build time: change them in the service env, then redeploy (a restart is not enough). Locale: `NEXT_PUBLIC_APP_LOCALE` (`en|es|pt|ko`).
- Supabase migrations (`supabase/migrations/*.sql`) are NOT applied by CI or by the deploy. Apply new ones manually, in filename order, in the Supabase SQL editor before deploying code that needs them.
