# Deployment Order and CRD Requirements

## Important: KeptnConfig CRD Installation

When deploying this project to a new cluster, ensure the following order to avoid errors with KeptnConfig resources:

1. **Install Keptn CRDs first**
   - The KeptnConfig CRD (`keptnconfigs.options.keptn.sh`) must be present before any KeptnConfig resources are applied.
   - If using FluxCD, create a separate kustomization for CRDs and apply it before other resources.
   - Alternatively, use the `dependsOn` field in your kustomization.yaml to enforce this order.

2. **Apply KeptnConfig and other resources after CRDs**
   - Once CRDs are installed, you can safely apply KeptnConfig and related manifests.

## Example: FluxCD `dependsOn`

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - keptn-crds.yaml
  - keptn-config.yaml
  # ...other resources...
dependsOn:
  - name: keptn-crds
```

## Why?
If KeptnConfig is applied before the CRD exists, FluxCD will report an error and the resource will not be created until the CRD is present.

## Best Practice
- Always check CRD presence before applying dependent resources.
- Document this order in your deployment guides.
- Use FluxCD `dependsOn` for reliable automation.

---

For more details, see the main README and troubleshooting section.