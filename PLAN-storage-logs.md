# Plan: storage account na logi

## Kontekst
Użytkownik chce storage account na logi. W stanie są tylko `data.azurerm_resource_group.main` i `random_string.suffix`.
Gotowy przykład `storage.tf.disabled` bierze sufiks z `md5`, a CLAUDE.md każe użyć `random_string`, więc piszę nowy plik i nie włączam tamtego.

## Pliki
- **nowy `my_logs.tf`**: storage account, kontener, polityka retencji
- **`variables.tf`**: `log_retention_days` (number, domyślnie 30)
- **`outputs.tf`** (teraz pusty): `logs_storage_account_name`, `logs_container_name`
- `storage.tf.disabled` zostaje bez zmian. Gdyby ktoś go później włączył, powstanie drugi, niezależny account (inne nazwy zasobów, więc nie ma konfliktu).

## Zasoby (3 do utworzenia)
1. `azure_storage_account.logs`
   - `name = "stlogs${random_string.suffix.result}"` (12 znaków, małe litery i cyfry)
   - RG i `location` z `data.azurerm_resource_group.main` / `var.location`, `tags` z RG
   - `Standard` / `LRS` (najtańsze), `account_kind = "StorageV2"`, `min_tls_version = "TLS1_2"`
   - `https_traffic_only_enabled = true`, `allow_nested_items_to_be_public = false`
2. `azurerm_storage_container.logs`: `name = "logs"`, `container_access_type = "private"`
3. `azurerm_storage_management_policy.logs`: usuwa bloby z prefiksem `logs/` starsze niż `var.log_retention_days`

`random_string.suffix` już jest w stanie, więc się nie zmieni.

## Co może odrzucić polityka Azure / uprawnienia
- Storage account **nie jest** na liście zakazanych, więc powinien przejść.
- Region inny niż `var.location` → `RequestDisallowedByPolicy`. Biorę go ze zmiennej, więc tu ryzyka nie ma.
- Brak tagów z RG może zostać odrzucony przez politykę tagowania. Biorę je z RG.
- Polityki, których nie widać w repo (np. wymóg `public_network_access_enabled = false` albo `shared_access_key_enabled = false`), wyjdą dopiero przy `apply`, bo `plan` ich nie sprawdza. Wtedy wyłączam publiczny dostęp, a kontener zakładam przez `azurerm_storage_container` z `storage_account_id` (ARM, nie data plane).
- Nazwa zajęta globalnie (`StorageAccountAlreadyTaken`) jest mało prawdopodobna przy losowym sufiksie.
- GRS/ZRS nie są potrzebne. Zostaję przy LRS, bo droższą replikację mogłaby blokować polityka kosztowa.
- `resource_provider_registrations = "none"` zostaje. `Microsoft.Storage` musi być zarejestrowany przez prowadzącego. Jeśli nie jest, zobaczymy `MissingSubscriptionRegistration` i to jest blokada demo.

## Weryfikacja
1. Hook robi `fmt` + `validate` po edycji. Potem `terraform plan` (albo `/plan-review`): oczekiwane `3 to add, 0 to change, 0 to destroy`.
2. Krótkie podsumowanie planu i prośba o zgodę, potem `terraform apply` bez `-auto-approve`.
3. `terraform output` oraz `az resource list -g $TF_VAR_resource_group_name -o table`.
