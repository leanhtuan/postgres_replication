provider "kubernetes" {
  config_path = "config"
}
#resource "kubernetes_manifest" "persistentvolume_pv_hostpath" {
#  manifest = {
#    "apiVersion" = "v1"
#    "kind" = "PersistentVolume"
#    "metadata" = {
#      "name" = "pv-hostpath"
#    }
#    "spec" = {
#      "accessModes" = [
#        "ReadWriteOnce",
#      ]
#      "capacity" = {
#        "storage" = "5Gi"
#      }
#      "hostPath" = {
#        "path" = "/var/lib/pgsql/14/data"
#      }
#      "storageClassName" = "hostpath"
#    }
#  }
#}
#resource "kubernetes_manifest" "persistentvolume_pv_hostpath" {
#  manifest = {
#    "apiVersion" = "v1"
#    "kind" = "PersistentVolume"
#    "metadata" = {
#      "name" = "pv-hostpath"
#    }
#    "spec" = {
#      "accessModes" = [
#        "ReadWriteOnce",
#      ]
#      "capacity" = {
#        "storage" = "5Gi"
#      }
#      "hostPath" = {
#        "path" = "/var/lib/pgsql/14/data"
#      }
#      "storageClassName" = "hostpath"
#    }
#  }
#}

resource "kubernetes_manifest" "statefulset_postgres_master" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
    "metadata" = {
      "labels" = {
        "component" = "postgres-master"
      }
      "name" = "postgres-master"
      "namespace" = "default"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "component" = "postgres-master"
        }
      }
      "serviceName" = "postgres-master"
      "template" = {
        "metadata" = {
          "labels" = {
            "component" = "postgres-master"
          }
        }
        "spec" = {
          "containers" = [
            {
              "command" = [
                "sh",
                "-c",
                "docker-entrypoint.sh -c config_file=/var/config/postgresql.conf -c hba_file=/var/config/pg_hba.conf",
              ]
              "envFrom" = [
                {
                  "configMapRef" = {
                    "name" = "postgres-password"
                  }
                },
              ]
              "image" = "postgres:11"
              "name" = "postgres"
              "ports" = [
                {
                  "containerPort" = 5432
                },
              ]
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/pgsql/14/data"
                  "name" = "postgres-data-master"
                },
                {
                  "mountPath" = "/var/config"
                  "name" = "postgres-master-configmap"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "configMap" = {
                "name" = "postgres-master-configmap"
              }
              "name" = "postgres-master-configmap"
            },
          ]
        }
      }
      "volumeClaimTemplates" = [
        {
          "metadata" = {
            "name" = "postgres-data-master"
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
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "service_postgres_master" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "postgres-master"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "nodePort" = 30000
          "port" = 5432
        },
      ]
      "selector" = {
        "component" = "postgres-master"
      }
      "type" = "NodePort"
    }
  }
}
/*

resource "kubernetes_manifest" "persistentvolumeclaim_postgres_data_slave" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "PersistentVolumeClaim"
    "metadata"   = {
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
      "storageClassName" = "hostpath2"
    }
  }
}

resource "kubernetes_manifest" "job_sync_master_data" {
  manifest = {
    "apiVersion" = "batch/v1"
    "kind" = "Job"
    "metadata" = {
      "name" = "sync-master-data"
      "namespace" = "default"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "containers" = [
            {
              "command" = [
                "sh",
                "-c",
                "PGPASSWORD=\"postgres\" pg_basebackup -h postgres-master -D /var/lib/slave-postgresql/data -U postgres -vP",
              ]
              "image" = "postgres:11"
              "name" = "sync-master-data"
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/slave-postgresql/data"
                  "name" = "postgres-data"
                },
              ]
            },
          ]
          "restartPolicy" = "OnFailure"
          "volumes" = [
            {
              "name" = "postgres-data"
              "persistentVolumeClaim" = {
                "claimName" = "postgres-data-slave"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "statefulset_postgres_slave" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
    "metadata" = {
      "labels" = {
        "component" = "postgres-slave"
      }
      "name" = "postgres-slave"
      "namespace" = "default"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "component" = "postgres-slave"
        }
      }
      "serviceName" = "postgres-slave"
      "template" = {
        "metadata" = {
          "labels" = {
            "component" = "postgres-slave"
          }
        }
        "spec" = {
          "containers" = [
            {
              "envFrom" = [
                {
                  "configMapRef" = {
                    "name" = "postgres-password"
                  }
                },
              ]
              "image" = "postgres:11"
              "name" = "postgres"
              "ports" = [
                {
                  "containerPort" = 5432
                },
              ]
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/pgsql/14/data"
                  "name" = "postgres-data"
                },
              ]
            },
          ]
          "initContainers" = [
            {
              "command" = [
                "sh",
                "-c",
                "cp /var/config/postgresql.conf /var/lib/pgsql/14/data/postgresql.conf && cp /var/config/recovery.conf /var/lib/pgsql/14/data/recovery.conf",
              ]
              "image" = "busybox"
              "name" = "busybox"
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/pgsql/14/data"
                  "name" = "postgres-data"
                },
                {
                  "mountPath" = "/var/config/postgresql.conf"
                  "name" = "postgres-slave-configmap"
                  "subPath" = "postgresql.conf"
                },
                {
                  "mountPath" = "/var/config/recovery.conf"
                  "name" = "postgres-slave-configmap"
                  "subPath" = "recovery.conf"
                },
              ]
            },
          ]
          "volumes" = [
            {
              "configMap" = {
                "name" = "postgres-slave-configmap"
              }
              "name" = "postgres-slave-configmap"
            },
            {
              "name" = "postgres-data"
              "persistentVolumeClaim" = {
                "claimName" = "postgres-data-slave"
              }
            },
          ]
        }
      }
    }
  }
}
*/

#terraform {
#  required_providers {
#    docker = {
#      source = "kreuzwerker/docker"
#      version = "~> 2.13.0"
#    }
#  }
#}
#
#provider "docker" {
#  version = "~> 2.6"
#  host    = "npipe:////.//pipe//docker_engine"
#}
#
#resource "docker_image" "nginx" {
#  name         = "nginx:latest"
#  keep_locally = false
#}
#
#resource "docker_container" "nginx" {
#  image = docker_image.nginx.latest
#  name  = var.container_name
#  ports {
#    internal = 80
#    external = 8000
#  }
#}