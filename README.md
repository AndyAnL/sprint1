# Этап 1: Создание инфраструктуры (Terraform)

## 🛠️ Что создается

- **VPC сеть** `k8s-network` с подсетью `192.168.10.0/24` (зона `ru-central1-d`)
- **3 виртуальные машины**:
  - `k8s-master` (2 vCPU, 4GB RAM) - мастер-нода Kubernetes
  - `k8s-app` (2 vCPU, 2GB RAM) - воркер-нода
  - `srv` (2 vCPU, 4GB RAM) - сервер для CI/CD (единственный с публичным IP)

## ⚙️ Характеристики ВМ

| Параметр         | Значение                     |
|------------------|------------------------------|
| Образ ОС         | Ubuntu 22.04 LTS             |
| Тип ВМ           | Прерываемые (`preemptible`)  |
| Гарантия vCPU    | 50% (master), 20% (worker)   |
| Диск             | 20GB HDD                     |
| Доступ           | SSH по ключу (`ubuntu` user) |

## 🔧 Предварительные требования

1. **Аккаунт в Yandex Cloud** с доступом к сервису Compute Cloud
2. **Сервисный аккаунт** в Yandex Cloud с ролью `editor` и созданный файл `authorized_key.json`
3. **SSH ключ** загружен в облако (добавлен в метаданные проекта)
4. **Аккаунт на GitLab.com**
5. **Registration Token** для GitLab Runner, полученный в настройках проекта или группы в GitLab
6. **Локально установленные инструменты:**
    - Terraform (>= 1.0)
    - Ansible (>= 2.9)

## 🏗️ Структура проекта

sprint1/
├── infra/                       # Инфраструктурные файлы
│   ├── terraform/               # Terraform-конфигурации
│   │   ├── main.tf              - Основные ресурсы (VM, сеть)
│   │   ├── variables.tf         - Переменные для Yandex Cloud
│   │   └── outputs.tf           - Вывод IP-адресов
│   │
│   └── ansible/                 # Конфигурация Ansible
│       ├── ansible.cfg          - Конфигурация Ansible (отключение host_key_checking)
│       ├── inventory.ini        - Инвентарь с хостами и переменными
│       ├── k8s-full-setup.yml   - Главный playbook для развертывания кластера
│       ├── srv-full-setup.yml   - Playbook для настройки CI/CD сервера
│       │
│       ├── all/                 # Задачи для всех узлов
│       │   ├── tasks/
│       │   │   ├── check_hosts.yml         - Проверка доступности хостов
│       │   │   └── add_docker_repo.yml     - Добавление Docker CE репозитория
│       │   └── handlers/
│       │       └── common_handlers.yml     - Общие обработчики (рестарт сервисов)
│       │
│       ├── kubernetes/          # Задачи для Kubernetes
│       │   ├── tasks/
│       │   │   ├── setup_containerd.yml    - Установка containerd
│       │   │   ├── configure_network.yml   - Настройка сетевых параметров
│       │   │   ├── add_k8s_repo.yml        - Добавление репозитория Kubernetes
│       │   │   ├── install_k8s_packages.yml- Установка kubeadm/kubelet/kubectl
│       │   │   ├── create_kubeadm_config.yml - Генерация конфига kubeadm
│       │   │   ├── init_cluster.yml        - Инициализация кластера (kubeadm init)
│       │   │   ├── get_join_command.yml    - Получение команды для присоединения worker-узлов
│       │   │   ├── join_worker.yml         - Присоединение worker-узлов к кластеру
│       │   │   ├── install_flannel_prereqs.yml - Установка kubectl и jq
│       │   │   ├── download_flannel_manifest.yml - Загрузка манифеста Flannel
│       │   │   ├── configure_flannel.yml   - Настройка Flannel
│       │   │   └── apply_flannel.yml       - Применение Flannel CNI
│       │   │
│       │   └── templates/       # Шаблоны конфигураций
│       │       └── kubeadm-config.yaml.j2  - Шаблон конфига kubeadm
│       │
│       └── srv/                 # Задачи для CI/CD сервера
│           ├── tasks/
│           │   ├── install_base.yml        - Установка базовых пакетов
│           │   ├── docker_install.yml      - Установка и настройка Docker
│           │   ├── install_gitlab_runner.yml - Установка GitLab Runner
│           │   ├── config_gitlab_runner.yml - Конфигурация GitLab Runner
│           │   ├── install_kubectl.yml     - Установка kubectl
│           │   ├── install_helm.yml        - Установка Helm
│           │   ├── configure_helm.yml      - Конфигурация Helm (добавление репозиториев)
│           │   └── copy_kubeconfig.yml     - Копирование kubeconfig с master-ноды
│           │
│           └── vars/
│               └── main.yml     - Переменные для настройки GitLab Runner
├── scripts/                     # Вспомогательные скрипты
│   ├── start-tunnel.sh          - Скрипт для создания SSH-туннелей
│   └── stop-tunnel.sh           - Скрипт для остановки SSH-туннелей
│
└── README.md                    - Основная документация

