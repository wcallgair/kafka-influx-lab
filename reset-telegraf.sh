#!/bin/bash


echo "starting lab..."
if [ `docker ps | grep minikube | wc -l` -gt 0 ]; then
	echo "minikube running.."
else
	echo "minikube not running.. starting.."
	minikube start
fi

echo "adding repos.."
helm repo add influxdata https://helm.influxdata.com/

echo "Install telegraf-client chart..."
helm uninstall telegraf-client-lab
helm install -f telegraf-client.yaml telegraf-client-lab influxdata/telegraf > /dev/null

echo "Install telegraf-read chart..."
helm uninstall telegraf-read-lab
helm install -f telegraf-read.yaml telegraf-read-lab influxdata/telegraf > /dev/null

echo "Install telegraf-write chart..."
helm uninstall telegraf-write-lab
helm install -f telegraf-write.yaml telegraf-write-lab influxdata/telegraf > /dev/null

sleep 3
kubectl get pods| grep telegraf
