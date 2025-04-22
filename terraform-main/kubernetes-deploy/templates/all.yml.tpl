---
# FILE inventory/sample/group_vars/all/all.yml

## Directory where the binaries will be installed
bin_dir: /usr/local/bin

## External LB example config
## apiserver_loadbalancer_domain_name: "elb.some.domain"
#loadbalancer_apiserver:
#  address: ${loadbalancer_ext_ip}
#  port: ${loadbalancer_ext_port}

## Internal loadbalancers for apiservers
# loadbalancer_apiserver_localhost: true
# valid options are "nginx" or "haproxy"
# loadbalancer_apiserver_type: nginx  # valid values "nginx" or "haproxy"

## Local loadbalancer should use this port
## And must be set port 6443
loadbalancer_apiserver_port: ${loadbalancer_int_port}

## If loadbalancer_apiserver_healthcheck_port variable defined, enables proxy liveness check for nginx.
loadbalancer_apiserver_healthcheck_port: ${loadbalancer_healthcheck_port} #8081

## Since workers are included in the no_proxy variable by default, docker engine will be restarted on all nodes (all
## pods will restart) when adding or removing workers.  To override this behaviour by only including control plane nodes
## in the no_proxy variable, set below to true:
no_proxy_exclude_workers: true

## Certificate Management
## This setting determines whether certs are generated via scripts.
## Chose 'none' if you provide your own certificates.
## Option is  "script", "none"
# cert_management: script

## Variables for webhook token auth https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication
kube_webhook_token_auth: false
kube_webhook_token_auth_url_skip_tls_verify: false
# kube_webhook_token_auth_url: https://...
## base64-encoded string of the webhook's CA certificate
# kube_webhook_token_auth_ca_data: "LS0t..."

## NTP Settings
# Start the ntpd or chrony service and enable it at system boot.
ntp_enabled: false
ntp_manage_config: false
ntp_servers:
  - "0.pool.ntp.org iburst"
  - "1.pool.ntp.org iburst"
  - "2.pool.ntp.org iburst"
  - "3.pool.ntp.org iburst"

## Used to control no_log attribute
unsafe_show_logs: false

## If enabled it will allow kubespray to attempt setup even if the distribution is not supported. For unsupported distributions this can lead to unexpected failures in some cases.
allow_unsupported_distribution_setup: false
