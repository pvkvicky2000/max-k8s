# max-k8s
# Absolutely not for production usage 
My Maximo on K8s , Working with Sql Server and Maximo 7.6.1.2
this is a super basic install as proof of concept.

Some files are .sh , if you want to work in windows , the commands are quite easy to translate into .bat
I recommend powershell for windows  

# :bangbang: Allocate at least 8 GB of ram and 4 cpus for docker-desktop :bangbang:

# It needs a working SMP copy in order to work , i tested it on Docker-desktop + Kuberenets , but should work the same on minikube or openshift also

# Pre-Requisites

Install Docker-desktop with k8s

https://andrewlock.net/running-kubernetes-and-the-dashboard-with-docker-desktop/



Here is the directory structure of the project that is expected

/<br/>
|<br/>
|<br/>
--docker-files<br/>
--k8s<br/>
--SMP<br/>
--sql-server<br/>

# This below step is for local install only , for Azure, AWS, GCP or openshift you need to specify another storage provisioner
create a folder called persistent-volume ( this is where your sql server files will reside) in the same folder structure , so it looks like this
/<br/>
|<br/>
|<br/>
--docker-files<br/>
--k8s<br/>
--SMP<br/>
--sql-server<br/>
--persistent-volume<br/>

# Create Storage Provisioner

we need to create pv ( Persistent Volume ) , pvc (Persistent Volume Claim) , SC (storage Class) 

I'm allocating 10 Gb for persistent Volume and 5 Gb fgor Sql Server , if it outgrows that we can expnad it later

<b> For local Persistent volume , in some cases on windows , we need to pass the Absolute path of your Folder instead of relative path<br/>
Goto ./k8s/persistent-volume.yaml file and change the path name to an absolute path of the folder </b>

<br/>
<br/>
./kubectl apply -f ./k8s/persistent-volume.yaml<br/>
./kubectl apply -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl apply -f ./k8s/storageclass.yaml<br/>
<br/><br/>
<b>To see evertything is working fine and allocated </b>
<br/><br/>
./kubectl describe -f ./k8s/persistent-volume.yaml<br/>
./kubectl describe -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl describe -f ./k8s/storageclass.yaml<br/><br/><br/>

<b>Messed up ? need to re-create?</b><br/><br/>
./kubectl delete -f ./k8s/persistent-volume.yaml<br/>
./kubectl delete -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl delete -f ./k8s/storageclass.yaml<br/>
<br/>
# Install Sql Server and perform maximo db install
<br/>
./k8s/createSqlServerImage.sh<br/>
./k8s/startSqlServer.sh<br/>

<br/>
./kubectl get deployment<br/>
./kubectl get pods<br/>
<br/>
to gather logs
<br/>
./kubectl get log <the pod name> ( its random every time , so you need to check based on the output of get pods)<br/>
 <br/>
 <i>You can also check the deployment status using Kubernetes dashboard that you created when you setup the docker desktop<br/><br/>
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ <br/><br/>
</i>

 <br/>
  
The SQL server will be accessible on port 1433<br/>
username : sa <br/>
password : maximo_2012 ( this is in the sql-server-deployment.yaml file FYI)<br/>
<br/>
Now follow the regular steps for craeting a new sql server database ( i named it maxdb76 ) and maximo user ( i named my user "maximo")  
make sure that you allocate at least 400 Mb and auto expand when creating the SQL database
make sure that for the user maximo , the default database is maxdb76 

i'm not going to ouline this step as its fairly easy to do this ( its sql server , also its outlined here)
<br/>
https://www.ibm.com/docs/en/SSLKT6_7.6.0/com.ibm.mam.doc/pdf_was_sql_wad_install.pdf#%5B%7B%22num%22%3A421%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C166%2C443%2Cnull%5D
<br/>

<br/>
Now goto the SMP folder and change the properties to something like this ( assuming you are using my defaults)<br/>
jdbc:sqlserver://localhost\max761-local:1433<br/>
# Note : sometimes the properties file will make a fuss about slashes (\) so in that case change it to jdbc:sqlserver://localhost\\max761-local:1433<br/>
<br/>


