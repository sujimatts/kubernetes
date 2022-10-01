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
resource "rke_cluster" "foo" {
  delay_on_creation = 30   
  cluster_yaml = file("cluster.yml")
}

resource "local_sensitive_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = "${rke_cluster.foo.kube_config_yaml}"
}
