#!/bin/sh

set -euo pipefail

cd "${MATHJAX_HOME}"

mathjax_start_server() {
  echo "Starting up MathJax server."
  echo "The server will fork iteslf as many times as CPUs are installed."
  exec gosu "${MATHJAX_RUN_USER}:${MATHJAX_RUN_GROUP}" \
	"node" "./index.js"
}


case ${1} in
  app:serve)
    mathjax_start_server
    ;;
  *)
    exec "$@"
    ;;
esac


