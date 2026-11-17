# Terraform + Claude Code na Azure — szablon kursanta

Szablon do ćwiczeń z Terraforma na Azure z pomocą Claude Code. Każdy kursant pracuje
we własnej, już istniejącej grupie zasobów i ma uprawnienia Contributor tylko do niej.

**Zacznij od [INSTRUKCJE.md](INSTRUKCJE.md)** — setup krok po kroku, zasady demo i typowe błędy.

## Szybki start

```bash
source ~/.tf-training/studentNN.env   # w każdym nowym terminalu
./scripts/login.sh                    # opcjonalnie: az login (do `az resource list`)
terraform init
claude
```

## Struktura

| Plik | Zawartość |
|---|---|
| `providers.tf` | Provider `azurerm` (`resource_provider_registrations = "none"`) |
| `main.tf` | `data "azurerm_resource_group" "main"` + output |
| `variables.tf` | `resource_group_name`, `location` (z `TF_VAR_*`) |
| `network.tf` | Prywatna strefa DNS |
| `security.tf` | `random_string.suffix` do globalnie unikalnych nazw |
| `monitoring.tf` | Action group (`alert_email`); alert na usunięcie RG to zadanie |
| `outputs.tf` | Miejsce na outputy |
| `vm.tf.disabled` | Ćwiczenie: VM nginx `Standard_B1s` z własnym VNet/NSG |
| `storage.tf.disabled` | Ćwiczenie: storage account |
| `scripts/login.sh` | Logowanie `az` jako service principal kursanta |

Pliki `*.disabled` włączasz, usuwając rozszerzenie. Pamiętaj: **maksymalnie 1 VM naraz**.

## Praca z Claude Code

- `.claude/settings.json` — allowlista komend read-only; `apply`/`destroy` wymagają zgody.
- Hooki: `fmt` + `validate` po każdej edycji `.tf`; blokada `-auto-approve`.
- `/plan-review` — `terraform plan` + recenzja przez subagenta `tf-reviewer`.
- `CLAUDE.md` — zasady demo dla agenta.

## CI/CD

- `ci.yaml` — `fmt` + `validate` na PR i push do `main`.
- `cd.yaml` — uruchamiany ręcznie: plan, potem apply po zatwierdzeniu w środowisku `production`.
- `codex-review.yaml` — automatyczny przegląd PR.

## Weryfikacja

Testów nie ma. Sprawdzeniem jest:

```bash
terraform fmt -check -recursive -diff && terraform validate && terraform plan
```
