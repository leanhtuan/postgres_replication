[Kubernetes Practice - Setup a database master-slave replication with PostgreSQL](https://viblo.asia/p/kubernetes-practice-setup-a-database-master-slave-replication-with-postgresql-924lJB2mlPM)

  kubectl apply -f postgres-password-cm.yaml && kubectl create cm postgres-master-configmap --from-file=config && kubectl create cm postgres-slave-configmap --from-file=slave-config
kubectl apply -f pv-hostpath.yaml

kubectl apply -f postgres-master-sts.yaml

kubectl exec -it postgres-master-0 -- bash
root@postgres-master-0:/# su - postgres
postgres=# su - postgres
$psql
-----------------
SET password_encryption = 'scram-sha-256';
CREATE ROLE repuser WITH REPLICATION PASSWORD 'postgres' LOGIN;
SELECT * FROM pg_create_physical_replication_slot('replica_1_slot');
-----------------
kubectl apply -f postgres-master-svc.yaml
kubectl apply -f pvc-slave.yaml
kubectl apply -f sync-master-data.yaml
kubectl create cm postgres-slave-configmap --from-file=slave-config
kubectl apply -f postgres-slave-sts.yaml


