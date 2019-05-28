## Azure resource provider ##
provider "azurerm" {
  version = "=1.5.0"
}

## Azure resource group for the kubernetes cluster ##
resource "azurerm_resource_group" "aks_demo" {
  name     = "kubedemo"
  location = "centralus"
}
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

## Save the private key in the local workspace ##
resource "null_resource" "save-key" {
  triggers {
    key = "${tls_private_key.key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}
## AKS kubernetes cluster ##
resource "azurerm_kubernetes_cluster" "aks_demo" {
  name                = "kubecluster"
  location            = "${azurerm_resource_group.aks_demo.location}"
  resource_group_name = "${azurerm_resource_group.aks_demo.name}"
  dns_prefix          = "aksdemo"

  linux_profile {
    admin_username = "hema"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVWTA82YrcEBJjttULhqVK/BbBmqW9fNJGEX/pbaq3zf1vLK/HE9V37VgedT6RwVt7R16hpeYi5zAyuWcDym9hiCxdEqcVi1h2xIXMCWxzq5XJWym6/tLNZQ2o04oMF0T4coIKk8RMcj19L31PXyX1W8NWu+ZyBiza+UDcXpzoNBb0/go7lIJED0jkpbppIwMuhQMFNhiy/+eqG24iA/S2/4ginkjGY4dxy/iaCPrYHZ+jK4JEpQyG41aFu29001HCniOL1/fWkRBEfRZ8KAzlbE8QLkoaRxE/Wr4UIezU8+duQ+ycIfbEq6gxY9QK7MYOwojp6+XhOXv9170km9mr zippyops@cc-ab48d1c0-6c874bb846-brf47"

    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "2"
    vm_size         = "Standard_D2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "e6bc1045-4417-4717-b48a-6b18b956d0b3"
    client_secret = "70137cc5-44d1-42de-bf83-a5dce0f2a2e0"
  }

  tags {
    Environment = "Production"
  }
}

## Outputs ##

# Example at#output "id" {
#    value = "${azurerm_kubernetes_cluster.aks_demo.id}"
#}
#
#output "client_key" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.client_key}"
#}
#
#output "client_certificate" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.client_certificate}"
#}
#
#output "cluster_ca_certificate" {
#  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.cluster_ca_certificate}"
#}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks_demo.kube_config.0.host}"
}

output "configure" {
  value = <<CONFIGURE

Run the following commands to configure kubernetes client:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl

$ kubectl get nodes
CONFIGURE
}

tributes available for output