## 🚀 Развертывание инфраструктуры Terraform

### Инициализация и проверка

```bash
cd infra/terraform
terraform init
terraform validate
terraform plan
```

### Применение конфигурации

```bash
terraform apply -auto-approve
```

### Получение выходных данных

```bash
terraform output'
Запишите полученные IP-адреса для дальнейшей настройки'
```

## 🔄 Настройка SSH-туннеля

После развертывания инфраструктуры запустите туннель для доступа к внутренним ресурсам:

```bash
chmod +x scripts/start-tunnel.sh
./scripts/start-tunnel.sh
```

Туннель предоставит доступ к:
    localhost:2222 → k8s-master (SSH)
    localhost:2223 → k8s-app (SSH)
    localhost:6443 → Kubernetes API'
После завершения работы остановите туннель:

```bash
'./scripts/stop-tunnel.sh'
```

## 📦 Установка и настройка Ansible

1. Настройка inventory

    Обновите `inventory.ini` актуальными данными:

    ```ini
    [k8s_master]
    k8s-master ansible_host=127.0.0.1 ansible_port=2222 ansible_user=ubuntu

    [k8s_workers]
    k8s-app ansible_host=127.0.0.1 ansible_port=2223 ansible_user=ubuntu

    [srv]
    ci-server ansible_host=<публичный-ip-srv> ansible_user=ubuntu

    [all:vars]
    ansible_ssh_private_key_file=~/.ssh/id_rsa
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
    ```

2. Последовательность установки

    Сначала настраиваем Kubernetes кластер:

    ```bash
    cd infra/ansible
    ansible-playbook k8s-full-setup.yml
    ```

    Затем настраиваем CI/CD сервер:

    ```bash
    ansible-playbook srv-full-setup.yml
    ```

    Отдельные компоненты (опционально):

    ```bash
    # Только базовые пакеты
    ansible-playbook srv-full-setup.yml --tags base
    ```

    ```bash
    # Только Docker
    ansible-playbook srv-full-setup.yml --tags docker,docker_repo
    ```

    ```bash
    # Только Kubernetes tools
    ansible-playbook srv-full-setup.yml --tags k8s_tools,kubeconfig
    ```

    ```bash
    # Только GitLab Runner
    ansible-playbook srv-full-setup.yml --tags gitlab_runner,gitlab_runner_config
    ```

    ```bash
    # Только Helm
    ansible-playbook srv-full-setup.yml --tags helm,helm_config
    ```

## 🎯 Проверка результатов

После выполнения всех шагов проверьте:

1. Доступность узлов Kubernetes:

    ```bash
    kubectl get nodes
    ```

2. Работоспособность Docker на `srv`:

    ```bash
    docker run hello-world
    ```

3. Регистрацию GitLab Runner:

    ```bash
    gitlab-runner list
    ```

4. Доступность Helm:

    ```bash
    helm version
    helm repo list
    ```
