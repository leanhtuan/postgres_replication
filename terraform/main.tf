/*
provider "kubernetes" {
  config_path = "config"
}
*/

resource "null_resource" "kubectl" {
  depends_on = [kubernetes_manifest.statefulset_postgres_master]
  provisioner "local-exec" {
    command     = "${path.module}/create_role.sh"
    interpreter = ["bash", "-c"]
  }
}


resource "kubernetes_manifest" "job_sync_master_data" {
  depends_on = [kubernetes_manifest.job_sync_master_data]
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
                "PGPASSWORD='postgres' pg_basebackup -h postgres-master -D /var/lib/slave-postgresql/data -U repuser -vP",
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
