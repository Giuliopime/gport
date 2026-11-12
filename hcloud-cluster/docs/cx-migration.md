# cpx to cx migration

Hetzner raised CPX prices on 2026-06-15 (cpx52: €36.49 to €100.49). New servers get the new price, so every autoscaler replacement node costs €100.49. The `cx` line has the same RAM and is unaffected. Expected saving: ~€154/month (~€281 to ~€127). Full analysis: `bot-astro/astro` repo, `docs/infra-cost-migration.md`.

| Pool | Before | After |
|---|---|---|
| `control-plane` (3) | cpx22 (2c/4G) | cx23 (2c/4G) |
| `agent-sailboat` (1) | cpx32 (4c/8G) | cx33 (4c/8G) |
| `agent-as-cruiser` (3) | cpx52 (12c/24G) | cx53 (16c/32G) |

These are the target types. Stock on 2026-10-24: only cx23 was available (fsn1, nbg1); cx33 was sold out everywhere and cx53 was not available. Check the UI before each step and ask Hetzner support for capacity if it stays sold out. Fallbacks: cx43 (8c/16G, €15.99) for the agent, cax (ARM) types.

Workload is memory-bound (CPU 5-10%), so the slower cx CPUs don't matter. Keep 3 cx53: ~61 GiB used against 96 GiB.

## Rollout (one pool at a time, never apply everything at once)

1. **Autoscaler**: apply only this pool first. Existing nodes keep their type; cordon and drain one cpx52 node (`kubectl drain <node> --ignore-daemonsets --delete-emptydir-data`), let the autoscaler create a cx53 replacement, then watch shard latency and memory for a few days before replacing the others.
2. **agent-sailboat**: it holds the Longhorn volumes (Redis 30 GB, Prometheus 10 GB, single replica). Back up / snapshot them first, or raise the replica count, because replacing the node destroys local disk data.
3. **control-plane**: one node at a time, keeping etcd quorum (never more than 1 of 3 down). Drain and cordon before each removal.

## Checks
- cx53 disk is 320 GB (cpx52 had 480 GB): Longhorn usage must fit.
- Confirm cx capacity is available in nbg1 when the autoscaler scales up.
