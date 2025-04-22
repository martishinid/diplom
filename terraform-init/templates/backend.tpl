terraform {
  backend "s3" {
      endpoints = {
        s3 = "https://storage.yandexcloud.net"
      }
      bucket     = "${bucket.name}"
      region     = "${bucket.region}"
      key        = "${bucket.key}"
      access_key = "${access_key}"
      secret_key = "${secret_key}"

      skip_region_validation      = true
      skip_credentials_validation = true
      skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
      skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}
