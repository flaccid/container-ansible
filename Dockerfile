FROM debian:bookworm
ARG user=ansible
RUN apt-get update && \
    apt-get -y install \
        ansible \
        iputils-ping \
        procps \
        sudo && \
        useradd --system --create-home --shell /bin/bash "$user" && \
        echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER $user
CMD ["/bin/bash"]
