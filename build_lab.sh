#!/bin/bash
set -e

echo "starting lab..."
if [ `docker ps | grep minikube | wc -l` -gt 0 ]; then
	echo "minikube running.."
else
	echo "minikube not running.. starting.."
	minikube start
fi

echo "adding repos.."
helm repo add influxdata https://helm.influxdata.com/
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add kafka https://charts.bitnami.com/bitnami

echo "Install grafana-lab chart..."
helm install -f grafana.yaml grafana-lab grafana/grafana > /dev/null

echo "Install influxdb-lab chart..."
helm install -f influxdb.yaml influxdb-lab influxdata/influxdb > /dev/null

echo "Install kafka-lab chart..."
helm install -f kafka.yaml kafka-lab kafka/kafka > /dev/null

echo "adding repos.."
helm repo add influxdata https://helm.influxdata.com/

echo "Install telegraf-client chart..."
helm install -f telegraf-client.yaml telegraf-client-lab influxdata/telegraf > /dev/null

echo "Install telegraf-read chart..."
helm install -f telegraf-read.yaml telegraf-read-lab influxdata/telegraf > /dev/null

echo "Install telegraf-write chart..."
helm install -f telegraf-write.yaml telegraf-write-lab influxdata/telegraf > /dev/null


echo "Create screen sessnions..."
screen -dmS grafana-lab-portfwd 
screen -dmS influxdb-lab-portfwd
screen -dmS kafka-lab-portfwd

echo "Starting grafana-lab-portfwd..."
test_grafana=0
until [ "$test_grafana" -gt 0 ]; do
	test_grafana=`kubectl get pods | grep grafana | grep Running | wc -l`
	echo "Waiting for grafana to start... val: $test_grafana"
	sleep 1
done
screen -S grafana-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana-lab" -o jsonpath="{.items[0].metadata.name}") 3000 \n" 

echo "Starting influxdb-lab-portfwd..."
test_influxdb=0
until [ "$test_influxdb" -gt 0 ]; do
	test_influxdb=`kubectl get pods | grep influxdb | grep Running | wc -l`
	echo "Waiting for influxdb to start... val: $test_influxdb"
	sleep 1
done
screen -S influxdb-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=influxdb,app.kubernetes.io/instance=influxdb-lab" -o jsonpath='{ .items[0].metadata.name }') 8086 \n"

echo "Starting kafka-lab-portfwd..."
test_kafka=0
until [ "$test_kafka" -gt 0 ]; do
	test_kafka=`kubectl get pods | grep kafka | grep Running | wc -l`
	echo "Waiting for kafka to start... val: $test_kafka"
	sleep 1
done
screen -S kafka-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=kafka,app.kubernetes.io/instance=kafka-lab" -o jsonpath='{ .items[0].metadata.name }') 9092 \n"

echo "done!"
kubectl get pods

