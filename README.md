# Terraform + Claude Code on Azure — student template

A template for Terraform exercises on Azure with the help of Claude Code. Each student works
in their own, already existing resource group and has Contributor permissions on it only.

**Start with [INSTRUKCJE.md](INSTRUKCJE.md)** (in Polish) — step-by-step setup, demo rules and common errors.

## Quick start

```bash
source ~/.tf-training/studentNN.env   # in every new terminal
./scripts/login.sh                    # optional: az login (for `az resource list`)
terraform init
claude
```

## Structure

| File | Contents |
|---|---|
| `providers.tf` | `azurerm` provider (`resource_provider_registrations = "none"`) |
| `main.tf` | `data "azurerm_resource_group" "main"` + output |
| `variables.tf` | `resource_group_name`, `location` (from `TF_VAR_*`) |
| `network.tf` | Private DNS zone |
| `security.tf` | `random_string.suffix` for globally unique names |
| `monitoring.tf` | Action group (`alert_email`); the RG deletion alert is an exercise |
| `outputs.tf` | Place for outputs |
| `vm.tf.disabled` | Exercise: nginx VM `Standard_B1s` with its own VNet/NSG |
| `storage.tf.disabled` | Exercise: storage account |
| `scripts/login.sh` | Logs `az` in as the student's service principal |

Enable the `*.disabled` files by removing the extension. Remember: **at most 1 VM at a time**.

## Working with Claude Code

- `.claude/settings.json` — allowlist of read-only commands; `apply`/`destroy` require approval.
- Hooks: `fmt` + `validate` after every `.tf` edit; `-auto-approve` is blocked.
- `/plan-review` — `terraform plan` + a review by the `tf-reviewer` subagent.
- `CLAUDE.md` — demo rules for the agent.

## CI/CD

- `ci.yaml` — `fmt` + `validate` on PRs and pushes to `main`.
- `cd.yaml` — triggered manually: plan, then apply after approval in the `production` environment.
- `codex-review.yaml` — automated PR review.

## Verification

There are no tests. The check is:

```bash
terraform fmt -check -recursive -diff && terraform validate && terraform plan
```
