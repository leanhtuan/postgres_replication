
/*provider "kubernetes" {
  config_path = "config"
}*/

resource "kubernetes_manifest" "persistentvolume_pv_hostpath" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolume"
    "metadata" = {
      "name" = "pv-hostpath"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "2Gi"
      }
      "hostPath" = {
        "path" = "/var/lib/postgresql/data"
      }
      "storageClassName" = "hostpath"
    }
  }
}

/*resource "kubernetes_manifest" "persistentvolume_pv_hostpath2" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolume"
    "metadata" = {
      "name" = "pv-hostpath"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "2Gi"
      }
      "hostPath" = {
        "path" = "/var/lib/postgresql/data"
      }
      "storageClassName" = "hostpath2"
    }
  }
}*/

resource "kubernetes_manifest" "persistentvolume_pv_hostpath2" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolume"
    "metadata" = {
      "name" = "pv-hostpath2"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "capacity" = {
        "storage" = "5Gi"
      }
      "hostPath" = {
        "path" = "/var/lib/postgresql/data"
      }
      "storageClassName" = "hostpath2"
    }
  }
}

resource "kubernetes_manifest" "persistentvolumeclaim_postgres_data_slave" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "PersistentVolumeClaim"
    "metadata" = {
      "name" = "postgres-data-slave"
      "namespace" = "default"
    }
    "spec" = {
      "accessModes" = [
        "ReadWriteOnce",
      ]
      "resources" = {
        "requests" = {
          "storage" = "1Gi"
        }
      }
      "storageClassName" = "hostpath"
    }
  }
}