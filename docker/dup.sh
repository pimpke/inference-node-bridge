#!/bin/bash

POSITIONAL_ARGS=()

SHOULD_CLONE_REPOS=0
SHOULD_RUN_OPENPILOT_SIM=0
DEBUG_OPENPILOT_BRIDGE=0
DEBUG_INFERENCE_NODE_BRIDGE=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --clone)
      SHOULD_CLONE_REPOS=1
      shift
      ;;
    --sim)
      SHOULD_RUN_OPENPILOT_SIM=1
      shift
      ;;
    --dbg_openpilot_bridge)
      DEBUG_OPENPILOT_BRIDGE=1
      shift
      ;;
    --dbg_inference_node_bridge)
      DEBUG_INFERENCE_NODE_BRIDGE=1
      shift
      ;;
    --*|-*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

GROUP_ID=$(id -g)
USER_ID=$(id -u)
REPOS_PATH=${HOME}/inference-repos

if [ $SHOULD_CLONE_REPOS = true ]; then
  if [ -d "${REPOS_PATH}" ]; then
    echo "Couldn't execute --clone, the directory ${REPOS_PATH} already exists"
    exit 1
  fi

  mkdir "${REPOS_PATH}"
  git clone git@github.com:pimpke/openpilot.git --branch "0.9.1-sim" "${REPOS_PATH}/openpilot"
  git clone git@github.com:goloskokovic/Aslan.git "${REPOS_PATH}/aslan"
  git clone git@github.com:pimpke/openpilot-bridge.git "${REPOS_PATH}/openpilot-bridge"

  exit 0
fi

export SHOULD_RUN_OPENPILOT_SIM
export DEBUG_OPENPILOT_BRIDGE
export DEBUG_INFERENCE_NODE_BRIDGE
export GROUP_ID
export USER_ID

docker-compose rm && docker-compose up
