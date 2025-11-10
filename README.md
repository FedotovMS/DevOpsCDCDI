# Terraform AWS — Lesson 5

## Опис проєкту
Цей проєкт демонструє використання **Infrastructure as Code (IaC)** з **Terraform** для створення базової інфраструктури в AWS.

Інфраструктура включає:
- **S3 + DynamoDB** — бекенд для збереження Terraform state і блокування через DynamoDB.
- **VPC** — мережа з публічними та приватними підмережами, Internet Gateway, NAT Gateway і маршрутами.
- **ECR** — репозиторій для зберігання Docker-образів із автоматичним скануванням при push.

---

## 🗂️ Структура проєкту
```
lesson-5/
├── main.tf            # Підключення модулів
├── backend.tf         # Налаштування бекенду для Terraform state
├── outputs.tf         # Виведення результатів
├── variables.tf       # Змінні для кореневого модуля
├── README.md          # Документація проєкту
└── modules/
    ├── s3-backend/    # Модуль S3 + DynamoDB
    │   ├── s3.tf
    │   ├── dynamodb.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc/           # Модуль мережевої інфраструктури
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/           # Модуль для ECR
        ├── ecr.tf
        ├── variables.tf
        └── outputs.tf
```

---

## ⚙️ Команди для запуску

1️⃣ **Ініціалізація Terraform**
```bash
terraform init
```
> Підключає бекенд і завантажує модулі та провайдери.

2️⃣ **Перевірка плану**
```bash
terraform plan
```
> Показує, які ресурси будуть створені або змінені.

3️⃣ **Створення інфраструктури**
```bash
terraform apply
```
> Створює всі ресурси AWS: S3, DynamoDB, VPC, ECR.

4️⃣ **Видалення інфраструктури**
```bash
terraform destroy
```
> Видаляє всі створені ресурси, щоб уникнути зайвих витрат.

---

## 🧩 Опис модулів

### 1. `modules/s3-backend`
Модуль створює:
- **S3 bucket** для зберігання Terraform state:
  - назва: `my-lesson5-terraform-goit-neovercity-demo-hw5-state`
  - ввімкнено **versioning**
  - шифрування AES256
- **DynamoDB таблицю** `terraform-locks` для блокування state-файлів.

**Outputs:**
- Назва S3 bucket
- Ім’я таблиці DynamoDB

---

### 2. `modules/vpc`
Модуль створює базову мережеву інфраструктуру:
- **VPC** із CIDR `10.0.0.0/16`
- **3 публічні підмережі**: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- **3 приватні підмережі**: `10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24`
- **Internet Gateway** для публічного доступу
- **NAT Gateway** для виходу в інтернет із приватних підмереж
- **Route Tables** для маршрутизації

**Outputs:**
- `vpc_id` — ID створеного VPC  
- `public_subnet_ids` — список ID публічних підмереж  
- `private_subnet_ids` — список ID приватних підмереж  
- `igw_id` — ID Internet Gateway  
- `nat_gateway_id` — ID NAT Gateway  

---

### 3. `modules/ecr`
Модуль створює:
- **ECR репозиторій** `lesson-5-ecr`
- Автоматичне **сканування образів** при push
- Lifecycle політику для видалення старих *untagged* образів (через 14 днів)
- Політику доступу для поточного AWS акаунта

**Outputs:**
- `repository_url` — повний URL до репозиторію ECR  
- `repository_arn` — ARN репозиторію

---

## 🧠 Важливі примітки

- **Backend налаштований на S3 і DynamoDB:**
  ```hcl
  terraform {
    backend "s3" {
      bucket         = "my-lesson5-terraform-goit-neovercity-demo-hw5-state"
      key            = "lesson-5/terraform.tfstate"
      region         = "eu-north-1"
      dynamodb_table = "terraform-locks"
      encrypt        = true
    }
  }
  ```
- Ім’я S3 бакета має бути унікальним у всьому AWS.
- Після завершення перевірки завжди виконуйте:
  ```bash
  terraform destroy
  ```
  щоб уникнути нарахувань від AWS.

---

## 🌍 Регіон
Всі ресурси створюються в:
```
region = "eu-north-1"
availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
```

---

## 👨‍💻 Автор
**Микола Федотов**  
Terraform AWS — Lesson 5
