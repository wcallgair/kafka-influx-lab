#!/bin/bash

echo "starting lab..."

if [ `docker ps | grep minikube | wc -l` -gt 0 ]; then
	echo "minikube running.."
else
	echo "minikube not running.. starting.."
	minikube start
fi

echo "install helm chats..."
helm install -f grafana.yaml grafana-lab /home/bill/git-repos/grafana/helm-charts/charts/grafana
helm install -f influxdb.yaml influxdb-lab /home/bill/git-repos/influxdb/helm-charts/charts/influxdb
helm install -f telegraf.yaml telegraf-lab /home/bill/git-repos/influxdb/helm-charts/charts/telegraf

echo "pause 3 seconds and create port forwarding via screen..."
sleep 3
screen -dmS grafana-lab-portfwd 
screen -dmS influxdb-lab-portfwd
screen -S grafana-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana-lab" -o jsonpath="{.items[0].metadata.name}") 3000 \n" 
screen -S influxdb-lab-portfwd -X stuff "/usr/local/bin/kubectl port-forward --namespace default $(kubectl get pods --namespace default -l "app.kubernetes.io/name=influxdb,app.kubernetes.io/instance=influxdb-lab" -o jsonpath='{ .items[0].metadata.name }') 8086 \n"

echo "pause 3 seconds before posting telegraf database creation..."
sleep 3
curl -i -XPOST http://localhost:8086/query --data-urlencode 'q=CREATE DATABASE "telegraf" WITH DURATION 30d REPLICATION 1 NAME "rp_30d"'

echo "done!"
kubectl get pods

