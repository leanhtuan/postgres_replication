
provider "kubernetes" {
  config_path = "config"
}


resource "kubernetes_config_map" "postgres-master-configmap" {
  metadata {
    name      = "postgres-master-configmap"
    namespace = "default"
  }
  data = {
    "postgresql.conf" = <<VERNEMQCONF
      listen_addresses = '*'
      max_connections = 100
      shared_buffers = 128MB
      dynamic_shared_memory_type = posix
      max_wal_size = 1GB
      min_wal_size = 80MB
      log_timezone = 'Etc/UTC'
      datestyle = 'iso, mdy'
      timezone = 'Etc/UTC'
      lc_messages = 'en_US.utf8'
      lc_monetary = 'en_US.utf8'
      lc_numeric = 'en_US.utf8'
      lc_time = 'en_US.utf8'
      default_text_search_config = 'pg_catalog.english'
      wal_level = replica
      max_wal_senders = 2
      max_replication_slots = 2
      synchronous_commit = off
    VERNEMQCONF
    "pg_hba.conf" = file("master-config/pg_hba.conf")

  }
}

resource "kubernetes_config_map" "postgres-slave-configmap" {
  metadata {
    name      = "postgres-slave-configmap"
    namespace = "default"
  }
  data = {
    "postgresql.conf" = <<VERNEMQCONF
      listen_addresses = '*'
      max_connections = 100
      shared_buffers = 128MB
      dynamic_shared_memory_type = posix

      max_wal_size = 1GB
      min_wal_size = 80MB
      log_timezone = 'Etc/UTC'
      datestyle = 'iso, mdy'
      timezone = 'Etc/UTC'
      lc_messages = 'en_US.utf8'
      lc_monetary = 'en_US.utf8'
      lc_numeric = 'en_US.utf8'
      lc_time = 'en_US.utf8'
      default_text_search_config = 'pg_catalog.english'
      hot_standby = on
      wal_level = replica
      max_wal_senders = 2
      max_replication_slots = 2
      synchronous_commit = off
    VERNEMQCONF
    "recovery.conf" = <<VERNEMQCONF
      standby_mode = on
      primary_conninfo = 'host=postgres-master port=5432 user=repuser password=postgres application_name=r1'
      primary_slot_name = 'replica_1_slot'
      trigger_file = '/var/lib/postgresql/data/change_to_master'
    VERNEMQCONF
  }
}

resource "kubernetes_config_map" "postgres-password" {
  metadata {
    name = "postgres-password"
  }

  data = {
    POSTGRES_USER: "postgres"
    POSTGRES_PASSWORD: "postgres"
    TIMESCALEDB_TELEMETRY: "off"
  }
}

