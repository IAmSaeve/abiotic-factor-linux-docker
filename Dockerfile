# https://github.com/CM2Walki/steamcmd
# Root image is needed to install extra dependencies.
FROM docker.io/cm2network/steamcmd:root

# Disables a few prompts that could stall image builds.
# https://manpages.debian.org/bullseye/debconf-doc/debconf.7.en.html#noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and run cleanup
RUN apt-get update && \
    apt-get install -yq --install-recommends wine64 && \
    apt-get clean autoclean && \
    apt-get autoremove -yq

# The server runs as the "steam" user from the base image.
# It is therefore required to set correct permissions for the server folder.
RUN mkdir -p /server/AbioticFactor/Saved && chown -R ${USER}:${USER} /server
VOLUME [ "/server/AbioticFactor/Saved" ]
VOLUME [ "/server" ]

# Switch back to the "steam" user.
USER ${USER}

# Setup Wine prefix
ENV WINEDEBUG=-all WINEPREFIX=${HOMEDIR}/.wine WINEARCH=win64
RUN wineboot --init --end-session

# Set up entrypoint
COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]

# Use these for development if the container is crashing.
# CMD ["tail", "-f", "/dev/null"]
# SHELL [ "/bin/bash" ]