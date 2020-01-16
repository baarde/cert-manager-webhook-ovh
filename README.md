# OVH Webhook for Cert Manager

This is a webhook solver for [OVH](http://www.ovh.com).

## Prerequisites

* [cert-manager](https://github.com/jetstack/cert-manager) version 0.11.0 or higher (*tested with 0.12.0*):
  - [Installing on Kubernetes](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm)

## Installation

Choose a unique group name to identify your company or organization (for example `acme.mycompany.example`).

```bash
helm install ./deploy/cert-manager-webhook-ovh \
 --set groupName='<YOUR_UNIQUE_GROUP_NAME>'
```

If you customized the installation of cert-manager, you may need to also set the `certManager.namespace` and `certManager.serviceAccountName` values.

## Issuer

1. [Create a new OVH API key](https://docs.ovh.com/gb/en/customer/first-steps-with-ovh-api/) with the following rights:
    * `GET /domain/zone/*`
    * `PUT /domain/zone/*`
    * `POST /domain/zone/*`
    * `DELETE /domain/zone/*`

2. Create a secret to store your application secret:

    ```bash
    kubectl create secret generic ovh-credentials \
      --from-literal=applicationSecret='<OVH_APPLICATION_SECRET>'
    ```

3. Grant permission to get the secret to the `cert-manager-webhook-ovh` service account:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: cert-manager-webhook-ovh:secret-reader
    rules:
    - apiGroups: [""]
      resources: ["secrets"]
      resourceNames: ["ovh-credentials"]
      verbs: ["get", "watch"]
    ---
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata:
      name: cert-manager-webhook-ovh:secret-reader
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: cert-manager-webhook-ovh:secret-reader
    subjects:
    - apiGroup: ""
      kind: ServiceAccount
      name: cert-manager-webhook-ovh
    ```

4. Create a certificate issuer:

    ```yaml
    apiVersion: certmanager.k8s.io/v1alpha1
    kind: Issuer
    metadata:
      name: letsencrypt
    spec:
      acme:
        server: https://acme-v02.api.letsencrypt.org/directory
        email: '<YOUR_EMAIL_ADDRESS>'
        privateKeySecretRef:
          name: letsencrypt-account-key
        solvers:
        - dns01:
            webhook:
              groupName: '<YOUR_UNIQUE_GROUP_NAME>'
              solverName: ovh
              config:
                endpoint: ovh-eu
                applicationKey: '<OVH_APPLICATION_KEY>'
                applicationSecretRef:
                  key: applicationSecret
                  name: ovh-credentials
                consumerKey: '<OVH_CONSUMER_KEY>'
    ```

## Certificate

Issue a certificate:

```yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: example-com
spec:
  dnsNames:
  - example.com
  - *.example.com
  issuerRef:
    name: letsencrypt
  secretName: example-com-tls
```

## Development

All DNS providers **must** run the DNS01 provider conformance testing suite,
else they will have undetermined behaviour when used with cert-manager.

**It is essential that you configure and run the test suite when creating a
DNS01 webhook.**

An example Go test file has been provided in [main_test.go]().

Before you can run the test suite, you need to download the test binaries:

```bash
./scripts/fetch-test-binaries.sh
```

Then duplicate the `.sample` files in `testdata/ovh/` and update the configuration with the appropriate OVH credentials.

Now you can run the test suite with:

```bash
TEST_ZONE_NAME=example.com. go test .
```
