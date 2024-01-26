# DX Network policies
Helm Chart to create DX network policies required to run DX. This is a standard Helm chart to create NetworkPolicy objects in a namespace. As we have to install that in every namepspace we can't do that cross namespace automatically

**Note**: As we have currently a different setting between test- and prod environment we need to align that so that we have the same NetworkPolicy objects in place. As of writing this document we had the situation that on *ocptest* no NetworkPolicy objects were in place while on `ocpext` we had a set of default NetworkPolicy objects created at creation of the namespace.

>[!IMPORTANT]
>Delete **all** NetworkPolicies (except the default ones or those from other sources) before installing the Helm Chart. It is highly recommended to have only once source for the NetworkPolicy objects (otherwise maintenance will be very hard).

## Values files
Inside of `charts/dx-network-policy` we have a folder `values` with the prepared values files per environment. The following values files are currently prepared:
- *epyc_<ns>_</ns>values.yaml*: Values for the epyc test cluster.
- *ocptest_<ns>_values.yaml*: Values for the **epyc** test cluster. In this values file we are creating the NetworkPolicy objects which exist in the PROD cluster as well via the Helm chart. I.e  `deployProdDefaults=true` is set.
- *ocpext_<ns>_values.yaml*: Values for the **ocpext** test cluster. In this values file we are creating the NetworkPolicy objects which exist in the PROD cluster as well via the Helm chart. I.e  `deployProdDefaults=true` is set.
    **Note**: As on this cluster default NetworkPolicy objects exist the setting `deployProdDefaults=false` is set.

## Templating
To test the Helm chart and the values files you can run:

```sh
cd charts/dx-network-policy
helm template . -f .<path-to-values.yaml> --debug 2>&1 | tee /dev/shm/hhue.log
```

or you can use a dry-run. The following example mimics the installation of the chart using the release name *dx-network-policies*

```sh
cd charts/dx-network-policy
helm -n <ns> install --debug <release-name> . -f <path-to-values.yaml>  --dry-run=client 2>&1 | tee /dev/shm/hhue.log
```

for example:
```sh
cd charts/dx-network-policy
helm -n dxb install --debug dx-network-policies . -f values/epyc_dxb_values.yaml --dry-run | tee /dev/shm/hhue.log
```

## Installation
To install the Helm chart run the following command:
**Note**: The Helm release name in that case is `dx-network-policies`
```sh
cd charts/dx-network-policy
helm upgrade --install <release-name> . -f <path-to-values.yaml>
```

for example:
```sh
cd charts/dx-network-policy
helm -n dxb upgrade --install dx-network-policies . -f values/epyc_dxb_values.yaml --debug
helm -n dxg upgrade --install dx-network-policies . -f values/epyc_dxg_values.yaml --debug
```

### Verifying installation and checking installation history
To verify the installation and the installation history you can run the following commands:

```sh
helm -n <ns> list
helm -n dxb history dx-network-policies
```


for example:
```sh
helm -n dxb list
helm -n <ns> history <release-name>
```

## Uninstallation
As this is a standard Helm chart you can uninstall the NetworkPolicy manifests by running:

```sh
helm -n <ns> uninstall <release-name>
```

for example:
```sh
helm -n dxb uninstall dx-network-policies
helm -n dxg uninstall dx-network-policies
```
