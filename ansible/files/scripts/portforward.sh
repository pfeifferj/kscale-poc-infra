#!/bin/bash

# usage: ./start_port_forward.sh <kubeconfig_path> <port>

KUBECONFIG_PATH=$1
PORT=$2

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION="us-east-1"

MAX_RETRIES=10
RETRY_DELAY=30

attempt_port_forward() {
  local attempt=1
  until KUBECONFIG=$KUBECONFIG_PATH kubectl port-forward svc/prometheus-operator-kube-p-prometheus -n monitoring ${PORT}:9090; do
    if (( attempt >= MAX_RETRIES )); then
      echo "failed to start port-forwarding after $MAX_RETRIES attempts"
      return 1
    fi
    echo "port-forward failed, retrying in ${RETRY_DELAY}s... (attempt $((attempt + 1))/$MAX_RETRIES)"
    ((attempt++))
    sleep $RETRY_DELAY
  done
  echo "port-forwarding started successfully"
}

attempt_port_forward 
