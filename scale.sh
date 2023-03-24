

# Scale down the argocd-server Deployment
kubectl -n argocd scale deployments.apps argocd-server --replicas 0

# Wait for the argocd-server Deployment to be fully scaled down
while kubectl -n argocd get deployments.apps argocd-server -o=jsonpath='{.status.availableReplicas}' | grep -q '[^0-9]0[^0-9]'; do
  echo "Waiting for argocd-server Deployment to scale down..."
  sleep 5
done

# Scale up the argocd-server Deployment
kubectl -n argocd scale deployments.apps argocd-server --replicas 1

# Wait for the argocd-server Deployment to become ready
while ! kubectl -n argocd get deployments.apps argocd-server -o=jsonpath='{.status.conditions[?(@.type=="Available")].status}' | grep -q True; do
  echo "Waiting for argocd-server Deployment to become ready..."
  sleep 5
done

echo "argocd-server Deployment is ready."