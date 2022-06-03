FROM chef/chefworkstation:stable

ARG USER=btoll
RUN apt-get update \
    && apt-get install -y \
        awscli \
        curl \
        gnupg \
        silversearcher-ag \
        software-properties-common \
        tree \
        unzip \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev

RUN mkdir -p "$HOME/.ssh" \
    && ssh-keyscan github.com >> "$HOME/.ssh/known_hosts"
RUN --mount=type=ssh git clone git@github.com:pagerduty/chef.git
RUN --mount=type=ssh git clone git@github.com:pagerduty/knife-chef-config.git

# Install Chef Workstation.
RUN wget https://packages.chef.io/files/stable/chef-workstation/21.9.613/ubuntu/20.04/chef-workstation_21.9.613-1_amd64.deb \
    && dpkg -i chef-workstation_21.9.613-1_amd64.deb

RUN useradd -m $USER
RUN mkdir /home/$USER/workspace \
    && mv /chef "/home/$USER/workspace" \
    && mkdir "/home/$USER/.chef" \
    && mv /knife-chef-config /home/$USER/.chef \
    && chown -R "$USER:$USER" /home/$USER \
    && ln -s $CHEF/lib/plugins /home/$USER/.chef/plugins

USER "$USER"
WORKDIR "/home/$USER"

RUN git clone -c advice.detachedHead=false https://github.com/asdf-vm/asdf.git .asdf --branch v0.8.1
RUN cd workspace/chef \
    && "/home/$USER/.asdf/bin/asdf" plugin-add ruby \
    && "/home/$USER/.asdf/bin/asdf" install ruby \
    && "/home/$USER/.asdf/bin/asdf" global ruby 2.5.5 \
    && "/home/$USER/.asdf/bin/asdf" reshim ruby

# Fixes the "-bash: warning: setlocale: LC_ALL: cannot change locale (en_IN.UTF-8)" warning.
RUN echo ". /home/$USER/.asdf/asdf.sh\n. /home/$USER/.asdf/completions/asdf.bash" >> /home/$USER/.bashrc

ENV PATH="/home/$USER/.asdf/bin:/home/$USER/.asdf/shims:$PATH" \
    LANG=en_US.utf-8 \
    LC_ALL=en_US.utf-8 \
    CHEF="/home/$USER/workspace/chef" \
    USER="$USER"

WORKDIR "$CHEF"

ENTRYPOINT ["knife"]

