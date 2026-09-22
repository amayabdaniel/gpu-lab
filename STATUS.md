# STATUS

**Last updated:** 2026-09-22
**Recommendation:** Maintain with fixes; no new components unless one of the trigger conditions below fires.

## What this repo is today

- Terragrunt-orchestrated Terraform for one-shot GCP GPU workloads
  under `live/gcp-lab/{model-bench, personaplex, aerial-lab}`, backed
  by two real modules and one templates directory:
  - `modules/firewall` — required-input CIDRs (`allowed_ssh_cidrs`,
    `allowed_app_cidrs`) with `validation` blocks that reject
    `0.0.0.0/0`. Consumed by every component via root.hcl inputs so
    inheritance doesn't rely on component-level plumbing.
  - `modules/gpu-instance` — five no-default variables (name, zone,
    machine_type, ssh_user, ssh_pub_key), all wired through the
    components' `main.tf`.
  - `modules/startup` — shell templates, not a real Terraform module.
- Root `env.hcl` reads `GPU_LAB_ALLOWED_SSH_CIDRS` /
  `GPU_LAB_ALLOWED_APP_CIDRS` at plan time so an operator running
  without those envs gets a loud fail, not a silent open.
- `live/_components/model-bench/startup.sh` pins
  `OLLAMA_VERSION="v0.5.4"` (rationale in the comment; treats the
  `install.sh | sh` line the same way we treat `:latest` image tags —
  no floating fetches on a runtime that gets frequent updates).
- vLLM container pinned to `vllm/vllm-openai:v0.6.4.post1` in the same
  startup script.
- `SECURITY.md` at the repo root documents the CIDR discipline, the
  runtime pins, and the "no `0.0.0.0/0` firewall rules" invariant.

## Hygiene state (as of 2026-09-22)

- `terraform fmt -recursive -check` — clean.
- `terragrunt hcl format --check` — clean.
- `terraform validate` on `modules/firewall` and `modules/gpu-instance`
  — both `Success! The configuration is valid.`
- `tflint` — clean on both real modules.
- Wiring audit (2026-09-21): no `modules/gpu-instance` no-default
  variable is missing from any component; no other module has the
  fixed-but-not-wired shape that the CIDR chain had before
  2026-09-19.

## What this repo is NOT

- **Not applied by anyone but Daniel.** The rule is: `terraform plan`,
  `validate`, `fmt`, `init -backend=false` — no `apply`. State lives
  in a GCS bucket named after the project.
- **Not multi-region.** Everything targets one GCP project, one region,
  one zone, per `live/gcp-lab/env.hcl`. Adding another region means
  another `live/<region>/env.hcl` and a re-run of the wiring audit.
- **Not a general-purpose GPU platform.** The components are each
  single-purpose (a model-bench VM, a personaplex VM, an aerial-lab
  VM); a new use case should get a new component under
  `live/gcp-lab/`, not a mode toggle on an existing one.

## When to touch this repo

Do work here only when at least one of these fires:

1. **Runtime version bump.** `OLLAMA_VERSION` in
   `live/_components/model-bench/startup.sh`, or the vLLM tag in the
   same file. Verify the new version against a real GPU boot before
   pushing, and update `SECURITY.md`'s Network Security section.
2. **A new component.** Copy an existing `live/_components/<name>/`,
   audit which no-default variables need root-level plumbing, run the
   wiring audit before shipping.
3. **A security finding.** Rebuild the STRIDE + FMEA argument in
   `SECURITY.md`, treat any 0.0.0.0/0 or unpinned-runtime bug as a P0.
4. **Terragrunt / provider bump.** Rerun `fmt -recursive -check`,
   `validate` on both modules, and `tflint`; a version bump that quietly
   requires new variables would surface here.
5. **A cost anomaly on the GCP bill.** The `model-bench` component is
   the biggest single-invoice line here; before iterating on cost,
   check whether an instance is stuck up (the components are one-shot,
   so an up-instance older than the last plan is a bug).

If none of the above fires, this repo is idle by design.

## Related repos

- `ai-inference-benchmark` — the script that runs on the
  `model-bench` component's GPU.
- `inferctl` — its `simulate` command's heuristics are what
  `ai-inference-benchmark` validates against real hardware here.
