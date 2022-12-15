#!/bin/bash

interval_in_seconds=3;
while true;
do
    container_status=` kubectl exec -i postgres-master-0 -- pg_isready`;
    echo "$container_status";
    if [[ $container_status == *"accepting connections"* ]]; then
        echo "Status is running"
            kubectl exec -i postgres-master-0 -- date
            kubectl exec -i postgres-master-0 -- psql -U postgres -c "SET password_encryption = 'scram-sha-256';"
            kubectl exec -i postgres-master-0 -- psql -U postgres -c "CREATE ROLE repuser WITH REPLICATION PASSWORD 'postgres' LOGIN;"
            kubectl exec -i postgres-master-0 -- psql -U postgres -c "SELECT * FROM pg_create_physical_replication_slot('replica_1_slot');"
            kubectl exec -i postgres-master-0 -- date
            kubectl exec -i postgres-master-0 -- echo "helloworld"
        break;
    fi;
    echo container_status;
    echo "Waiting for pod ready...";
    sleep $interval_in_seconds;
done