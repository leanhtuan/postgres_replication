#!/bin/bash
kubectl exec -it postgres-master-0 -- date
echo "helloworld"
sleep 30