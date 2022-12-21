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
                  "mountPath" = "/var/lib/postgresql/data"
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
            #            "storageClassName" = "hostpath"
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
