data "yandex_iam_service_account" "existing_sa" {
  service_account_id = "ajecikr0epkc7nnrh0cg"  # ID вашего существующего SA "andyan"
}

# Явное объявление output для проверки (опционально)
output "service_account_details" {
  value = {
    id   = data.yandex_iam_service_account.existing_sa.id
    name = data.yandex_iam_service_account.existing_sa.name
  }
  description = "Данные используемого сервисного аккаунта"
}