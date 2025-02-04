echo "killing lab..."
helm uninstall grafana-lab
helm uninstall influxdb-lab
helm uninstall kafka-lab
helm uninstall telegraf-client-lab
helm uninstall telegraf-read-lab
helm uninstall telegraf-write-lab

for i in `screen -ls | grep lab | awk '{print $1}'` ; do screen -S $i -X quit ; done
sleep 5
echo "lab is dead..."
kubectl get pods
