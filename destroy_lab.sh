echo "killing lab..."
helm uninstall grafana-lab
helm uninstall influxdb-lab
helm uninstall telegraf-lab
for i in `screen -ls | grep lab | awk '{print $1}'` ; do screen -S $i -X quit ; done
sleep 3
echo "lab is dead..."
kubectl get pods
