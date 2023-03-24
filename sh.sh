#!/bin/bash

ARGOCD_SERVER="localhost:8080"
ARGOCD_USERNAME="admin"
ARGOCD_PASSWORD="admin"
NEW_ARGOCD_PASSWORD="admin"

echo "Attempt to login to ArgoCD"
argocd login ${ARGOCD_SERVER} --username=${ARGOCD_USERNAME} --password=${ARGOCD_PASSWORD}

echo "If the login failed, update the ArgoCD password and try again"
if [ $? -ne 0 ]; then
    echo "update the ArgoCD password and try again"
    argocd account update-password --current-password=${ARGOCD_PASSWORD} --new-password=${NEW_ARGOCD_PASSWORD}
    argocd login ${ARGOCD_SERVER} --username=${ARGOCD_USERNAME} --password=${NEW_ARGOCD_PASSWORD}
fi
