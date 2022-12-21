
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
                  "mountPath" = "/var/lib/postgresql/data"
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
                "cp /var/config/postgresql.conf /var/lib/postgresql/data/postgresql.conf && cp /var/config/recovery.conf /var/lib/postgresql/data/recovery.conf && pg_resetxlog /var/lib/postgresql/data;",
                #                "echo 'hello'",
              ]
              #              "args":

              "image" = "busybox"
              "name" = "busybox"
              "volumeMounts" = [
                {
                  "mountPath" = "/var/lib/postgresql/data"
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
    depends_on = [kubernetes_manifest.job_sync_master_data]
}
