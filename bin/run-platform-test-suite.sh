#!/bin/bash

set -eax

cmd_usage="Run platform-test-suite

Usage: run-platform-test-suite <branch> [options]
  <branch> branch to run

  Options:
  --scope                     - test scope to run
  --network                   - network
  --npm-install
  --faucet-key
  --dpns-contract-id
  --dpns-tld-identity-id
  --dpns-tld-identity-private-key
"

branch="$1"

if [ -z "$branch" ]
then
  echo "Branch is not specified"
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
    --scope=*)
    scope="${i#*=}"
    ;;
    --network=*)
    network="${i#*=}"
    ;;
    --npm-install=*)
    npm-install="${i#*=}"
    ;;
    --faucet-key=*)
    faucet-key="${i#*=}"
    ;;
    --dpns-contract-id=*)
    dpns-contract-id="${i#*=}"
    ;;
    --dpns-tld-identity-id=*)
    dpns-tld-identity-id="${i#*=}"
    ;;
    --dpns-tld-identity-private-key=*)
    dpns-tld-identity-private-key="${i#*=}"
    ;;
esac
done

# Ensure $TMPDIR
if [ -z "$TMPDIR" ]; then
  TMPDIR="/tmp"
fi

echo "Installing Platform Test Suite from branch ${branch}"

git clone --depth 1 --branch $branch https://github.com/dashevo/platform-test-suite.git "$TMPDIR/platform-test-suite"

cd "$TMPDIR"/mn-bootstrap

npm ci

cmd="/bin/bash bin/test.sh"

if [ -n "$scope" ]
then
  cmd="${cmd} --scope=${scope}"
fi

if [ -n "$network" ]
then
  cmd="${cmd} --network=${network}"
fi

if [ -n "${npm-install}" ]
then
  cmd="${cmd} --npm-install=${npm-install}"
fi

if [ -n "${faucet-key}" ]
then
  cmd="${cmd} --faucet-key=${faucet-key}"
fi

if [ -n "${dpns-contract-id}" ]
then
  cmd="${cmd} --dpns-contract-id=${dpns-contract-id}"
fi

if [ -n "${dpns-tld-identity-id}" ]
then
  cmd="${cmd} --dpns-tld-identity-id=${dpns-tld-identity-id}"
fi

if [ -n "${dpns-tld-identity-private-key}" ]
then
  cmd="${cmd} --dpns-tld-identity-private-key=${dpns-tld-identity-private-key}"
fi

eval $cmd


