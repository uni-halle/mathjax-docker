FROM node:10-alpine
LABEL maintainer="O: University of Halle (Saale) Germany; OU: ITZ, department application systems" \
      license="Docker composition: MIT; Components: Please check"

ENV BATIK_VERSION="1.11" \
    MATHJAX_RUN_USER="mathjax" \
    MATHJAX_RUN_GROUP="mathjax" \
    MATHJAX_RUN_UID="800" \
    MATHJAX_RUN_GID="800" \
    MATHJAX_HOME="/opt/mathjax" \
    MATHJAX_PORT="8003" \
    MATHJAX_VERSION="0.5.2" \
    MATHJAX_SERVER_COMMIT="9c55118d90ae798c26949adae3e435e1670436bb" \
    GOSU_VERSION="1.11"

RUN apk add --no-cache \
      gnupg \
      bash openssl curl tini \
      openjdk8 \
    ### Install GoSu
    && set -ex \
    && for key in \
      B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      ; do \
        gpg --batch --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.pgp.com --recv-keys "$key" || \
        gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" ; \
      done \
    && set +x \
    && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    ### Install MathJax
    && mkdir -p "${MATHJAX_HOME}" && cd "${MATHJAX_HOME}" \
    ### use the GitHub links, not the packages from the npm repository
    ### install the release with PNG support
    && npm install "https://github.com/mathjax/MathJax-node/archive/${MATHJAX_VERSION}.tar.gz" \
    && npm install "https://github.com/tiarno/mathjax-server/tarball/${MATHJAX_SERVER_COMMIT}" \
    && cd "${MATHJAX_HOME}/node_modules" && ln -s mathjax-node MathJax-node \
    ### Additionally you need to install Apache Batic, if the MathJax server
    ### should be able to create PNG images. This is needed by ILIAS to support
    ### LaTeX in PDF files
    && cd "${MATHJAX_HOME}/node_modules/mathjax-node/batik" \
    && curl -o batik.tar.gz -L "http://www.apache.org/dyn/closer.cgi?filename=/xmlgraphics/batik/binaries/batik-bin-${BATIK_VERSION}.tar.gz&action=download" \
    && curl -o batik.tar.gz.asc -L "https://www.apache.org/dist/xmlgraphics/batik/binaries/batik-bin-${BATIK_VERSION}.tar.gz.asc" \
    && curl -o /tmp/batik-keys -L "https://www.apache.org/dist/xmlgraphics/batik/KEYS" \
    && gpg --import /tmp/batik-keys && rm /tmp/batik-keys \
    && gpg --batch --verify ./batik.tar.gz.asc ./batik.tar.gz && rm ./batik.tar.gz.asc \
    && tar xf batik.tar.gz && rm batik.tar.gz \
    && ln -s "batik-${BATIK_VERSION}/batik-rasterizer-${BATIK_VERSION}.jar" batik-rasterizer.jar \
    && ln -s "batik-${BATIK_VERSION}/lib" lib \
    && addgroup -S -g "${MATHJAX_RUN_GID}" "${MATHJAX_RUN_GROUP}" \
    && adduser -S -D -H -G "${MATHJAX_RUN_GROUP}" -h "${MATHJAX_HOME}" -u "${MATHJAX_RUN_UID}" "${MATHJAX_RUN_USER}" \
    && apk del gnupg

ADD assets/* "/"

RUN \
    mv /index.js "${MATHJAX_HOME}"

WORKDIR "${MATHJAX_HOME}"

EXPOSE "${MATHJAX_PORT}"

HEALTHCHECK --interval=30s --timeout=15s --start-period=30s CMD "/docker-healthcheck.js"
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["app:serve"]

