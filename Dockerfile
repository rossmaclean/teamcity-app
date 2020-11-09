FROM cloudron/base:2.0.0@sha256:f9fea80513aa7c92fe2e7bf3978b54c8ac5222f47a9a32a7f8833edf0eb5a4f4

EXPOSE 8000

RUN mkdir -p /app/data/runtime /app/data/config /run && \
    chown -R cloudron:cloudron /app/data/runtime /app/data/config /run

WORKDIR /app/data

# configure apache
RUN rm /etc/apache2/sites-enabled/*
RUN sed -e 's,^ErrorLog.*,ErrorLog "|/bin/cat",' -i /etc/apache2/apache2.conf
RUN a2disconf other-vhosts-access-log
ADD apache/teamcity.conf /etc/apache2/sites-enabled/teamcity.conf
RUN echo "Listen 8000" > /etc/apache2/ports.conf
RUN a2enmod ldap authnz_ldap proxy proxy_http rewrite

## install TeamCity
#RUN mkdir -p /usr/local/bin/teamcity && \
#    cd /usr/local/bin && \
#    wget -c https://download-cf.jetbrains.com/teamcity/TeamCity-2020.1.5.tar.gz && \
#    tar xvfz TeamCity-*.tar.gz && \
#    rm -rf TeamCity-*.tar.gz && \
#    mv TeamCity*/* teamcity && \
#    rm -rf TeamCity-* && \
#    chown -R cloudron:cloudron teamcity

# install TeamCity
RUN mkdir -p /run/teamcity && \
    cd /run && \
    wget -c https://download-cf.jetbrains.com/teamcity/TeamCity-2020.1.5.tar.gz && \
    tar xvfz TeamCity-*.tar.gz && \
    rm -rf TeamCity-*.tar.gz && \
    mv TeamCity*/* teamcity && \
    rm -rf TeamCity-* && \
    chown -R cloudron:cloudron teamcity

# Install OpenJDK8
RUN apt update
RUN apt install openjdk-8-jdk-headless -y

# install TeamCity
#RUN mkdir -p /usr/local/bin/tomcat && \
#    cd /usr/local/bin && \
#    wget -c https://apache.mirrors.nublue.co.uk/tomcat/tomcat-9/v9.0.39/bin/apache-tomcat-9.0.39.tar.gz && \
#    tar xvfz apache-*.tar.gz && \
#    rm -rf apache-*.tar.gz && \
#    mv apache-*/* tomcat && \
#    rm -rf apache-* && \
#    chown -R cloudron:cloudron tomcat

#RUN sudo -u cloudron cp -n /usr/local/bin/teamcity/teamcity.yml /app/data/config/teamcity.yml

COPY start.sh /app/pkg/
RUN chmod +x /app/pkg/start.sh

RUN export CATALINA_HOME=/usr/local/bin/tomcat

RUN echo "=> Starting apache"
RUN APACHE_CONFDIR="" source /etc/apache2/envvars
RUN rm -f "${APACHE_PID_FILE}"
RUN /usr/sbin/apache2 -DFOREGROUND &

RUN echo "=> Starting TeamCity"
RUN cd /run/teamcity/bin
#  exec /usr/local/bin/gosu cloudron:cloudron ./runAll.sh start
CMD [ "exec /usr/local/bin/gosu cloudron:cloudron /run/teamcity/bin/runAll.sh start" ]
#CMD [ "/app/pkg/start.sh" ]
