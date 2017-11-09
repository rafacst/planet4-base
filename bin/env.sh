#!/usr/bin/env bash
# shellcheck disable=SC2034
set -ao pipefail

# CONFIG FILE
# Read parameters from key->value configuration files
# Note this will override environment variables at this stage
# @todo prioritise ENV over config file ?

# Find real file path of current script
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
source="${BASH_SOURCE[0]}"
while [[ -h "$source" ]]
do # resolve $source until the file is no longer a symlink
 dir="$( cd -P "$( dirname "$source" )" && pwd )"
 source="$(readlink "$source")"
 # if $source was a relative symlink, we need to resolve it relative to the
 # path where the symlink file was located
 [[ $source != /* ]] && source="$dir/$source"
done
current_dir="$( cd -P "$( dirname "$source" )" && pwd )"

DEFAULT_CONFIG_FILE="${current_dir}/../config.default"

if [[ ! -f "${DEFAULT_CONFIG_FILE}" ]]
then
  >&2 echo "Default configuration file not found: ${DEFAULT_CONFIG_FILE}"
fi
# shellcheck source=/dev/null
. ${DEFAULT_CONFIG_FILE}

# Read from custom config file from command line parameter
if [[ "${CONFIG_FILE}" ]]
then
  if [[ ! -f "${CONFIG_FILE}" ]]
  then
    >&2 echo "Custom config file not found: ${CONFIG_FILE}"
  fi

  echo "Reading config from: ${CONFIG_FILE}"

  # https://github.com/koalaman/shellcheck/wiki/SC1090
  # shellcheck source=/dev/null
  . ${CONFIG_FILE}
fi

if [[ -z "${GITHUB_OAUTH_TOKEN}" ]]
then
  >&2 echo "GITHUB_OAUTH_TOKEN environment variable not set"
fi

# Envsubst and cloudbuild.yaml variable consolidation
APPLICATION_NAME=${APPLICATION_NAME:-${DEFAULT_APPLICATION_NAME}}
BRANCH_NAME="${CIRCLE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"
BUILD_ENVIRONMENT="${BUILD_ENVIRONMENT:-${DEFAULT_BUILD_ENVIRONMENT}}"
BUILD_NAMESPACE="${BUILD_NAMESPACE:-${DEFAULT_BUILD_NAMESPACE}}"
BUILD_NUM="${BUILD_NUM:-${CIRCLE_BUILD_NUM:-"local"}}"
FROM_IMAGE="${FROM_IMAGE:-${DEFAULT_FROM_IMAGE}}"
FROM_NAMESPACE="${FROM_NAMESPACE:-${DEFAULT_FROM_NAMESPACE}}"
FROM_TAG="${FROM_TAG:-$(${current_dir}/get_from_tag.sh)}"
GIT_REF="${GIT_REF:-${DEFAULT_GIT_REF}}"
GOOGLE_PROJECT_ID="${GOOGLE_PROJECT_ID:-${DEFAULT_GOOGLE_PROJECT_ID}}"
IMAGE_MAINTAINER="${MAINTAINER:-${DEFAULT_MAINTAINER}}"
