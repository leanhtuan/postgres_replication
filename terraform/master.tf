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
              "args" = [
                "docker-entrypoint.sh -c config_file=/var/config/postgresql.conf -c hba_file=/var/config/pg_hba.conf;",
              ]
              "command" = [
                "sh",
                "-c",
              ]
              "envFrom" = [
                {
                  "configMapRef" = {
                    "name" = "postgres-password"
                  }
                },
              ]
              "image" = "postgres:14"
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
            #            "storageClassName" = "hostpath"
          }
        },
      ]
    }
  }
}