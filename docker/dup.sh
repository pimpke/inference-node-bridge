#!/bin/bash

POSITIONAL_ARGS=()

SHOULD_CLONE_REPOS=0
SHOULD_BUILD_PROJECTS=0
SHOULD_RUN_OPENPILOT_SIM=0
DEBUG_OPENPILOT_BRIDGE=0
DEBUG_INFERENCE_NODE_BRIDGE=0
SHOULD_EXEC=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --exec)
      SHOULD_EXEC=1
      EXEC_SERVICE_NAME="$2"
      shift
      shift
      ;;
    --clone)
      SHOULD_CLONE_REPOS=1
      shift
      ;;
    --build_projects)
      SHOULD_BUILD_PROJECTS=1
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
REPOS_PATH=${HOME}/repos # TODO: revert to inference-repos
OPENPILOT_PATH=${REPOS_PATH}/openpilot
ASLAN_PATH=${REPOS_PATH}/aslan
OPENPILOT_BRIDGE_PATH=${REPOS_PATH}/openpilot-bridge
INFERENCE_NODE_BRIDGE_PATH=${REPOS_PATH}/inference-node-bridge

SHOULD_BUILD_ASLAN=0
SHOULD_BUILD_OPENPILOT=0

export SHOULD_RUN_OPENPILOT_SIM
export DEBUG_OPENPILOT_BRIDGE
export DEBUG_INFERENCE_NODE_BRIDGE

export OPENPILOT_PATH
export ASLAN_PATH
export OPENPILOT_BRIDGE_PATH
export INFERENCE_NODE_BRIDGE_PATH

export GROUP_ID
export USER_ID

export SHOULD_BUILD_ASLAN
export SHOULD_BUILD_OPENPILOT

if [ ${SHOULD_EXEC} = 1 ]; then
  docker-compose exec -it ${EXEC_SERVICE_NAME} bash
  exit 0
fi

if [ ${SHOULD_CLONE_REPOS} = 1 ]; then
  if [ -d "${REPOS_PATH}" ]; then
    echo "Couldn't execute --clone, the directory ${REPOS_PATH} already exists"
    exit 1
  fi

  mkdir "${REPOS_PATH}"
  git clone git@github.com:pimpke/openpilot.git --recurse-submodules --branch "0.9.1-sim" "${OPENPILOT_PATH}"
  git clone git@github.com:goloskokovic/Aslan.git "${ASLAN_PATH}"
  git clone git@github.com:pimpke/openpilot-bridge.git "${OPENPILOT_BRIDGE_PATH}"
  git clone git@github.com:pimpke/inference-node-bridge.git "${INFERENCE_NODE_BRIDGE_PATH}"
fi

if [ ${SHOULD_BUILD_PROJECTS} = 1 ]; then
  if [ ! -d "${OPENPILOT_BRIDGE_PATH}" ]; then
    echo "Can't build the openpilot project, the directory ${OPENPILOT_BRIDGE_PATH} doesn't exist"
    exit 1
  fi

  SHOULD_BUILD_OPENPILOT=1
  docker-compose rm -f openpilot-client
  docker-compose up openpilot-client
  SHOULD_BUILD_OPENPILOT=0

  if [ ! -d "${ASLAN_PATH}" ]; then
    echo "Can't build the aslan project, the directory ${ASLAN_PATH} doesn't exist"
    exit 1
  fi

  SHOULD_BUILD_ASLAN=1
  docker-compose rm -f aslan
  docker-compose up aslan
  SHOULD_BUILD_ASLAN=0
fi

docker-compose rm -f && docker-compose up
