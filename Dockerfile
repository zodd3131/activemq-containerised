FROM openjdk:11.0.14.1-oraclelinux8

ENV ACTIVEMQ_VERSION 5.15.9
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQPS=5671 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV SHA512_VAL=35cae4258e38e47f9f81e785f547afc457fc331d2177bfc2391277ce24123be1196f10c670b61e30b43b7ab0db0628f3ff33f08660f235b7796d59ba922d444f

ENV ACTIVEMQ_HOME /opt/activemq

RUN set -x && \
    mkdir -p /opt && \
    microdnf install -y curl && \
    curl https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz -o $ACTIVEMQ-bin.tar.gz
# Validate checksum
RUN if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ];\
    then \
    echo "sha512 values doesn't match! exiting."  && \
    exit 1; \
    fi;

RUN tar xzf $ACTIVEMQ-bin.tar.gz -C  /opt && \
    ln -s /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    groupadd -r activemq && useradd -r -M -g activemq -d $ACTIVEMQ_HOME activemq && \
    chown -R activemq:activemq /opt/$ACTIVEMQ && \
    chown -h activemq:activemq $ACTIVEMQ_HOME && \
    microdnf clean all && \
    rm -rf /var/cache/yum

COPY entrypoint.sh /entrypoint.sh


COPY jolokia-access.xml $ACTIVEMQ_HOME/webapps/api/WEB-INF/classes/
COPY activemq.xml groups.properties users.properties $ACTIVEMQ_HOME/conf/
RUN chown activemq: $ACTIVEMQ_HOME/conf/groups.properties $ACTIVEMQ_HOME/conf/users.properties

USER activemq

EXPOSE $ACTIVEMQ_TCP $ACTIVEMQ_AMQPS $ACTIVEMQ_AMQP $ACTIVEMQ_UI

ENTRYPOINT [ "/entrypoint.sh" ]