now run the install Command

# with demo data<br/>
./SMP/maximo/tools/maximo/maxinst.sh -e -sPRIMARY -tPRIMARY<br/>

# without demo data<br/>
./SMP/maximo/tools/maximo/maxinst.sh -i -sPRIMARY -tPRIMARY<br/>
<br/><br/>
grab a :hamburger: :fries: :tumbler_glass: :tumbler_glass: :tumbler_glass: :sleeping: :sleeping:
<br/><br/>
After its done, query the data ( :grey_question: select * from maxobjectcfg  :grey_question:) to see everything is fine
<br/>
# Now for the Maximo part
<br/><br/>
 <b>Change the SMP/maximo/applications/maximo/properties/maximo.properties jdbc url to below</b>
<br/>
<i>This is because k8s and containers dont really understand localhost , 
<br/>the localhost part is really there to expose the service outside and get our DB tools working with it<br/>
 so we need to refer with the k8s service name when one container connects to another container</i>
<br/><br/>
Change the JDBC URL to
<br/><br/>
jdbc:sqlserver://sql-server-service\\max761-local:1433
<br/>
<br/>

./k8s/createMaximoImage.sh<br/><br/>

❗This might take a while depending on windows / antivirus / internet and strange random forces of the universe and the multiverse ( one time it took 5 mins, another time it took 4 hours 🤷‍♂️)
<br/>
check if the image was created properly
<br/>
./docker image ls<br/><br/>
you should see the image maximo_k8s:latest
<br/>
now run  <br/><br/>
./startMaximo.sh
<br/>
check the status using <br/>
./kubectl get deployment<br/>
./kubectl get pods<br/>
and gather logs to check progress<br/>

After a hot minute , open http://localhost:9080/maximo and you will see a familiar sight ( for some reason on Mac + firefox this doesnt work 🤷‍♂️, so use chrome /safari)
  <br/>
# Great ,so how can i update and redeploy the classes?<br/>

Put your compiled classes / jsp / images of puppies into the correct folders in maximo SMp folder and run<br/><br/>
./k8s/update-maximowar.sh
 
it rebuilds the maximo image and then does a rolling deployment ( here there is a dependency , it doesnt delete the old image properly because docker recognises that the old image is being used and doesnt remove it , just untags it , for now this has to be removed manualy , yes i know i have to create new tag for every build and update the yaml files automatically , but that's future Vijay's problem 🙂)<br/><br/>
  <br/><br/>
# Burn it to the ground
<br/><br/>
./k8s/stopMaximo.sh<br/>
./k8s/stopSqlServer.sh<br/>
<br/>
Don't worry , your Sql server data files are still safe in the persistent-volume<br/>
from this point on just run<br/>
./k8s/startSqlServer.sh<br/>
./k8s/startMaximo.sh  <br/>
  <br/>
# NO , really Burn it to the ground<br/>
./k8s/stopMaximo.sh<br/>
./k8s/stopSqlServer.sh<br/>
./rm -f ./persistent-volume<br/>
 <br/><br/>
# How to do it for 🌩️🌩️🌩️🌩️🌩️??

The implemenation to change is<br/>
./k8s/persistent-volume.yaml<br/>
./k8s/persistent-volume-claim-sqlserver.yaml <br/>
./k8s/storageclass.yaml<br/>
  <br/><br/>
this needs to be changed for every cloud implementation ( Azure disk for Azure , OCS for Openshift , S3 for AWS , NFS for data center etc.)\
all the steps are pretty much the same 
  <br/><br/>
# DB2 ( maybe Works maybe doesnt)
 
**Windows users at this point are just plain of out luck , please use linux , or at least use WSL 2 , it isnt worth the hassle to try to run k8s on windows at this point** 
if you still insist on windows fine then install choclatey from https://chocolatey.org/

and run
```fallback
choco install kubernetes-helm
```


**Warning /minor rant:** DB2 and increasingly IBM products especially on k8s and OpenShift are what I would describe as malfunctioning magnets, cause their stuff just randomly starts malfunctioning, without rhyme or reason, and it's not the same issue every time, I never faced this with either oracle or with SQL server, I mean your experience might be different, but this was way harder than it was supposed to be because, well, this is the opposite of apple , it just ~~works~~ fails.


