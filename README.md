# Этап 1: Создание инфраструктуры (Terraform)

## 🛠️ Что создается
- **VPC сеть** `k8s-network` с подсетью `192.168.10.0/24` (зона `ru-central1-d`)
- **3 виртуальные машины**:
  - `k8s-master` (2 vCPU, 2GB RAM) - мастер-нода Kubernetes
  - `k8s-app` (2 vCPU, 2GB RAM) - воркер-нода
  - `srv` (2 vCPU, 2GB RAM) - сервер для CI/CD (единственный с публичным IP)

## ⚙️ Характеристики ВМ
| Параметр         | Значение                     |
|------------------|------------------------------|
| Образ ОС         | Ubuntu 22.04 LTS             |
| Тип ВМ           | Прерываемые (`preemptible`)  |
| Гарантия vCPU    | 50% (master), 20% (worker)   |
| Диск             | 20GB HDD                     |
| Доступ           | SSH по ключу (`ubuntu` user) |

## 🔄 Команды развертывания
```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

## 🏗️ Структура проекта

```bash
.
├── authorized_key.json      # Ключ сервисного аккаунта Yandex.Cloud
├── provider.tf              # Конфигурация провайдера Terraform
├── network.tf               # Настройки сети (VPC, подсети, публичный IP)
├── instances.tf             # Описание ВМ: k8s-master, k8s-app, srv
├── service-account.tf       # Использование существующего сервисного аккаунта
├── outputs.tf               # Вывод IP-адресов и служебной информации
├── variables.tf             # Переменные (cloud_id, folder_id, zone_id)
└── README.md               # Документация (этот файл)