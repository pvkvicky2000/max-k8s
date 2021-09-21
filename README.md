# max-k8s
# Absolutely not for production usage 
My Maximo on K8s , Working with Sql Server and Maximo 7.6.1.2
this is a super basic install as proof of concept.

Some files are .sh , if you want to work in windows , the commands are quite easy to translate into .bat

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


# Install Sql Server and perform maximo db install

./k8s/createSqlServerImage.sh
./k8s/startSqlServer.sh

The SQL server will be accessible on port 1433
Now follow the regular steps for craeting a new sql server database ( i named it maxdb76 ) and maximo user ( i named my user "maximo")  
make sure that you allocate at least 400 Mb and auto expand when creating the SQL database
make sure that for the user maximo , the default database is maxdb76 

i'm not going to ouline this step as its fairly easy to do this ( its sql server , so its fairly easy , also its outlined here)

https://www.ibm.com/docs/en/SSLKT6_7.6.0/com.ibm.mam.doc/pdf_was_sql_wad_install.pdf#%5B%7B%22num%22%3A421%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C166%2C443%2Cnull%5D



Now goto the SMP folder and change the properties to something like this ( assuming you are using my defaults)
jdbc:sqlserver://localhost\max761-local:1433
# Note : sometimes the properties file will make a fuss about slashes (\) so in that case chnage it to jdbc:sqlserver://localhost\\max761-local:1433

now run the install Command

# with demo data
./SMP/maximo/tools/maximo/maxinst.sh -e -sPRIMARY -tPRIMARY

# without demo data
./SMP/maximo/tools/maximo/maxinst.sh -i -sPRIMARY -tPRIMARY

grab a :hamburger: :fries: :tumbler_glass: :tumbler_glass: :tumbler_glass:

after its done just 








