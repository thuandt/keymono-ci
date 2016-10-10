FROM golang:1.7

MAINTAINER Thuan Duong <thuandt26@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV CLOUDSDK_VERSION 129.0.0

ENV JAVA_VERSION 8u102
ENV JAVA_DEBIAN_VERSION 8u102-b14.1-1~bpo8+1

# see https://bugs.debian.org/775775
# and https://github.com/docker-library/java/issues/19#issuecomment-70546872
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.10.0.1
ENV KAFKA_MIRROR http://apache.stu.edu.tw/kafka
ENV KAFKA_HOME /opt/kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"
ENV PATH=$KAFKA_HOME/bin:$PATH

COPY scripts/install_protoc.sh /usr/scripts/install_protoc.sh

# Enable backports repos and install some system utils included beanstalkd
RUN apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends apt-transport-https ca-certificates && \
    echo 'deb http://httpredir.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
    echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > /etc/apt/sources.list.d/docker-engine.list && \
    ## Docker repos GPG keys: https://docs.docker.com/engine/installation/linux/debian/#/debian-jessie-80-64-bit
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    apt-get -qq update && \
    apt-get install -qq -y --no-install-recommends \
            jq unzip rsync expect tcl tcl-tclreadline bzip2 unzip xz-utils \
            beanstalkd mysql-client docker-engine

# Install glide, protoc, gometalinter and some golang tools
RUN curl https://glide.sh/get | bash && \
    /bin/bash /usr/scripts/install_protoc.sh && \
    go get github.com/alecthomas/gometalinter \
           github.com/golang/lint/golint \
           github.com/kisielk/errcheck \
           github.com/golang/protobuf/proto \
           github.com/golang/protobuf/protoc-gen-go \
           github.com/ckaznocha/protoc-gen-lint

# Install OpenJDK for kafka
# Based offical openjdk Dockerfile
# https://github.com/docker-library/openjdk/blob/baaaf7714f9c66e4c5decf2c108a2738b7186c7f/8-jre/Dockerfile
RUN apt-get install -y \
    openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
    ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" && \
    rm -rf /var/lib/apt/lists/* && \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Install nodejs for React project deployment
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -qq -y nodejs

# Install Kafka, Zookeeper
RUN apt-get install -qq -y --no-install-recommends zookeeper supervisor dnsutils && \
    curl -sSL "${KAFKA_MIRROR}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | tar -xzf - -C /opt && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY scripts/start-kafka.sh /usr/bin/start-kafka.sh

# Supervisor config
COPY supervisor /etc/supervisor/conf.d

# Install Google Cloud SDK for deployment
RUN curl -s https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-"${CLOUDSDK_VERSION}"-linux-x86_64.tar.gz | tar -xz -C /opt/ && \
    /opt/google-cloud-sdk/bin/gcloud --quiet components install kubectl && \
    echo "source '/opt/google-cloud-sdk/path.bash.inc'" >> /root/.bashrc

# 2181 is zookeeper, 9092 is kafka, 11300 is beanstalkd
EXPOSE 2181 9092 11300

CMD ["/usr/bin/supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf"]
