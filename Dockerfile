FROM debian:bookworm
RUN apt-get update && \
    apt-get -y install ansible && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]
