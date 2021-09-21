# max-k8s
# Absolutely not for production usage 
My Maximo on K8s , Working with Sql Server and Maximo 7.6.1.2
this is a super basic install as proof of concept.

Some files are .sh , if you want to work in windows , the commands are quite easy to translate into .bat

# :bangbang: Allocate at least 8 GB of ram and 4 cpus for docker-desktop :bangbang:

# It needs a working SMP copy in order to work , i tested it on Docker-desktop + Kuberenets , but should work the same on minikube or openshift also

# Pre-Requisites

Here is the directory structure of the project that is expected

/
|
|
--docker-files
--k8s
--SMP
--sql-server

# This below step is for local install only , for Azure, AWS, GCP or openshift you need to specify another storage provisioner
create a folder called persistent-volume ( this is where your sql server files will reside) in the same folder structure , so it looks like this
/
|
|
--docker-files
--k8s
--SMP
--sql-server
# --persistent-volume

# Create Storage Provisioner

we need to create pv ( Persistent Volume ) , pvc (Persistent Volume Claim) , SC (storage Class) 

I'm allocating 10 Gb for persistent Volume and 5 Gb fgor Sql Server , if it outgrows that we can expnad it later


./kubectl apply -f ./k8s/persistent-volume.yaml
./kubectl apply -f ./k8s/persistent-volume-claim-sqlserver.yaml
./kubectl apply -f ./k8s/storageclass.yaml

To see evertything is working fine and allocated 

./kubectl describe -f ./k8s/persistent-volume.yaml
./kubectl describe -f ./k8s/persistent-volume-claim-sqlserver.yaml
./kubectl describe -f ./k8s/storageclass.yaml

Messed up ? need to re-create?
./kubectl delete -f ./k8s/persistent-volume.yaml
./kubectl delete -f ./k8s/persistent-volume-claim-sqlserver.yaml
./kubectl delete -f ./k8s/storageclass.yaml

# Install Sql Server and perform maximo db install

./k8s/createSqlServerImage.sh
./k8s/startSqlServer.sh

you can check the deployment status using 

./kubectl get deployment
./kubectl get pods

to gather logs

./kubectl get log <the pod name> ( its random every time , so you need to check based on the output of get pods)

you can also track this using docker desktp and just clicking on the pod , but try to use cmds just to practice
  
  
The SQL server will be accessible on port 1433
Now follow the regular steps for craeting a new sql server database ( i named it maxdb76 ) and maximo user ( i named my user "maximo")  
make sure that you allocate at least 400 Mb and auto expand when creating the SQL database
make sure that for the user maximo , the default database is maxdb76 

i'm not going to ouline this step as its fairly easy to do this ( its sql server , so its fairly easy , also its outlined here)

https://www.ibm.com/docs/en/SSLKT6_7.6.0/com.ibm.mam.doc/pdf_was_sql_wad_install.pdf#%5B%7B%22num%22%3A421%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C166%2C443%2Cnull%5D



Now goto the SMP folder and change the properties to something like this ( assuming you are using my defaults)
jdbc:sqlserver://localhost\max761-local:1433
# Note : sometimes the properties file will make a fuss about slashes (\) so in that case change it to jdbc:sqlserver://localhost\\max761-local:1433

now run the install Command

# with demo data
./SMP/maximo/tools/maximo/maxinst.sh -e -sPRIMARY -tPRIMARY

# without demo data
./SMP/maximo/tools/maximo/maxinst.sh -i -sPRIMARY -tPRIMARY

grab a :hamburger: :fries: :tumbler_glass: :tumbler_glass: :tumbler_glass: :sleeping: :sleeping:

After its done, query the data ( :grey_question: select * from maxobjectcfg  :grey_question:) to see everything is fine

# Now for the Maximo part

./k8s/createMaximoImage.sh

❗This might take a while depending on windows / antivirus / internet and strange random forces of the universe and the multiverse ( one time it took 5 mins, another time it took 4 hours 🤷‍♂️)

check if the image was created properly

./docker image ls
you should see the image maximo_k8s:latest

now run  
./startMaximo.sh

check the status using 
./kubectl get deployment
./kubectl get pods
and gather logs to check progress

After a hot minute , open http://localhost:9080/maximo and you will see a familiar sight ( for some reason on Mac + firefox this doesnt work 🤷‍♂️, so use chrome /safari)
  
# Great ,so how can i update and redeploy the classes?

Put your compiled classes / jsp / images of puppies into the correct folders in maximo SMp folder and run
./k8s/update-maximowar.sh
 
it rebuilds the maximo image and then does a rolling deployment ( here there is a dependency , it doesnt delete the old image properly because docker recognises that the old image is being used and doesnt remove it , just untags it , for now this has to be removed manualy , yes i know i have to create new tag for every build and update the yaml files automatically , but that's future Vijay's problem 🙂)
  
# Burn it to the ground

./k8s/stopMaximo.sh
./k8s/stopSqlServer.sh

Don't worry , your Sql server data files are still safe in the persistent-volume
from this point on just run
./k8s/startSqlServer.sh
./k8s/startMaximo.sh  
  
# NO , really Burn it to the ground
./k8s/stopMaximo.sh
./k8s/stopSqlServer.sh
./rm -f ./persistent-volume
 
# How to do it for 🌩️🌩️🌩️🌩️🌩️??

The implemenation to change is
./k8s/persistent-volume.yaml
./k8s/persistent-volume-claim-sqlserver.yaml 
./k8s/storageclass.yaml
  
this needs to be changed for every cloud implementation ( Azure disk for Azure , OCS for Openshift , S3 for AWS , NFS for data center etc.)\
all the steps are pretty much the same 
  
# DB2 ??
Coming soon ... 🙂











