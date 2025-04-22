#######################################
# НАСТРОЙКИ ОРГАНИЗАЦИИ ДЛЯ РАБОТЫ OS LOGIN
#######################################
## Настройки OS Login
resource "yandex_organizationmanager_os_login_settings" "my_os_login_settings" {
  organization_id = var.organization_id
  ssh_certificate_settings {
    enabled = true
  }
  user_ssh_key_settings {
    enabled               = true
    allow_manage_own_keys = true
  }
}

#######################################
# СЕРВИСНЫЙ АККАУНТ ДЛЯ TERRAFORM
#######################################
## Сервисный аккаунт Terraform
resource "yandex_iam_service_account" "terraform_sa" {
  name        = var.terraform_sa_name
  description = "Terraform service account"
}
## Предоставление роли Editor на текущий folder
## для возможности создания ресурсов в облаке
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
resource "yandex_resourcemanager_folder_iam_member" "storage-admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли kms.keys.encrypterDecrypter на текущий folder
## для работы с S3 Bucket в зашифрованном виде
resource "yandex_resourcemanager_folder_iam_member" "encrypterDecrypter" {
  folder_id = var.folder_id
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли compute.osLogin на текущий folder
## для возможности подключения к ВМ через OS Login
resource "yandex_resourcemanager_folder_iam_member" "osLogin" {
  folder_id = var.folder_id
  role      = "compute.osLogin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли compute.operator на текущий folder
## для возможности подключения к ВМ через OS Login
resource "yandex_resourcemanager_folder_iam_member" "operator" {
  folder_id = var.folder_id
  role      = "compute.operator"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли load-balancer.admin на текущий folder
## для возможности создавать внешние балансировщики (NLB)
resource "yandex_resourcemanager_folder_iam_member" "loadBalancerAdmin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

## Предоставление роли k8s.clusters.agent на текущий folder
resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли vpc.publicAdmin на текущий folder
resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
## Предоставление роли container-registry.images.puller на текущий folder
resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}
#######################################
# BUCKET И КЛЮЧИ ШИФРОВАНИЯ
#######################################
## Ключ Yandex Key Management Service для шифрования .tfstate, 
resource "yandex_kms_symmetric_key" "tfstate-bucket-kms-key" {
  name              = var.tfstate_bucket_kms_key_name
  default_algorithm = var.tfstate_bucket_kms_key_algorithm
  rotation_period   = var.tfstate_bucket_kms_key_rotation
  description       = "KMS key for encrypting tfstate bucket content"
  # Дополнительные настройки
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}
## Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "static access key for terraform service account"
}
## BUCKET
resource "yandex_storage_bucket" "tfstate-bucket" {
  bucket     = "${var.tfstate_bucket_name}-${var.tfstate_bucket_name_suffix != "" ? var.tfstate_bucket_name_suffix : formatdate("YYYYMMDD", timestamp())}"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.tfstate-bucket-kms-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  # Дополнительные параметры доступа
  anonymous_access_flags {
    read        = false # Public read access to bucket objects.
    list        = false # Public view access to the list of bucket objects.
    config_read = true  # Public read access to bucket settings.
  }
  # для включения механизма блокировок
  versioning {
    enabled = true
  }
  # политика блокировки доступа к данным
  object_lock_configuration {
    object_lock_enabled = "Enabled"

  }
  # удаляем, даже если не пустой
  force_destroy = true

  # зависимости
  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage-admin
  ]
}

#######################################
# НАСТРОЙКА S3 BACKEND ДЛЯ TERRAFORM-MAIN
# СОЗДАЕМ BACKEND.SECRET.TFVARS
#######################################
## СОздаем файл с переменными 
resource "local_file" "vars" {
  content = templatefile("${path.module}/templates/variables.tpl",
    {
      bucket : {
        name : yandex_storage_bucket.tfstate-bucket.bucket,
        bucket_domain_name : yandex_storage_bucket.tfstate-bucket.bucket_domain_name,
        id : yandex_storage_bucket.tfstate-bucket.id,
        region : var.default_zone,
        key : var.tfstate_bucket_key
      }
      access_key : yandex_iam_service_account_static_access_key.sa-static-key.access_key
      secret_key : yandex_iam_service_account_static_access_key.sa-static-key.secret_key
    }
  )
  filename = "${var.terraform_main_path}${var.terraform_main_secret_vars_filename}"
  # зависимости
  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage-admin,
    yandex_iam_service_account_static_access_key.sa-static-key,
    yandex_storage_bucket.tfstate-bucket
  ]
}

# Создаем yandex_container_registry
resource "yandex_container_registry" "my_registry" {
  name = "my-nginx-registry"
}

## Создаем файл backend.tf
# resource "local_file" "backend" {
#   content = templatefile("${path.module}/templates/backend.tpl",
#     {
#       bucket: {
#         name: yandex_storage_bucket.tfstate-bucket.bucket,
# 		    bucket_domain_name: yandex_storage_bucket.tfstate-bucket.bucket_domain_name,
# 		    id: yandex_storage_bucket.tfstate-bucket.id,
#         region: var.default_zone,
#         key: var.tfstate_bucket_key
# 	    }
#       access_key: yandex_iam_service_account_static_access_key.sa-static-key.access_key
#       secret_key: yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#     } 
#   )
#   filename = "${var.terraform_main_path}backend.tf"
#   # зависимости
#   depends_on = [
#     yandex_resourcemanager_folder_iam_member.storage-admin,
#     yandex_iam_service_account_static_access_key.sa-static-key,
#     yandex_storage_bucket.tfstate-bucket
#   ]
# }


# resource "null_resource" "example" {
#   provisioner "local-exec" {
#     command = "curl --request POST --header 'Content-Type: application/json' --header 'Authorization: Bearer ${var.token}' --data '{'serviceAccountId': '${yandex_iam_service_account_static_access_key.sa-static-key.service_account_id}'}'   https://storage.yandexcloud.net/iam/v1/keys >> keys.json"
#   }

#   # зависимости
#   depends_on = [
#     yandex_resourcemanager_folder_iam_member.storage-admin,
#     yandex_iam_service_account_static_access_key.sa-static-key
#   ]
# }