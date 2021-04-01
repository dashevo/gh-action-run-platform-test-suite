#!/bin/bash

set -eax

cmd_usage="Run platform-test-suite

Usage: run-platform-test-suite <seed> [options]
  <seed> can be IP or IP:port

  Options:
  --branch                    - branch to run
  --scope                     - test scope to run
  --network                   - network
  --npm-install
  --faucet-key
  --dpns-contract-id
  --dpns-tld-identity-id
  --dpns-tld-identity-private-key
"

DAPI_SEED="$1"

if [ -z "$DAPI_SEED" ] || [[ $DAPI_SEED == -* ]]
then
  echo "Seed is not specified"
  echo ""
  echo "$cmd_usage"
  exit 1
fi

for i in "$@"
do
case ${i} in
    -h|--help)
        echo "$cmd_usage"
        exit 0
    ;;
    --branch=*)
    branch="${i#*=}"
    ;;
    --scope=*)
    scope="${i#*=}"
    ;;
    --network=*)
    network="${i#*=}"
    ;;
    --npm-install=*)
    npm_install="${i#*=}"
    ;;
    --faucet-key=*)
    faucet_key="${i#*=}"
    ;;
    --dpns-contract-id=*)
    dpns_contract_id="${i#*=}"
    ;;
    --dpns-tld-identity-id=*)
    dpns_tld_identity_id="${i#*=}"
    ;;
    --dpns-tld-identity-private-key=*)
    dpns_tld_identity_private_key="${i#*=}"
    ;;
esac
done

# Ensure $TMPDIR
if [ -z "$TMPDIR" ]; then
  TMPDIR="/tmp"
fi

# Ensure $branch
if [ -z "$branch" ]; then
  branch="master"
fi

echo "Installing Platform Test Suite from branch ${branch}"

git clone --depth 1 --branch $branch https://github.com/dashevo/platform-test-suite.git "$TMPDIR/platform-test-suite"

cd "$TMPDIR"/platform-test-suite

npm ci

cmd="/bin/bash bin/test.sh ${DAPI_SEED}"

if [ -n "$scope" ]
then
  cmd="${cmd} --scope=${scope}"
fi

if [ -n "$network" ]
then
  cmd="${cmd} --network=${network}"
fi

if [ -n "${npm_install}" ]
then
  cmd="${cmd} --npm-install=${npm_install}"
fi

if [ -n "${faucet_key}" ]
then
  cmd="${cmd} --faucet-key=${faucet_key}"
fi

if [ -n "${dpns_contract_id}" ]
then
  cmd="${cmd} --dpns-contract-id=${dpns_contract_id}"
fi

if [ -n "${dpns_tld_identity_id}" ]
then
  cmd="${cmd} --dpns-tld-identity-id=${dpns_tld_identity_id}"
fi

if [ -n "${dpns_tld_identity_private_key}" ]
then
  cmd="${cmd} --dpns-tld-identity-private-key=${dpns_tld_identity_private_key}"
fi

eval $cmd
