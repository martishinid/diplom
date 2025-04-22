output "terraform_sa" {
  description = "Terraform Service Account ID for creating instances and other objects in Cloud folder"
  value = {
    id          = yandex_iam_service_account.terraform_sa.id,
    name        = yandex_iam_service_account.terraform_sa.name,
    description = yandex_iam_service_account.terraform_sa.description
    folder_id   = yandex_iam_service_account.terraform_sa.folder_id
  }
}

output "tfstate_bucket" {
  description = "Object storage for .tfstate"
  value = {
    bucket             = yandex_storage_bucket.tfstate-bucket.bucket,
    bucket_domain_name = yandex_storage_bucket.tfstate-bucket.bucket_domain_name
    id                 = yandex_storage_bucket.tfstate-bucket.id
  }
}

output "sa-key" {
  value = {
    id    = yandex_iam_service_account_static_access_key.sa-static-key.id
    sa_id = yandex_iam_service_account_static_access_key.sa-static-key.service_account_id
    #key_id = yandex_iam_service_account_static_access_key.sa-static-key.key_id
    #public_key = yandex_iam_service_account_static_access_key.sa-static-key.public_key 
    #private_key = yandex_iam_service_account_static_access_key.sa-static-key.private_key 
  }
}

output "registry_id" {
  value = yandex_container_registry.my_registry.id
}