cd ../SMP/maximo/deployment/was-liberty-default
./buildmaximoui-war.sh
./buildmaximo-xwar.sh
docker image rm maximo_k8s:latest
cd ../../../../docker-files
rm -rf ./maximo-ui-server
cp -R ../SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-ui-server ./maximo-ui-server
docker build -t maximo_k8s:latest .
rm -rf ./maximo-ui-server