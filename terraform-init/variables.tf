#######################################
# Yandex.cloud SECRET VARS
#######################################
## token
variable "token" {
  type        = string
  description = "OAuth-token 'yc iam create-token' (https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token)"
  sensitive   = true
}

## organization id
variable "organization_id" {
  type        = string
  description = "ID организации 'yc organization-manager organization list'"
  sensitive   = true
}
## cloud id
variable "cloud_id" {
  type        = string
  description = "'yc resource-manager cloud get <имя_облака>' (https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id)"
  sensitive   = true
}
## cloud-folder id
variable "folder_id" {
  type        = string
  description = "'yc resource-manager folder list' (https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id)"
  sensitive   = true
}

#######################################
# Yandex.cloud DEFAULTS
#######################################
## default network zone (used in yandex_vpc_subnet) - 'ru-central1-a'
variable "default_zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
  default     = "ru-central1-a"
}

#######################################
# TERRAFORM VARS
#######################################
## Terraform service account name
variable "terraform_sa_name" {
  type        = string
  description = "Terraform service account name"
}
## Path to main teraform mpdule
## with creating all infrustructure
variable "terraform_main_path" {
  type        = string
  description = "Path to main teraform mpdule with creating all infrustructure"
}
## Filename of secret vars
## to be created
variable "terraform_main_secret_vars_filename" {
  type        = string
  description = "Filename of secret vars for main terraform module"
}
#######################################
# Yandex.cloud BUCKET
#######################################
## bucket name
variable "tfstate_bucket_name" {
  type        = string
  description = "Short bucket name for storing .tfstate"
}
## bucket name suffix
variable "tfstate_bucket_name_suffix" {
  type        = string
  description = "Suffix name for bucket"
}

## bucket data key
variable "tfstate_bucket_key" {
  type        = string
  description = "Object key in Bucket in pair (key:value) for storing .tfstate"
}
## bucket encryption key name
variable "tfstate_bucket_kms_key_name" {
  type        = string
  description = "KMS key for encrypting bucket content"
}
## bucket encryption algorithm
variable "tfstate_bucket_kms_key_algorithm" {
  type        = string
  description = "Bucket encryption algorithm {AES_256_HSM |SYMMETRIC_ALGORITHM_UNSPECIFIED | AES_128 | AES_192 | AES_256}"
}
## bucket encryption key rotation
variable "tfstate_bucket_kms_key_rotation" {
  type        = string
  description = "Bucket key rotation period"
}
