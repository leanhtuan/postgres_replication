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
              "args" = [
                "cp /var/config/postgresql.conf /var/lib/pgsql/14/data/postgresql.conf && cp /var/config/recovery.conf /var/lib/pgsql/14/data/recovery.conf;",
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
                  "name" = "postgres-data-slave"
                },
                {
                  "mountPath" = "/var/config"
                  "name" = "postgres-slave-configmap"
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
          ]
        }
      }
      "volumeClaimTemplates" = [
        {
          "metadata" = {
            "name" = "postgres-data-slave"
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