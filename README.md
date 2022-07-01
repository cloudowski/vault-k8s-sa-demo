# Vault with Kubernetes secrets

This repo contains resources for testing Vault with dynamic Kubernetes secrets.

## How to generate dynamic service accounts

1. Install vault

   ```
   kustomize build config/vault/ --enable-helm|kubectl apply -f-
   ```

2. Use port forwarding to port 8200 of the vault instance
3. Prepare test environment

   ```
   kubectl create namespace test
   kubectl apply -f sample-rbac.yaml
   ```

4. Configure vault

   ```
   export VAULT_ADDR=http://localhost:8200
   vault login 

   vault secrets enable kubernetes
   vault write -f kubernetes/config
   ```

5. Ask vault to generate a serviceaccount

   ```
   # add special permissions for the vault sa
   kubectl -n test create rolebinding --role test-role-list-pods --serviceaccount=default:vault vault-test-role-abilities

   vault write kubernetes/roles/auto-managed-sa-role \
       allowed_kubernetes_namespaces="test" \
       kubernetes_role_name="test-role-list-pods"

   vault write kubernetes/creds/auto-managed-sa-role \
       kubernetes_namespace=test
   ```

6. Create a kubeconfig file

   ```
   # get serviceaccount and token from the previous command

   ./generate-kubeconfig.sh SA_GENERATED_NAME SA_GENERATED_TOKEN
   ```