terraform {
  required_providers {
    rke = {
      source = "rancher/rke"
      version = "1.3.3"
    }
  }
}

# Configure RKE provider
provider "rke" {
  log_file = "rke_debug.log"
}
# Create a new RKE cluster using config yaml
resource "rke_cluster" "cluster" {
  delay_on_creation = 30   
  cluster_yaml = file("cluster.yml")
}

resource "local_sensitive_file" "kube_cluster_yaml" {
  filename = "/var/lib/jenkins/.kube/config"
  content  = "${rke_cluster.cluster.kube_config_yaml}"
}
