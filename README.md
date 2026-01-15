<table style="border-collapse: collapse; border: none;">
  <tr style="border-collapse: collapse; border: none;">
    <td style="border-collapse: collapse; border: none;">
      <a href="http://www.openairinterface.org/">
         <img src="https://gitlab.eurecom.fr/uploads/-/system/user/avatar/716/avatar.png?width=800" alt="" border=3 height=50 width=50>
         </img>
      </a>
    </td>
    <td style="border-collapse: collapse; border: none; vertical-align: center;">
      <b><font size = "5">keptn-deploy</font></b>
    </td>
  </tr>
</table>

# Author
**Luis Felipe Ariza Vesga** 
emails: lfarizav@gmail.com, lfarizav@unal.edu.co
# keptn-deploy

> **Tenant Repository for Keptn Lifecycle Orchestration**

This repository contains the Helm charts and Flux CD configurations for deploying Keptn on Kubernetes to provide cloud-native application lifecycle orchestration and observability.

[![Flux](https://img.shields.io/badge/Flux-Managed-blue)](https://fluxcd.io/)
[![Keptn](https://img.shields.io/badge/Keptn-Lifecycle-orange)](https://keptn.sh/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27+-blue)](https://kubernetes.io/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Features](#features)
- [Integration](#integration)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This tenant repository is managed by the **k8s-open5gs-fleet** GitOps fleet and deploys:

- **Keptn Lifecycle Toolkit**: Observability and lifecycle orchestration
- **OpenTelemetry**: Metrics and traces collection
- **Cert-Manager**: Certificate management (dependency)

### Key Features

- ✅ **GitOps deployment** via Flux CD
- ✅ **Application lifecycle orchestration**
- ✅ **Pre/post deployment tasks** automation
- ✅ **SLO-based quality gates**
- ✅ **OpenTelemetry integration**
- ✅ **Prometheus metrics** collection
- ✅ **Slack notifications** for deployment events

### What is Keptn?

Keptn is a cloud-native application lifecycle orchestration tool that:

- **Tracks deployments** with workload and application contexts
- **Measures performance** using SLIs (Service Level Indicators)
- **Enforces quality gates** based on SLOs (Service Level Objectives)
- **Provides observability** through OpenTelemetry traces and metrics
- **Automates tasks** before and after deployments

---

## 📁 Repository Structure

```
keptn-deploy/
├── flux/
│   ├── base/                           # Base Flux configurations
│   │   ├── kustomization.yaml          # Aggregates all resources
│   │   ├── keptn-gitrepository.yaml    # Git source definition
│   │   ├── keptn-helmrelease.yaml      # Helm release config
│   │   ├── keptn-alert.yaml            # GitHub webhook alert
│   │   └── slack-notif-alert.yaml      # Slack notifications
│   │
│   └── dev/                            # Development environment
│       └── kustomization.yaml          # Dev-specific overlays
│
├── helm/
│   └── charts/
│       └── keptn/                      # Main Helm chart
│           ├── Chart.yaml              # Chart metadata
│           ├── Chart.lock              # Dependencies lock
│           ├── values.yaml             # Default values
│           ├── templates/              # K8s manifests
│           │   ├── keptn-ns.yaml       # Namespace (if needed)
│           │   ├── _helpers.tpl        # Template helpers
│           │   └── _keptnconfig.yaml   # Keptn configuration
│           └── charts/                 # Sub-charts
│               ├── keptn-lifecycle-operator/
│               ├── keptn-metrics-operator/
│               └── keptn-cert-manager/
│
├── README.md                           # This file
└── LICENSE
```

---

## 🏗️ Architecture

### Keptn Components

```
┌─────────────────────────────────────────────────────────┐
│                     keptn-system                        │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐       │
│  │ Lifecycle        │      │ Metrics          │       │
│  │ Operator         │◄────►│ Operator         │       │
│  └────────┬─────────┘      └────────┬─────────┘       │
│           │                         │                  │
│           ▼                         ▼                  │
│  ┌──────────────────┐      ┌──────────────────┐       │
│  │ KeptnApp         │      │ KeptnMetric      │       │
│  │ KeptnWorkload    │      │ Analysis         │       │
│  │ KeptnTask        │      │                  │       │
│  └──────────────────┘      └──────────────────┘       │
│           │                         │                  │
│           └─────────┬───────────────┘                  │
│                     ▼                                  │
│           ┌──────────────────┐                         │
│           │ OpenTelemetry    │                         │
│           │ Collector        │                         │
│           └────────┬─────────┘                         │
└────────────────────┼────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────┐
          │   Prometheus     │
          │   (monitoring)   │
          └──────────────────┘
```

### Deployment Lifecycle with Keptn

```
1. Deployment starts
   │
   ├─► Pre-deployment tasks (KeptnTask)
   │   ├─ Load tests
   │   ├─ Database migrations
   │   └─ Configuration validation
   │
2. Application deploys
   │
   ├─► Post-deployment tasks (KeptnTask)
   │   ├─ Smoke tests
   │   ├─ Cache warming
   │   └─ Health checks
   │
3. Evaluation phase (KeptnEvaluation)
   │
   ├─► Check SLOs
   │   ├─ Response time < 500ms
   │   ├─ Error rate < 1%
   │   └─ Availability > 99.9%
   │
4. Result
   ├─► Pass ✓ - Deployment successful
   └─► Fail ✗ - Rollback triggered
```

---

## 🔧 Prerequisites

### Fleet Repository Setup

This tenant is managed by the fleet repository. Ensure:

1. **Fleet repo** is bootstrapped: [k8s-open5gs-fleet](https://github.com/Cuemby/k8s-open5gs-fleet)
2. **Namespace** `keptn-system` exists
3. **RBAC** is configured
4. **GitRepository** resource points to this repo
5. **Monitoring** stack deployed (dependency)

### Required Resources

- Kubernetes cluster (v1.27+)
- Flux CD installed and running
- Prometheus (for metrics collection)
- Grafana (for visualization)
- Cert-Manager (for webhooks)

---

## 🚀 Deployment

### Option 1: Initial Chart Setup (First Time)

If you're setting up this repository for the first time, download and customize the official Keptn Helm chart:

<details>
<summary><b>📦 Download Official Helm Chart</b></summary>

#### Step 1: Add Keptn Helm Repository

```bash
# Add the official Keptn Helm repository
helm repo add keptn https://charts.lifecycle.keptn.sh
helm repo update
```

#### Step 2: Download the Chart

```bash
# Create helm/charts directory if it doesn't exist
mkdir -p helm/charts

# Pull the chart (replace X.Y.Z with desired version)
helm pull keptn/keptn-lifecycle-operator \
  --version 0.8.3 \
  --untar \
  --untardir helm/charts

# Rename to keptn for consistency
mv helm/charts/keptn-lifecycle-operator helm/charts/keptn
```

#### Step 3: Customize values.yaml

Edit `helm/charts/keptn/values.yaml` to match your environment:

```yaml
# helm/charts/keptn/values.yaml

# Lifecycle Operator Configuration
lifecycleOperator:
  enabled: true
  replicas: 1
  
  # OpenTelemetry Configuration
  env:
    otelCollectorUrl: "otel-collector.keptn-system.svc.cluster.local:4317"
    keptnAppControllerLogLevel: "0"
    keptnAppCreationRequestControllerLogLevel: "0"
    
  # Resource limits
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

# Metrics Operator Configuration
metricsOperator:
  enabled: true
  replicas: 1
  
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi

# Cert-Manager Integration (required for webhooks)
certManager:
  enabled: true
  
# Prometheus Integration
prometheus:
  enabled: true
  
# Global settings
global:
  imageRegistry: ""
  imagePullSecrets: []

# Enable metrics collection
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

#### Step 4: Update Chart Dependencies

```bash
cd helm/charts/keptn

# Update dependencies
helm dependency update

# Verify dependencies
helm dependency list
```

#### Step 5: Validate the Chart

```bash
# Lint the chart
helm lint helm/charts/keptn

# Dry-run installation
helm install keptn ./helm/charts/keptn \
  --namespace keptn-system \
  --create-namespace \
  --dry-run --debug
```

#### Step 6: Commit to Repository

```bash
git add helm/charts/keptn/
git commit -m "feat: add keptn helm chart with custom values"
git push origin main
```

</details>

### Option 2: Automatic Deployment (GitOps)

This repository is **automatically deployed** by Flux CD when:

1. Changes are pushed to the `main` branch
2. Flux reconciles (every 5 minutes)
3. Monitoring stack is healthy (dependency)

**No manual intervention required!**

### Option 3: Manual Deployment (Development)

For local testing:

```bash
# Install Helm chart directly
helm install keptn ./helm/charts/keptn \
  --namespace keptn-system \
  --create-namespace \
  --values ./helm/charts/keptn/values.yaml
```

### Verify Deployment

```bash
# Check HelmRelease status
flux get helmreleases -n keptn-system

# View all pods
kubectl get pods -n keptn-system

# Check Keptn operators
kubectl get deploy -n keptn-system

# View CRDs
kubectl get crds | grep keptn
```

Expected CRDs:
- `keptnapps.lifecycle.keptn.sh`
- `keptnworkloads.lifecycle.keptn.sh`
- `keptntasks.lifecycle.keptn.sh`
- `keptnevaluations.lifecycle.keptn.sh`
- `keptnmetrics.metrics.keptn.sh`

---

## ⚙️ Configuration

### Helm Values

Edit `helm/charts/keptn/values.yaml`:

```yaml
# Example configuration
lifecycleOperator:
  enabled: true
  replicas: 1
  env:
    otelCollectorUrl: "otel-collector:4317"

metricsOperator:
  enabled: true
  replicas: 1

certManager:
  enabled: true  # Required for webhooks

schedulingGatesEnabled: true  # Enable pre-deployment tasks

prometheus:
  enabled: true
  url: "http://prom-kube-prometheus-stack-prometheus.monitoring:9090"
```

### Environment-Specific Configuration

Use Flux overlays in `flux/dev/`:

```yaml
# flux/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
```

### HelmRelease Configuration

The HelmRelease is configured for resilience:

```yaml
spec:
  interval: 10m0s
  timeout: 10m0s
  install:
    remediation:
      retries: 3
    crds: CreateReplace
  upgrade:
    remediation:
      retries: 3
      remediateLastFailure: true
    cleanupOnFail: true
  driftDetection:
    mode: enabled
```

---

## 🎯 Features

### 1. Application Lifecycle Tracking

Enable Keptn for your application:

```yaml
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnApp
metadata:
  name: my-app
  namespace: default
spec:
  version: "1.0.0"
  workloads:
    - name: frontend
      version: "1.0.0"
    - name: backend
      version: "1.0.0"
```

### 2. Pre/Post Deployment Tasks

Define custom tasks:

```yaml
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnTaskDefinition
metadata:
  name: smoke-test
spec:
  function:
    inline:
      code: |
        let text = Deno.env.get("DATA");
        console.log("Running smoke tests...");
        console.log(text);
```

Use in workload:

```yaml
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnWorkload
metadata:
  name: frontend
spec:
  version: "1.0.0"
  app: my-app
  preDeploymentTasks:
    - database-migration
  postDeploymentTasks:
    - smoke-test
    - cache-warm
```

### 3. SLO-Based Evaluations

Define service level objectives:

```yaml
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnEvaluationDefinition
metadata:
  name: app-evaluation
spec:
  objectives:
    - keptnMetricRef:
        name: response-time
        namespace: default
      evaluationTarget: "<500"
    - keptnMetricRef:
        name: error-rate
        namespace: default
      evaluationTarget: "<1"
```

### 4. Custom Metrics

Collect metrics from Prometheus:

```yaml
apiVersion: metrics.keptn.sh/v1beta1
kind: KeptnMetric
metadata:
  name: response-time
spec:
  provider:
    name: prometheus
  query: "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))"
  fetchIntervalSeconds: 30
```

---

## 🔗 Integration

### Integrate with Your Application

Add annotation to enable Keptn:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  annotations:
    keptn.sh/app: "my-app"
    keptn.sh/workload: "frontend"
    keptn.sh/version: "1.0.0"
spec:
  template:
    metadata:
      annotations:
        keptn.sh/app: "my-app"
        keptn.sh/workload: "frontend"
        keptn.sh/version: "1.0.0"
```

### Connect to Prometheus

Keptn automatically discovers Prometheus if configured:

```yaml
# In values.yaml
prometheus:
  enabled: true
  url: "http://prometheus-server.monitoring:9090"
```

### OpenTelemetry Integration

Keptn creates traces for each deployment:

```bash
# View traces in Jaeger or your tracing backend
kubectl port-forward -n keptn-system svc/jaeger-query 16686:16686
```

---

## 📊 Monitoring

### View Deployment Status

```bash
# List all KeptnApps
kubectl get keptnapps -A

# Get workload instances
kubectl get keptnworkloadinstance -A

# View evaluation results
kubectl get keptnevaluations -A

# Check task executions
kubectl get keptntaskexecution -A
```

### Prometheus Metrics

Keptn exposes metrics:

- `keptn_app_count`
- `keptn_deployment_count`
- `keptn_deployment_duration_seconds`
- `keptn_task_duration_seconds`
- `keptn_evaluation_result`

### Grafana Dashboards

Access pre-built dashboards:

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/prom-grafana 3000:80
```

Look for **Keptn** dashboards showing:
- Deployment frequency
- Task success rates
- Evaluation pass/fail ratios
- Application health

---

## 🔍 Troubleshooting

### Keptn Operators Not Running

```bash
# Check operator pods
kubectl get pods -n keptn-system

# View operator logs
kubectl logs -n keptn-system -l app.kubernetes.io/name=lifecycle-operator
kubectl logs -n keptn-system -l app.kubernetes.io/name=metrics-operator

# Check webhook configuration
kubectl get validatingwebhookconfigurations | grep keptn
kubectl get mutatingwebhookconfigurations | grep keptn
```

### Workload Not Tracked

```bash
# Verify annotation on deployment
kubectl get deployment <name> -o yaml | grep keptn

# Check KeptnWorkload created
kubectl get keptnworkload -A

# View workload instance
kubectl get keptnworkloadinstance -A

# Describe for events
kubectl describe keptnworkloadinstance <name>
```

### Tasks Failing

```bash
# List task executions
kubectl get keptntaskexecution -A

# Describe failed task
kubectl describe keptntaskexecution <name>

# View task logs
kubectl logs -n <namespace> <task-pod-name>

# Check task definition
kubectl get keptntaskdefinition -A
```

### Metrics Not Available

```bash
# Check KeptnMetric resources
kubectl get keptnmetric -A

# Describe metric
kubectl describe keptnmetric <name>

# Verify Prometheus connection
kubectl get keptnmetricsprovider -A

# Test Prometheus query
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl "http://prometheus-server.monitoring:9090/api/v1/query?query=up"
```

**⚠️ Grafana Dashboards Showing "No Data"**

If Keptn dashboards show "No data" despite Keptn being deployed:

1. **Verify metrics exist at source:**
   ```bash
   kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n keptn-system -- \
     curl -s http://lifecycle-operator-metrics-service:2222/metrics | grep '^keptn' | head -20
   ```

2. **Check if Prometheus is scraping:**
   ```bash
   kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n monitoring -- \
     curl -s "http://prom-kube-prometheus-stack-prometheus:9090/api/v1/query?query=keptn_deployment_deploymentduration"
   ```

3. **If metrics exist but aren't in Prometheus, restart Prometheus:**
   ```bash
   kubectl delete pod -n monitoring prometheus-prom-kube-prometheus-stack-prometheus-0
   ```
   
   Wait ~30 seconds for Prometheus to restart and re-discover ServiceMonitors.

4. **Verify ServiceMonitors have correct labels:**
   ```bash
   kubectl get servicemonitor -n keptn-system -o yaml | grep "release: prom"
   ```

See [KEPTN_METRICS_TROUBLESHOOTING.md](./KEPTN_METRICS_TROUBLESHOOTING.md) for detailed investigation steps.

### Common Issues

| Issue | Solution |
|-------|----------|
| CRDs not installed | Ensure `crds: CreateReplace` in HelmRelease |
| Webhooks failing | Check cert-manager is running |
| Annotations not working | Verify exact format: `keptn.sh/app`, `keptn.sh/workload`, `keptn.sh/version` |
| Metrics query errors | Check Prometheus URL and network connectivity |
| Tasks timeout | Increase timeout in KeptnTaskDefinition |

---

## 🔄 Recent Updates & Improvements

### November 2025
**🎯 Grafana Dashboard Quality Improvements**

All Keptn Grafana dashboards have been fixed to eliminate duplicate metrics and improve user experience:

#### Keptn Overview Dashboard
- ✅ Added `legendFormat` to 6 stat panels for clean display
  - Total Applications, Active Apps, Active Deployments, Active Workloads, Succeeded, Failed
- ✅ All metrics now show user-friendly labels instead of raw Prometheus queries

#### Keptn Applications Dashboard
- ✅ Added `legendFormat` to 4 stat/gauge panels
  - Succeeded, Active Deployments, Failed, Avg Time Between Deployments
- ✅ Fixed "Active Workloads" table showing duplicate rows
  - Changed from raw metric to `max() by (workload_name, version)` aggregation
  - Added endpoint/container to excludeByName transformation
- ✅ Clean single-row entries per workload

#### Keptn Workloads DORA Dashboard
- ✅ Added `legendFormat` to 4 stat panels
  - Total Active Workloads, Active Deployments, Succeeded, Failed
- ✅ Fixed "Workload Deployment Status" table duplicates
  - Aggregated with `max() by (workload_name, version)`
  - Excluded infrastructure labels (pod, instance, endpoint, job, service, namespace, container)
- ✅ Clean single-row status per workload

#### Technical Root Cause
**Problem**: Prometheus ServiceMonitor creates multiple metric series with infrastructure labels (pod, instance, endpoint, job, service, namespace, container), causing:
- Stat panels showing raw Prometheus functions instead of friendly labels
- Table panels creating duplicate rows for the same workload/application

**Solution Applied**:
- **Stat/Gauge panels**: Added `legendFormat` for user-friendly display
- **Table queries**: Aggregated with `max() by (business_label)` to get one value per logical entity
- **Table transformations**: Excluded all infrastructure labels to show only relevant data

All dashboards now display clean, single-value metrics and single-row tables without duplicates.

---

## 🔐 Security

### RBAC

The fleet repository configures least-privilege RBAC:

- Namespace-scoped Role (not ClusterRole)
- Minimal permissions for Flux reconciliation
- Keptn operators have required cluster permissions via their own RBAC

### Webhooks

Keptn uses admission webhooks for:
- Validating KeptnApp resources
- Mutating Deployments to add lifecycle tracking

Certificates are managed by cert-manager.

---

## 📝 Development Workflow

### Making Changes

1. **Clone repository**:
   ```bash
   git clone https://github.com/Cuemby/keptn-deploy.git
   cd keptn-deploy
   ```

2. **Create branch**:
   ```bash
   git checkout -b feature/my-change
   ```

3. **Edit Helm chart** or Flux configs

4. **Test locally** (optional):
   ```bash
   helm template ./helm/charts/keptn
   ```

5. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: add my change"
   git push origin feature/my-change
   ```

6. **Create Pull Request**

7. **Merge to main** → Flux auto-deploys!

---

## 📖 Resources

### Official Documentation

- [Keptn Lifecycle Toolkit](https://lifecycle.keptn.sh/)
- [Keptn Metrics Operator](https://github.com/keptn/lifecycle-toolkit/tree/main/metrics-operator)
- [Examples](https://github.com/keptn/lifecycle-toolkit/tree/main/examples)

### Tutorials

- [Getting Started](https://lifecycle.keptn.sh/docs/getting-started/)
- [Tasks and Evaluations](https://lifecycle.keptn.sh/docs/implementing/tasks/)
- [Metrics and SLOs](https://lifecycle.keptn.sh/docs/implementing/slo/)

---

## 📞 Support

- 📧 Issues: [GitHub Issues](https://github.com/Cuemby/keptn-deploy/issues)
- 📖 Keptn Docs: [https://keptn.sh/docs/](https://keptn.sh/docs/)
- 💬 Keptn Slack: [https://slack.keptn.sh/](https://slack.keptn.sh/)

---

## 📄 License

See LICENSE file for details.

---

**Made it with ❤️ by Beanters using GitOps**
