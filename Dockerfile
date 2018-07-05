FROM ubuntu:16.04

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN apt-get update && \
    apt-get -y install wget software-properties-common python-software-properties sudo && \
    add-apt-repository ppa:git-core/ppa -y && \
    add-apt-repository ppa:openjdk-r/ppa -y && \
    wget -qO- https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get update && \
    apt-get -y install \
    locales \
    rsync \
    openssh-server \
    procps \
    unzip \
    mc \
    ca-certificates \
    curl \
    bash-completion \ 
    git \
    subversion \
    build-essential \
    libkrb5-dev \
    gcc \
    make \
    debian-keyring \
    python2.7 \
    gnupg2 \
    openjdk-8-jdk-headless=8u171-b11-0ubuntu0.16.04.1 \
    openjdk-8-source=8u171-b11-0ubuntu0.16.04.1 \
    nodejs && \
    mkdir /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    # Adding user to the 'root' is a workaround for https://issues.jboss.org/browse/CDK-305
    useradd -u 1000 -G users,sudo,root -d /home/user --shell /bin/bash -m user && \
    usermod -p "*" user && \
    apt-get clean && \
    apt-get -y autoremove && \
    sudo update-ca-certificates -f && \
    sudo sudo /var/lib/dpkg/info/ca-certificates-java.postinst configure && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    \curl -sSL https://get.rvm.io | bash -s stable --ruby && \
    sudo npm install --unsafe-perm -g yarn gulp bower grunt grunt-cli yeoman-generator yo generator-angular generator-karma generator-webapp

ENV LANG en_GB.UTF-8
ENV LANG en_US.UTF-8
USER user
RUN sudo locale-gen en_US.UTF-8 && \
    svn --version && \
    cd /home/user && ls -la && \
    sed -i 's/# store-passwords = no/store-passwords = yes/g' /home/user/.subversion/servers && \
    sed -i 's/# store-plaintext-passwords = no/store-plaintext-passwords = yes/g' /home/user/.subversion/servers
EXPOSE 22 4403 1337 3000 4000 4200 5000 9000 8003 35729
WORKDIR /projects

# The following instructions set the right
# permissions and scripts to allow the container
# to be run by an arbitrary user (i.e. a user
# that doesn't already exist in /etc/passwd)
ENV HOME /home/user
RUN for f in "/home/user" "/etc/passwd" "/etc/group" "/projects"; do\
           sudo chgrp -R 0 ${f} && \
           sudo chmod -R g+rwX ${f}; \
        done && \
        # Generate passwd.template \
        cat /etc/passwd | \
        sed s#user:x.*#user:x:\${USER_ID}:\${GROUP_ID}::\${HOME}:/bin/bash#g \
        > /home/user/passwd.template && \
        # Generate group.template \
        cat /etc/group | \
        sed s#root:x:0:#root:x:0:0,\${USER_ID}:#g \
        > /home/user/group.template && \
        sudo sed -ri 's/StrictModes yes/StrictModes no/g' /etc/ssh/sshd_config
COPY ["entrypoint.sh","/home/user/entrypoint.sh"]
ENTRYPOINT ["/home/user/entrypoint.sh"]
CMD tail -f /dev/null
LABEL che:server:8003:ref=angular che:server:8003:protocol=http che:server:3000:ref=node-3000 che:server:3000:protocol=http che:server:9000:ref=node-9000 che:server:9000:protocol=http