ok first thing create an ibm cloud account 
https://cloud.ibm.com

now click on manage (its on the top) -->Access (IAM) --> Click on API keys (its on the left) -->Create a new IBM API key 

**Keep this key with you and never share it with anyone**  , this key could be used to spin up entire clusters on IBM cloud and if hackers got it they could use it for crypto mining until your bank accounts run dry ( also dont put in your credit card at all)

All right now login to your K8s cluster on shell ( some of these commands are from an IBM tutorial) , ***the username has to be iamapikey , dont change it*** 
```plaintext
echo <apikey> | docker login -u iamapikey --password-stdin icr.io
```
```plaintext
docker pull icr.io/obs/hdm/db2wh_ee:v11.5.6.0-db2wh-linux
```

This will install Helm , which you can think of as a super awesome deployment tool that packages all the deployments and services and routes ( basically any entire application stack into a neat little package ) that can be committed to a repo and tracked , basically this is your Infrastructure as a code 
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
Download the helm charts from IBM's github repo (download this as is )
https://github.com/IBM/charts/tree/master/stable/ibm-db2warehouse

Db2 enterprise requires a license and im not sure everyone can have it just now, so we're using db2 warehouse which im hoping is free for evaluation  ( unlike Sql server and oracle which is FREE for development , so what gives IBM??)

Now create a namespace for db2 and all the service accounts 

```bash
kubectl create namespace db2
kubectl create serviceaccount db2u -n db2
```
 
 Now setup the pre requisites
 ```bash
 # create a role
kubectl create -f ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/ibm-db2-role.yaml -n db2

#create a role binding 
kubectl create -f ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/ibm-db2-rb.yaml -n db2

#Create a secret ( the username is always iamapikey)
kubectl create secret -n db2 docker-registry ibm-registry \
   --docker-server=icr.io \
   --docker-username=iamapikey \
   --docker-password=<api_key>
  
kubectl patch serviceaccount db2u -n db2 -p '{"imagePullSecrets": [{"name": "ibm-registry"}]}'
```


Ok now we push ( and hope and pray that the cluster doesn't screw up) 
**Attention windows users : at this point i cannot help , you're on your own   --> viel Glück <--**

Create the LDAP bluadmin secret and Db2 instance secret
```
export RELEASE_NAME="max-db2"
export PASSWORD="maximo_2012"
kubectl create secret generic ${RELEASE_NAME}-db2u-ldap-bluadmin --from-literal=password="${PASSWORD}"
kubectl create secret generic ${RELEASE_NAME}-db2u-instance --from-literal=password="${PASSWORD}"
```
open the `./ibm_cloud_pak/pak_extensions/common/helm_options`
file and set it like so
```
storage.useDynamicProvisioning="false"
storage.enableVolumeClaimTemplates="true"
storage.storageLocation.dataStorage.enablePodLevelClaim="true"
storage.storageLocation.dataStorage.enabled="true"
storage.storageLocation.dataStorage.volumeType="pvc"
storage.storageLocation.dataStorage.pvc.claim.storageClassName="maximo-persistent-volume"
storage.storageLocation.dataStorage.pvc.claim.size="10Gi"
storage.storageLocation.metaStorage.enabled="true"
storage.storageLocation.metaStorage.volumeType="pvc"
storage.storageLocation.metaStorage.pvc.claim.storageClassName="maximo-persistent-volume"
storage.storageLocation.metaStorage.pvc.claim.size="10Gi"
```
![](https://cdn.mos.cms.futurecdn.net/4SdzPVn25sxXXTftP59HMW.jpg)

./ibm_cloud_pak/pak_extensions/commondb2u-install \
  --db-type db2wh \
  --namespace db2u-project \
  --release-name db2u-release-2 \ 
  --helm-opt-file ./helm_options
  
![enter image description here](https://jaysblog.org/wp-content/uploads/2018/09/Fervent-Prayers-29t3cks-1vj911t-1.jpg)












