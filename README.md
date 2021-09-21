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

<br/>
./kubectl apply -f ./k8s/persistent-volume.yaml<br/>
./kubectl apply -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl apply -f ./k8s/storageclass.yaml<br/>

To see evertything is working fine and allocated 
<br/>
./kubectl describe -f ./k8s/persistent-volume.yaml<br/>
./kubectl describe -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl describe -f ./k8s/storageclass.yaml<br/>

Messed up ? need to re-create?<br/><br/>
./kubectl delete -f ./k8s/persistent-volume.yaml<br/>
./kubectl delete -f ./k8s/persistent-volume-claim-sqlserver.yaml<br/>
./kubectl delete -f ./k8s/storageclass.yaml<br/>

# Install Sql Server and perform maximo db install
<br/>
./k8s/createSqlServerImage.sh<br/>
./k8s/startSqlServer.sh<br/>

you can check the deployment status using 
<br/>
./kubectl get deployment<br/>
./kubectl get pods<br/>
<br/>
to gather logs
<br/>
./kubectl get log <the pod name> ( its random every time , so you need to check based on the output of get pods)

you can also track this using docker desktp and just clicking on the pod , but try to use cmds just to practice
 <br/>
  
The SQL server will be accessible on port 1433<br/>
username : sa <br/>
password : maximo_2012 ( this is in the sql-server-deployment.yaml file FYI)<br/>
<br/>
Now follow the regular steps for craeting a new sql server database ( i named it maxdb76 ) and maximo user ( i named my user "maximo")  
make sure that you allocate at least 400 Mb and auto expand when creating the SQL database
make sure that for the user maximo , the default database is maxdb76 

i'm not going to ouline this step as its fairly easy to do this ( its sql server , so its fairly easy , also its outlined here)
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
# DB2 ??
Coming soon ... 🙂











