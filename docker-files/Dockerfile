FROM websphere-liberty:21.0.0.5-full-java8-ibmjava
COPY "./maximo-ui-server/" "/config/"
#ADD "/Users/vijay/Docker-WAS-maximo/Anywhere/SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-ui-server/server.xml" "/config/server.xml"
#ADD "/Users/vijay/Docker-WAS-maximo/Anywhere/SMP/maximo/deployment/was-liberty-default/deployment/maximo-ui/maximo-ui-server/jvm.options" "/config/jvm.options"
#RUN ["sudo","chmod", "-R","777", "/opt/ibm/wlp/usr/servers"]
CMD ["/opt/ibm/wlp/bin/server","run", "defaultServer"]
EXPOSE 7777/tcp
EXPOSE 9080/tcp
EXPOSE 9443/tcp
ENV PATH="/opt/ibm/wlp/bin:/opt/ibm/helpers/build:/opt/ibm/java/jre/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	JAVA_VERSION="1.8.0_sr6fp30"\
    JAVA_HOME="/opt/ibm/java/jre"\
    IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,readonly,nonfatal,cacheDir=/output/.classCache/ -Dosgi.checkConfiguration=false -XX:+UseContainerSupport"\
    LIBERTY_VERSION="21.0.0_05"\
    LOG_DIR="/logs"\
    WLP_OUTPUT_DIR="/opt/ibm/wlp/output"\
    OPENJ9_SCC="true"\
    RANDFILE="/tmp/.rnd"