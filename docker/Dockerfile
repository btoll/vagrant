FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y software-properties-common jq curl unzip && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    apt-add-repository ppa:ansible/ansible && \
    apt-get update -y && \
    apt-get install -y ansible && \
    ansible --version

ARG ANSIBLE_VAULT_PASSWORD
RUN echo $ANSIBLE_VAULT_PASSWORD
ENV ANSIBLE_VAULT_PASSWORD=$ANSIBLE_VAULT_PASSWORD
RUN mkdir -p /opt/ansible-deployers && \
    echo $ANSIBLE_VAULT_PASSWORD > /opt/.ansible-vault-password
RUN cat /opt/.ansible-vault-password
WORKDIR /opt/ansible-deployers

COPY . .

#RUN ansible-playbook setup.yml
