#!/bin/bash



test_run=0
until [ "$test_run" -gt 1 ]; do
	test_run=`kubectl get pods | grep kafka | grep Running | wc -l`
	echo "waiting for kafka to start..."
	sleep 1
done
screen -S kafka-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=kafka,app.kubernetes.io/instance=kafka-lab" -o jsonpath='{ .items[0].metadata.name }') 9092 \n"

