#!/bin/bash
set -euo pipefail

# === CONFIG ===
IMAGE_NAME=databricks-pipeline
ACR_NAME=cicdpocregistry
# Make sure these match your real resource group / cluster names:
AKS_RG=dev-rg
AKS_CLUSTER=myAKSCluster
SUBSCRIPTION="eaa68753-8b1b-4403-a138-e297bf248bf4"  # optional: ensure correct subscription

FULL_IMAGE="$ACR_NAME.azurecr.io/$IMAGE_NAME:latest"

# === FUNCTIONS ===
log() { echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }

# === START ===
log "Setting subscription to ${SUBSCRIPTION} (if provided)..."
if [[ -n "${SUBSCRIPTION:-}" ]]; then
  az account set --subscription "$SUBSCRIPTION"
fi

log "Logging into Azure (managed identity fallback to interactive)..."
if ! az account show &>/dev/null; then
  az login || true
fi

log "Registering ContainerRegistry provider if needed..."
az provider register --namespace Microsoft.ContainerRegistry --wait

log "ACR login (will fail if Docker daemon is absent)..."
if az acr login --name "$ACR_NAME" 2>&1 | tee /dev/stderr | grep -q "error during connect"; then
  log "Docker not reachable locally; falling back to remote build via ACR."
  # Use ACR Tasks to build and push without local Docker
  az acr build --registry "$ACR_NAME" --image "$IMAGE_NAME:latest" .
else
  log "Building Docker image locally..."
  docker build -t "$IMAGE_NAME:latest" .

  log "Tagging image for ACR..."
  docker tag "$IMAGE_NAME:latest" "$FULL_IMAGE"

  log "Pushing image to ACR..."
  docker push "$FULL_IMAGE"
fi

log "Ensuring AKS has pull permission (assumes system-assigned identity)..."
ACR_ID=$(az acr show --name "$ACR_NAME" --query id -o tsv)
AKS_PRINCIPAL_ID=$(az aks show --resource-group "$AKS_RG" --name "$AKS_CLUSTER" --query "identity.principalId" -o tsv)
az role assignment create \
  --assignee "$AKS_PRINCIPAL_ID" \
  --role AcrPull \
  --scope "$ACR_ID" || log "Role assignment may already exist."

log "Fetching AKS credentials..."
az aks get-credentials --resource-group "$AKS_RG" --name "$AKS_CLUSTER" --overwrite-existing

log "Updating Kubernetes manifests to use the image: $FULL_IMAGE"
# Optionally patch deployment to ensure the image reference is correct before apply.
# Example: kubectl set image deployment/<your-deploy> <container-name>="$FULL_IMAGE"

log "Deploying to AKS..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

log "✅ Deployment Complete!"
