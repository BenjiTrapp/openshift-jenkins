FROM openshift/jenkins-2-centos7:latest

USER root

LABEL maintainer="WolverMinion <neo71.matrix@gmx.de>"

COPY containerfiles /

#RUN yum --disablerepo=base update && \
#    yum clean all -y

RUN ln -s $((readlink -f $(which javac ))| sed "s:bin/javac::") /usr/lib/jvm/java1.8 && \
    find /tmp/resources -name "*.sh" && \
    chmod 777 /tmp/resources/*/*.sh && \
    echo "change own run Script for openshift" && \
    mv /usr/libexec/s2i/run /usr/libexec/s2i/run-original.sh && \
    mv /usr/libexec/s2i/run.sh /usr/libexec/s2i/run && \
    chmod 775 /usr/libexec/s2i/run && \
    echo "change own assemble Script for openshift" && \
    mv /usr/libexec/s2i/assemble /usr/libexec/s2i/assemble-original.sh && \
    mv /usr/libexec/s2i/assemble.sh /usr/libexec/s2i/assemble && \
    chmod 775 /usr/libexec/s2i/assemble && \
    echo "Change Jenkins 4 ME" && \
    /tmp/resources/jenkins/setup-jenkins.sh && \
    echo "start update CA" && \
    update-ca-trust

USER 1001
