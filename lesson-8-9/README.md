# 📦 Full CI/CD Pipeline: Jenkins + Terraform + ECR + Helm + Argo CD

Цей проєкт реалізує повний GitOps-орієнтований CI/CD процес для
Django-застосунку на Kubernetes, використовуючи:

-   **Terraform** --- інфраструктура (AWS, EKS, ECR, S3 backend)\
-   **Helm** --- деплоймент застосунку\
-   **Jenkins** --- CI-процес: build → push → update Helm\
-   **Argo CD** --- CD-процес: GitOps синхронізація Helm-чарта\
-   **Kaniko** --- побудова контейнерів у Kubernetes agent

Це типовий стек сучасної DevOps-команди, який автоматизує доставку змін
від Git до продакшн-кластера без ручних дій.

------------------------------------------------------------------------

# 🏗 Архітектура CI/CD

``` text
                 +-------------------------+
                 |     GitHub (App Repo)   |
                 |  Django source code     |
                 +-----------+-------------+
                             |
                             v
                  +----------+-----------+
                  |      Jenkins CI      |
                  |----------------------|
                  | 1. Build Docker img  |
                  | 2. Push to ECR       |
                  | 3. Update Helm chart |
                  +----------+-----------+
                             |
                             v
                 +-----------+------------+
                 |   GitHub (Helm Repo)   |
                 |  values.yaml updated   |
                 +-----------+------------+
                             |
                             v
                   +---------+---------+
                   |      Argo CD      |
                   |-------------------|
                   | GitOps Sync       |
                   | Auto deploy to K8s|
                   +---------+---------+
                             |
                             v
                     +-------+-------+
                     |     EKS       |
                     |  Django App   |
                     +---------------+
```

------------------------------------------------------------------------

# 📁 Структура репозиторію

    Project/
    │
    ├── main.tf
    ├── backend.tf
    ├── outputs.tf
    │
    ├── modules/
    │   ├── s3-backend/
    │   ├── vpc/
    │   ├── ecr/
    │   ├── eks/
    │   ├── jenkins/
    │   └── argo_cd/
    │
    └── charts/
        └── django-app/

------------------------------------------------------------------------

# ☁️ Інфраструктура (Terraform)

Після клонування репозиторію:

``` bash
terraform init
terraform plan
terraform apply
```

Terraform створює:

### ✔ S3 + DynamoDB backend

### ✔ VPC з приватними і публічними підмережами

### ✔ ECR репозиторій

### ✔ EKS кластер

### ✔ Jenkins через Helm

### ✔ Argo CD через Helm

### ✔ Argo Applications через Helm-чарт

------------------------------------------------------------------------

# ⚙️ Jenkins (CI)

Jenkins встановлюється в Kubernetes через Helm і використовує Kubernetes
agent із Kaniko для побудови образів.

## 🔐 Доступ до Jenkins

Отримати пароль адміністратора:

``` bash
kubectl get secret jenkins -n jenkins   -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

Проброс порту:

``` bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

UI:

    http://localhost:8080

------------------------------------------------------------------------

## 🧪 Jenkins Pipeline

Функціональність `Jenkinsfile`:

### 1️⃣ Checkout Django репозиторію

### 2️⃣ Build Docker image через Kaniko

### 3️⃣ Push у Amazon ECR

### 4️⃣ Оновлення `values.yaml` у Helm-чарті

### 5️⃣ Commit + push у main → це тригер для Argo CD

------------------------------------------------------------------------

# 🚀 Argo CD (CD)

Argo CD встановлюється Terraform модулем через Helm.

## 🔐 Доступ до Argo CD

Пароль адміністратора:

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 --decode
```

Порт-форвардинг:

``` bash
kubectl port-forward svc/argo-cd-argocd-server 8081:443 -n argocd
```

UI:

    https://localhost:8081

------------------------------------------------------------------------

## 🤖 Argo Application (GitOps)

Argo CD автоматично синхронізує Helm-чарт:

-   репозиторій: Helm-deploy-repo\
-   директорія: `charts/django-app`\
-   режим: `automated`\
-   опції: `prune`, `selfHeal`, `CreateNamespace=true`

Тобто кожна зміна image tag у Git → автоматичний redeploy у EKS.

------------------------------------------------------------------------

# 🧰 Helm чарт Django застосунку

Знаходиться в `charts/django-app`.

Головні значення у `values.yaml`:

``` yaml
image:
  repository: <ECR-URL>
  tag: "latest"
```

Jenkins оновлює тільки:

``` yaml
image.tag
```

------------------------------------------------------------------------

# 🔄 Повний цикл роботи

1.  Пуш коду в GitHub\
2.  Jenkins запускає pipeline\
3.  Kaniko будує Docker image\
4.  Образ пушиться в ECR\
5.  Jenkins оновлює Helm-чарт\
6.  Коміт і пуш у main\
7.  Argo CD бачить зміни та синхронізує\
8.  Kubernetes оновлює Deployment\
9.  Новий реліз працює 🎉

------------------------------------------------------------------------

# 📑 Команди для тестування вручну

### Тестовий деплой:

``` bash
helm upgrade --install django-app ./charts/django-app -n django --create-namespace
```

### Перевірити поди:

``` bash
kubectl get pods -n django
```

------------------------------------------------------------------------

# 📘 Висновок

Проєкт реалізує:

✔ Повноцінний CI/CD\
✔ GitOps деплоймент через Argo CD\
✔ Terraform інфраструктуру\
✔ Jenkins з Kaniko\
✔ Автоматичний оновлюваний Helm чарт

Сучасний, чистий і продакшн-орієнтований DevOps workflow.
