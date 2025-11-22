# Jenkins + Terraform + Helm + Argo CD (lesson-8-9)

Цей проєкт демонструє повний CI/CD ланцюжок для розгортання
Django-застосунку у Kubernetes, використовуючи Terraform, Jenkins,
Amazon ECR, Helm та Argo CD.

------------------------------------------------------------------------

## 1. Як застосувати Terraform

Перед початком переконайтесь, що: - Налаштовані AWS credentials
(`aws configure` або змінні середовища). - Ви перебуваєте в директорії
`lesson-8-9` (поруч із `main.tf`).

### Кроки

``` bash
cd lesson-8-9

terraform init
terraform plan
terraform apply
```

Terraform створює: - S3 + DynamoDB backend - VPC та підмережі - EKS
кластер - ECR репозиторій - Jenkins (через Helm) - Argo CD (через
Helm) - Argo CD Application для Django

------------------------------------------------------------------------

## 2. Як перевірити Jenkins job

### 2.1. Отримання доступу до Jenkins

Проброс порту:

``` bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

UI:

    http://localhost:8080

Отримати пароль admin:

``` bash
kubectl get secret jenkins -n jenkins   -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

### 2.2. Перевірка CI-процесу

1.  Увійдіть у Jenkins.
2.  Відкрийте ваш pipeline/job.
3.  Натисніть **Build Now**.
4.  Перегляньте **Console Output**.

Job має: - Зібрати Docker-образ через Kaniko\
- Запушити образ у Amazon ECR\
- Оновити `image.tag` у Helm-чарті\
- Запушити зміни у Helm-репозиторій

------------------------------------------------------------------------

## 3. Як побачити результат в Argo CD

### 3.1. Доступ до Argo CD

Проброс порту:

``` bash
kubectl port-forward svc/argo-cd-argocd-server 8081:443 -n argocd
```

UI:

    https://localhost:8081

Пароль admin:

``` bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 --decode
```

### 3.2. Перегляд стану застосунку

У UI перейдіть у **Applications** → оберіть ваш застосунок.

Статуси: - **Synced** --- кластер відповідає Git. - **OutOfSync** ---
Argo CD виявив зміни. - **Healthy** --- застосунок працює коректно.

Після успішного Jenkins job: - Argo CD бачить новий коміт - Автоматично
оновлює Deployment (якщо ввімкнено automated sync) - Новий Docker-образ
розгортається в EKS

### 3.3. Перевірка в Kubernetes

``` bash
kubectl get pods -n django
kubectl describe deployment django-app -n django | grep Image
```

------------------------------------------------------------------------

## Висновок

Цей репозиторій містить завершену CI/CD систему:

-   Terraform --- інфраструктура\
-   Jenkins --- CI (збірка + push)\
-   ECR --- реєстр образів\
-   Helm --- керування чартами\
-   Argo CD --- автоматичний GitOps деплоймент
