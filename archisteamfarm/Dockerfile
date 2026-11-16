ARG BUILD_FROM
FROM $BUILD_FROM

# Official ArchiSteamFarm image (see build.yaml) already ships the ASF
# binaries (/asf, symlinked as /usr/bin/ArchiSteamFarm) with the .NET 11
# runtime. This layer only adds what the add-on bootstrap needs.

# jq for parsing /data/options.json in run.sh (not present upstream)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends jq; \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh

# Replace the upstream ENTRYPOINT (which expects the raw docker layout at
# /app) with the add-on bootstrap script.
ENTRYPOINT ["/run.sh"]
CMD []
