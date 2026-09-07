# Metabase Upgrade Guide

Generic runbook for upgrading Metabase across Simple environments (all countries). Metabase is deployed via Argo CD using the Helm chart at `k8s/manifests/metabase`, with per-environment image tags in `k8s/environments/<env>/values/metabase.yaml`.

Upstream references:

- [Upgrading Metabase](https://www.metabase.com/docs/latest/installation-and-operation/upgrading-metabase)
- [Backing up Metabase application data](https://www.metabase.com/docs/latest/installation-and-operation/backing-up-metabase-application-data)
- [Docker Hub tags](https://hub.docker.com/r/metabase/metabase/tags)

---

## How Metabase is deployed in this repo

| Item | Detail |
| --- | --- |
| Chart | `k8s/manifests/metabase` (wrapper around Metabase Helm chart) |
| Argo CD app | `metabase` in each env’s `argocd-apps/apps.yaml` |
| Image tag override | `k8s/environments/<env>/values/metabase.yaml` → `metabase.image.tag` |
| Application DB | PostgreSQL database named `metabase` in the PGO cluster (`simple`) |
| DB credentials | Secret `simple-pguser-metabase` (JDBC URI via Helm `secrets.existingSecret`) |
| Namespace | Usually `simple-v1` |

Default chart tag (if an env does not override): see `k8s/manifests/metabase/values.yaml`.

---

## Environment inventory (image tags)

Confirm live tags before upgrading (`git grep` or open each values file):

| Environment | Values file | Notes |
| --- | --- | --- |
| sandbox | `k8s/environments/sandbox/values/metabase.yaml` | Prefer upgrade first |
| qa | `k8s/environments/qa/values/metabase.yaml` | |
| bangladesh-staging / bangladesh-demo | `.../bangladesh-*/values/metabase.yaml` | |
| bangladesh-production | `.../bangladesh-production/values/metabase.yaml` | |
| sri-lanka-staging | `.../sri-lanka-staging/values/metabase.yaml` | |
| sri-lanka-production | `.../sri-lanka-production/values/metabase.yaml` | |
| india-production | `.../india-production/values/metabase.yaml` | |
| test / local | `.../test` / `.../local` | May inherit chart default if tag unset |

Upgrade order: **sandbox → staging/demo → production**. Never jump production ahead of a lower env on the same release train.

---

## Before you start

1. **Pick a target version**  
   Use an official Open Source tag, e.g. `v0.62.3` (image `metabase/metabase:v0.62.3`). Prefer the latest **patch** of the chosen major (e.g. `v0.62.x`).

2. **Read release notes** for every major between current and target  
   Large jumps (e.g. `0.47` → `0.62`) still work as a single deploy in practice (Metabase runs migrations on startup), but review breaking changes and known issues.

3. **Confirm current version** in the target env  
   ```bash
   kubectl -n simple-v1 get deploy,sts,pods -l app.kubernetes.io/name=metabase -o wide
   kubectl -n simple-v1 get pod -l app.kubernetes.io/name=metabase -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'
   ```
   Or open Metabase → **Settings → About**.

4. **Schedule a maintenance window** for production  
   Metabase will restart and run application-DB migrations. Expect several minutes of downtime (longer on large majors). Dashboards/questions are unavailable during the rollout; Simple API/mobile sync is **not** affected.

5. **Air-gapped / Harbor envs (e.g. MIS)**  
   Mirror `metabase/metabase:<tag>` into the internal registry **before** changing Git values, and ensure the env’s image repository override (if any) points at Harbor.

---

## Step 1 — Back up the Metabase application database

**Required before every upgrade.** Downgrades after a major upgrade generally need a restore from this backup.

Metabase application data lives in Postgres DB `metabase` (not the Simple clinical DB).

### Identify the Postgres primary pod

```bash
kubectl -n simple-v1 get pods -l postgres-operator.crunchydata.com/role=master
# or
kubectl -n simple-v1 get pods | grep simple-instance
```

### Dump (example)

Run from a Postgres pod (use local socket / `127.0.0.1` as used in that cluster):

```bash
# Replace <pg-pod> with the primary pod name
kubectl -n simple-v1 exec -it <pg-pod> -c database -- \
  bash -lc 'pg_dump -h 127.0.0.1 -U postgres -Fc -d metabase' > metabase-<env>-$(date +%Y%m%d).dump
```

If role/password differs, use the `metabase` / `admin` credentials from the PGO-generated secrets (`simple-pguser-metabase`, etc.).

### Verify the dump

```bash
ls -lh metabase-<env>-*.dump
# optional: pg_restore -l metabase-<env>-YYYYMMDD.dump | head
```

Store the dump somewhere durable (secure share / backup bucket) for the duration of the upgrade and soak period.

---

## Step 2 — Change the image tag in Git

Edit only the target environment file:

```yaml
# k8s/environments/<env>/values/metabase.yaml
metabase:
  image:
    tag: v0.62.3   # <-- new version
```

Open a PR. Suggested commit/PR title: `Upgrade Metabase to vX.Y.Z in <env>`.

Do **not** change unrelated ingress/host settings in the same PR unless required for the upgrade.

---

## Step 3 — Merge and sync

1. Merge to the branch the env’s Argo CD Application tracks (usually `master`).
2. Wait for Argo CD `metabase` app to sync (automated sync is enabled in most envs), or sync manually:
   ```bash
   # via Argo CD UI, or:
   argocd app sync metabase
   # or kubectl patch Application if that is your ops pattern
   ```
3. Watch the rollout:
   ```bash
   kubectl -n simple-v1 get pods -l app.kubernetes.io/name=metabase -w
   kubectl -n simple-v1 logs -l app.kubernetes.io/name=metabase --tail=100 -f
   ```

On startup Metabase applies application-DB migrations automatically. First boot after a large major can take several minutes — do not kill the pod mid-migration.

---

## Step 4 — Verify

- [ ] Pod is `Running` / `Ready`
- [ ] Argo CD `metabase` is **Synced** and **Healthy**
- [ ] UI loads at the env hostname (see ingress hosts in that env’s `metabase.yaml`)
- [ ] Login works
- [ ] Spot-check: home, a known dashboard, a known question, Admin → Databases
- [ ] **Settings → About** shows the new version
- [ ] No repeated migration / JDBC errors in logs

Keep the DB dump until the env has been stable for an agreed soak (e.g. a few days on staging, at least one business day on production).

---

## Rollback

Metabase does **not** support casually downgrading a major after migrations. Preferred rollback:

1. Scale/stop Metabase (or leave the failing pod).
2. Restore the `metabase` database from the pre-upgrade dump (`pg_restore` into a clean/restored DB — coordinate carefully with PGO).
3. Set `metabase.image.tag` back to the previous version in Git and sync.

Only consider Metabase’s `migrate down` if you must keep post-upgrade UI changes **and** you understand the risk; **restore-from-backup is the default**.

---

## Recommended rollout sequence (all countries)

| Order | Environment type | Rationale |
| --- | --- | --- |
| 1 | sandbox (or qa) | Catch image pull / migration issues |
| 2 | Country staging / demo | Validate dashboards with near-prod data |
| 3 | Country production | One country at a time |
| 4 | Next country… | Repeat backup → tag → sync → verify |

Same target version across the fleet once proven. Avoid leaving countries many majors apart longer than necessary.

---

## Production checklist (copy into the change ticket)

- [ ] Target version chosen and release notes reviewed  
- [ ] Lower env already running the same (or newer) version successfully  
- [ ] Stakeholders notified (analytics users)  
- [ ] `pg_dump` of DB `metabase` taken and verified  
- [ ] PR merged with new `metabase.image.tag`  
- [ ] Argo sync + pod Ready  
- [ ] UI / login / sample dashboards OK  
- [ ] Version confirmed in **About**  
- [ ] Dump retained for soak period  

---

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| `ImagePullBackOff` | Tag exists on Docker Hub; Harbor mirror for air-gapped clusters; `imagePullSecrets` |
| Pod crash loop / migration error | Logs; restore backup; open Metabase Discourse/GitHub for that version |
| UI up but old version | Wrong values file / Argo not synced / wrong cluster context |
| Slow first start | Normal during major migrations — wait; watch logs for `Migration` / Liquibase |
| Ingress timeout on heavy dashboards | Env may already set nginx proxy timeouts (e.g. India/BD prod); unrelated to tag bump |

---

## What this upgrade does *not* cover

- Upgrading the **Simple** application or clinical Postgres DB  
- Changing Metabase **ingress hostnames** or TLS  
- Rotating DB passwords / sealed secrets (see `doc/SecretManagement.md`)  
- Embedding / SSO (community Metabase SSO limitations — see `doc/SSO.md`)

---

## Quick command cheat sheet

```bash
# Current image
kubectl -n simple-v1 get pods -l app.kubernetes.io/name=metabase \
  -o jsonpath='{.items[0].spec.containers[0].image}{"\n"}'

# Backup
kubectl -n simple-v1 exec -it <pg-primary> -c database -- \
  bash -lc 'pg_dump -h 127.0.0.1 -U postgres -Fc -d metabase' > metabase-$(date +%Y%m%d).dump

# After merge — watch
kubectl -n simple-v1 get pods -l app.kubernetes.io/name=metabase -w
kubectl -n simple-v1 logs -l app.kubernetes.io/name=metabase --tail=200 -f
```
