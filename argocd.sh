#!/bin/bash

ARGOCD_SERVER="localhost:8080"
ARGOCD_USERNAME="admin"
ARGOCD_PASSWORD="admin"
NEW_ARGOCD_PASSWORD="admin2"
# Define the desired number of replicas for all Deployments
DESIRED_REPLICAS=1

# Attempt to login to ArgoCD
echo "Attempt to login to ArgoCD"
LOGIN_OUTPUT=$(argocd login ${ARGOCD_SERVER} --insecure --username=${ARGOCD_USERNAME} --password=${ARGOCD_PASSWORD} 2>&1)
echo "Check if the login failed due to an invalid username or password"
# Check if the login failed due to an invalid username or password
if echo [[ "${LOGIN_OUTPUT}" == *"rpc error: code = Unauthenticated desc = Invalid username or password"*  ]]; then
    # Update the ArgoCD password
    echo "Update the ArgoCD password"
    kubectl patch secret argocd-secret  -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}' -n argocd

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


    kubectl port-forward svc/argocd-server -n argocd 8080:443 &


    #argocd account update-password --insecure --current-password=${ARGOCD_PASSWORD} --new-password=${NEW_ARGOCD_PASSWORD}
    NEW_ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d )
    echo "Attempt to login with the new password"
    #echo ${NEW_ARGOCD_PASSWORD}
    # Attempt to login with the new password
    LOGIN_OUTPUT=$(argocd login ${ARGOCD_SERVER} --insecure  --username=${ARGOCD_USERNAME} --password=${NEW_ARGOCD_PASSWORD} 2>&1)
    
    echo "Check if the login succeeded with the new password"
    # Check if the login succeeded with the new password
   # if [ $? -eq 0 ]; then
    if echo [[ "${LOGIN_OUTPUT}" == *"logged in successfully"*  ]]; then
        echo "Login succeeded with the new password."
    else
        echo "Login failed with the new password. Error message:"
        echo "${LOGIN_OUTPUT}"
    fi
else
    echo "Login succeeded with the existing password."
fi

argocd app create jsonnet-guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path jsonnet-guestbook --dest-namespace default --dest-server https://kubernetes.default.svc

#echo ${NEW_ARGOCD_PASSWORD}