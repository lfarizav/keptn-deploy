# keptn-deploy Repository Index

**Tenant Repository for Keptn Lifecycle Orchestration & Observability**

This repository contains Helm charts and Flux CD configurations for deploying Keptn on Kubernetes to provide cloud-native application lifecycle orchestration with pre/post deployment tasks, SLO-based quality gates, and OpenTelemetry integration.

---

## 📋 Quick Reference

| Info | Value |
|------|-------|
| **Project** | Keptn Lifecycle Toolkit Deployment |
| **Tenant** | keptn-system (Tenant 2) |
| **Priority** | 2 (deployed after monitoring) |
| **Namespace** | `keptn-system` |
| **Fleet Repository** | [k8s-open5gs-fleet](https://github.com/lfarizav/k8s-open5gs-fleet) |
| **Dependencies** | monitoring (Prometheus) |
| **Helm Chart** | keptn v0.11.0 |
| **Author** | Luis Felipe Ariza Vesga |
| **License** | MIT |

---

## 🚀 Quick Start

```bash
# Automatic deployment via Flux (GitOps)
flux reconcile helmrelease keptn -n keptn-system

# Manual deployment via Helm
helm install keptn ./helm/charts/keptn \
  --namespace keptn-system \
  --create-namespace

# Verify deployment
kubectl get pods -n keptn-system
kubectl get keptnworkloadinstance -A

# Check Keptn metrics
kubectl port-forward -n keptn-system svc/keptn-metrics-operator-metrics 8080:8080
curl http://localhost:8080/metrics
```

**Full Documentation**: See [README.md](README.md)

---

## 📁 Repository Structure

```
keptn-deploy/
├── flux/                                # Flux CD configurations
│   ├── base/                            # Base Flux configurations
│   │   ├── kustomization.yaml           # Aggregates all resources
│   │   ├── keptn-gitrepository.yaml     # Git source definition
│   │   ├── keptn-helmrelease.yaml       # Helm release config
│   │   ├── keptn-alert.yaml             # GitHub webhook alert
│   │   └── slack-notif-alert.yaml       # Slack notifications
│   │
│   └── dev/                             # Development environment
│       ├── kustomization.yaml           # Dev-specific overlays
│       └── README.md                    # Environment docs
│
├── helm/
│   └── charts/
│       ├── keptn/                       # Main Helm chart
│       │   ├── Chart.yaml               # Chart metadata (v0.11.0)
│       │   ├── Chart.lock               # Dependencies lock
│       │   ├── values.yaml              # Default values
│       │   ├── keptn-observability-values.yaml  # Observability config
│       │   ├── NOTES.txt                # Post-install notes
│       │   ├── README.md                # Chart documentation
│       │   ├── templates/               # K8s manifests
│       │   │   ├── keptn-ns.yaml        # Namespace (if needed)
│       │   │   ├── _helpers.tpl         # Template helpers
│       │   │   └── _keptnconfig.yaml    # Keptn configuration
│       │   │
│       │   └── charts/                  # Sub-charts (dependencies)
│       │       ├── keptn-lifecycle-operator/    # v0.6.0
│       │       ├── keptn-metrics-operator/      # v0.5.0
│       │       └── keptn-cert-manager/          # v0.3.0
│       │
│       └── README.md                    # Charts overview
│
├── .backup/                             # Backup configurations
├── README.md                            # Main documentation
├── DEPLOYMENT_ORDER.md                  # Deployment dependency guide
├── KEPTN_METRICS_TROUBLESHOOTING.md     # Metrics troubleshooting
└── LICENSE                              # License file
```

---

## 🎯 What is Keptn?

Keptn Lifecycle Toolkit is a cloud-native application lifecycle orchestration tool that provides:

### Core Capabilities

1. **Deployment Tracking**
   - Tracks application and workload deployments
   - Provides deployment context and history
   - Links deployments to Git commits

2. **Pre/Post Deployment Tasks**
   - Automated tasks before deployment (migrations, validation)
   - Automated tasks after deployment (smoke tests, cache warming)
   - Task orchestration and dependencies

3. **SLO-Based Quality Gates**
   - Define Service Level Objectives (SLOs)
   - Measure Service Level Indicators (SLIs)
   - Automated quality gate evaluation
   - Rollback on SLO violations

4. **Observability**
   - OpenTelemetry traces for deployment lifecycle
   - Prometheus metrics for all stages
   - Integration with Grafana dashboards
   - Jaeger tracing support

5. **Multi-Version Support**
   - Support for blue/green deployments
   - Canary deployment tracking
   - A/B testing support

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
│  │ (v0.6.0)         │      │ (v0.5.0)         │       │
│  └────────┬─────────┘      └────────┬─────────┘       │
│           │                         │                  │
│           ▼                         ▼                  │
│  ┌──────────────────┐      ┌──────────────────┐       │
│  │ KeptnApp         │      │ KeptnMetric      │       │
│  │ KeptnWorkload    │      │ KeptnMetricsPr.  │       │
│  │ KeptnTask        │      │ Analysis         │       │
│  │ KeptnTaskDef.    │      │ AnalysisDefin.   │       │
│  └──────────────────┘      └──────────────────┘       │
│           │                         │                  │
│           │    ┌──────────────────┐ │                  │
│           │    │ Cert Manager     │ │                  │
│           │    │ (v0.3.0)         │ │                  │
│           │    └────────┬─────────┘ │                  │
│           │             │            │                  │
│           └─────────────┼────────────┘                  │
│                         ▼                               │
│           ┌──────────────────┐                          │
│           │ OpenTelemetry    │                          │
│           │ Collector        │                          │
│           └────────┬─────────┘                          │
└────────────────────┼─────────────────────────────────────┘
                     │
          ┌──────────┼──────────┐
          │          │          │
          ▼          ▼          ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │Prometheus│ │ Jaeger │ │ Grafana │
    │(metrics)│  │(traces)│  │(dashboards)│
    └─────────┘ └─────────┘ └─────────┘
```

### Deployment Lifecycle with Keptn

```
1. Deployment starts (Helm/Flux applies manifests)
   │
   ├─► Pre-deployment phase (KeptnTaskDefinition)
   │   ├─ Load tests
   │   ├─ Database migrations
   │   ├─ Configuration validation
   │   └─ Resource checks
   │
2. Application deploys (Pods created)
   │
   ├─► Post-deployment phase (KeptnTaskDefinition)
   │   ├─ Smoke tests
   │   ├─ Cache warming
   │   ├─ Health checks
   │   └─ Integration tests
   │
3. Evaluation phase (KeptnEvaluationDefinition)
   │
   ├─► Check SLOs (KeptnMetricsProvider)
   │   ├─ Response time < 500ms
   │   ├─ Error rate < 1%
   │   ├─ Availability > 99.9%
   │   └─ Resource usage within limits
   │
4. Result
   ├─► Pass ✓ - Deployment successful, traces exported
   └─► Fail ✗ - Rollback triggered, alert sent
```

---

## 📦 Helm Chart Components

### Main Chart: keptn (v0.11.0)

**Location**: [helm/charts/keptn/](helm/charts/keptn/)

| File | Purpose |
|------|---------|
| [Chart.yaml](helm/charts/keptn/Chart.yaml) | Chart metadata, version, dependencies |
| [values.yaml](helm/charts/keptn/values.yaml) | Default configuration values |
| [keptn-observability-values.yaml](helm/charts/keptn/keptn-observability-values.yaml) | OpenTelemetry configuration |
| [NOTES.txt](helm/charts/keptn/NOTES.txt) | Post-install instructions |
| [README.md](helm/charts/keptn/README.md) | Chart documentation |

### Sub-Chart 1: keptn-lifecycle-operator (v0.6.0)

**Location**: [helm/charts/keptn/charts/keptn-lifecycle-operator/](helm/charts/keptn/charts/keptn-lifecycle-operator/)

**Purpose**: Manages application and workload lifecycle

**CRDs**:
- `KeptnApp` - Application grouping
- `KeptnWorkload` - Individual workload tracking
- `KeptnTask` - Task instance
- `KeptnTaskDefinition` - Task template
- `KeptnAppVersion` - Application version tracking
- `KeptnWorkloadInstance` - Workload instance tracking

**Deployment**: `lifecycle-operator` pod

### Sub-Chart 2: keptn-metrics-operator (v0.5.0)

**Location**: [helm/charts/keptn/charts/keptn-metrics-operator/](helm/charts/keptn/charts/keptn-metrics-operator/)

**Purpose**: Manages SLI/SLO evaluation

**CRDs**:
- `KeptnMetric` - Metric definition
- `KeptnMetricsProvider` - Metrics source (Prometheus, Dynatrace, etc.)
- `Analysis` - Analysis instance
- `AnalysisDefinition` - Analysis template

**Deployment**: `metrics-operator` pod

**Metrics Exposed**: `:8080/metrics` (Prometheus format)

### Sub-Chart 3: keptn-cert-manager (v0.3.0)

**Location**: [helm/charts/keptn/charts/keptn-cert-manager/](helm/charts/keptn/charts/keptn-cert-manager/)

**Purpose**: Certificate management for webhook admission controllers

**Components**:
- Certificate Operator
- RBAC configurations
- Leader election support

**Deployment**: `certificate-operator` pod

---

## 🌊 Flux CD Configuration

### Base Configuration

**Location**: [flux/base/](flux/base/)

| File | Resource Type | Purpose |
|------|---------------|---------|
| [kustomization.yaml](flux/base/kustomization.yaml) | Kustomization | Aggregates all Flux resources |
| [keptn-gitrepository.yaml](flux/base/keptn-gitrepository.yaml) | GitRepository | Git source definition (5m interval) |
| [keptn-helmrelease.yaml](flux/base/keptn-helmrelease.yaml) | HelmRelease | Helm chart deployment config |
| [keptn-alert.yaml](flux/base/keptn-alert.yaml) | Alert | GitHub webhook notifications |
| [slack-notif-alert.yaml](flux/base/slack-notif-alert.yaml) | Alert | Slack notifications |

### HelmRelease Configuration

```yaml
spec:
  interval: 10m
  timeout: 15m
  dependsOn:
    - name: prom
      namespace: monitoring
  install:
    remediation:
      retries: 3
  upgrade:
    remediation:
      retries: 3
      remediateLastFailure: true
  driftDetection:
    mode: enabled
```

**Key Features**:
- Depends on `prom` (Prometheus) in monitoring namespace
- Auto-remediation on failures
- Drift detection enabled
- 15-minute timeout for complex deployments

---

## ✅ Key Features

### 1. GitOps Deployment
- ✅ Fully automated via Flux CD
- ✅ Git as single source of truth
- ✅ Drift detection and remediation
- ✅ Multi-environment support (dev/staging/prod)

### 2. Application Lifecycle Orchestration
- ✅ Pre/post deployment task automation
- ✅ Task orchestration with dependencies
- ✅ Deployment tracking and history
- ✅ Multi-version support

### 3. SLO-Based Quality Gates
- ✅ Define SLOs with KeptnEvaluationDefinition
- ✅ Query metrics from Prometheus
- ✅ Automated pass/fail decisions
- ✅ Rollback on SLO violations

### 4. Observability
- ✅ OpenTelemetry traces for deployment lifecycle
- ✅ Prometheus metrics (`:8080/metrics`)
- ✅ Integration with Grafana dashboards
- ✅ Jaeger tracing support

### 5. Integration
- ✅ Works with Helm charts and Kubernetes manifests
- ✅ Prometheus metrics provider
- ✅ Jaeger trace exporter
- ✅ Slack notifications

---

## 🔄 Integration with Open5GS

Keptn is integrated with the Open5GS 5G Core deployment:

### Pre-Deployment Tasks
- ✅ Cluster resource validation (CPU, memory, storage)
- ✅ Node health checks
- ✅ Network connectivity tests
- ✅ CRD availability verification

### Post-Deployment Tasks
- ✅ Pod status validation (all Running/Succeeded)
- ✅ ConfigMap checksum verification
- ✅ Network function connectivity tests (PFCP, NRF, NG setup)
- ✅ Service endpoint validation
- ✅ Metrics exporter health checks

### SLO Evaluation
- ✅ AMF registration success rate ≥90%
- ✅ Authentication rejection rate ≤10%
- ✅ SMF PFCP peers ≥1
- ✅ Sessions per UE ≤10
- ✅ GTP failures = 0

### Observability
- ✅ Deployment duration tracking
- ✅ Task execution metrics
- ✅ SLO compliance reporting
- ✅ Traces exported to Jaeger

---

## 📊 Monitoring & Observability

### Prometheus Metrics

Keptn exposes metrics at `:8080/metrics`:

**Lifecycle Metrics**:
- `keptn_app_count` - Number of KeptnApps
- `keptn_app_deployment_duration_seconds` - Deployment duration
- `keptn_workload_deployment_count` - Workload deployments
- `keptn_task_duration_seconds` - Task execution time
- `keptn_deployment_active` - Active deployments

**Evaluation Metrics**:
- `keptn_evaluation_count` - Number of evaluations
- `keptn_evaluation_duration_seconds` - Evaluation duration
- `keptn_evaluation_result` - Pass/fail result
- `keptn_slo_status` - SLO compliance status

### OpenTelemetry Traces

Keptn sends traces to Jaeger (port 4317):

**Trace Spans**:
- Pre-deployment phase
- Workload deployment
- Post-deployment phase
- Evaluation phase
- Task execution

### Grafana Dashboards

Access Keptn metrics in Grafana:

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/prom-grafana 3000:80

# Open: http://localhost:3000
# Default credentials: admin / prom-operator
```

**Recommended Dashboards**:
- Keptn Lifecycle Orchestration
- Deployment History
- Task Execution
- SLO Compliance
- Quality Gates

---

## 📚 Documentation

### Main Documentation

| File | Description |
|------|-------------|
| **[README.md](README.md)** | Comprehensive Keptn guide (600+ lines) |
| **[DEPLOYMENT_ORDER.md](DEPLOYMENT_ORDER.md)** | Deployment dependency guide |
| **[KEPTN_METRICS_TROUBLESHOOTING.md](KEPTN_METRICS_TROUBLESHOOTING.md)** | Metrics troubleshooting guide |

### Chart Documentation

| File | Purpose |
|------|---------|
| [helm/charts/README.md](helm/charts/README.md) | Charts overview |
| [helm/charts/keptn/README.md](helm/charts/keptn/README.md) | Main chart docs |
| [helm/charts/keptn/charts/keptn-lifecycle-operator/README.md](helm/charts/keptn/charts/keptn-lifecycle-operator/README.md) | Lifecycle operator docs |
| [helm/charts/keptn/charts/keptn-metrics-operator/README.md](helm/charts/keptn/charts/keptn-metrics-operator/README.md) | Metrics operator docs |
| [helm/charts/keptn/charts/keptn-cert-manager/README.md](helm/charts/keptn/charts/keptn-cert-manager/README.md) | Cert manager docs |

### Environment Documentation

| File | Purpose |
|------|---------|
| [flux/dev/README.md](flux/dev/README.md) | Development environment guide |

---

## 🔧 Configuration

### Helm Values

Edit `helm/charts/keptn/values.yaml`:

```yaml
# Lifecycle Operator
lifecycleOperator:
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
  metrics:
    enabled: true
    port: 8080

# Metrics Operator
metricsOperator:
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

# OpenTelemetry
opentelemetry:
  enabled: true
  collectorURL: "jaeger-collector.jaeger.svc.cluster.local:4317"

# Cert Manager
certManager:
  enabled: true
```

### Observability Configuration

Edit `helm/charts/keptn/keptn-observability-values.yaml`:

```yaml
# OpenTelemetry Collector configuration
opentelemetry:
  collectorURL: "jaeger-collector.jaeger.svc.cluster.local:4317"
  serviceName: "keptn-lifecycle"

# Prometheus metrics
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: monitoring
```

### Environment-Specific Configuration

Use Flux overlays in `flux/dev/`:

```yaml
# flux/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
patchesStrategicMerge:
- |-
  apiVersion: helm.toolkit.fluxcd.io/v2
  kind: HelmRelease
  metadata:
    name: keptn
    namespace: keptn-system
  spec:
    values:
      lifecycleOperator:
        replicas: 2  # Override for dev
```

---

## 🔍 Troubleshooting

### Common Commands

```bash
# Check Keptn pods
kubectl get pods -n keptn-system

# View Keptn CRDs
kubectl get crds | grep keptn

# List KeptnApps
kubectl get keptnapp -A

# List KeptnWorkloadInstances
kubectl get keptnworkloadinstance -A

# Check KeptnTasks
kubectl get keptntask -A

# View Keptn metrics
kubectl port-forward -n keptn-system svc/keptn-metrics-operator-metrics 8080:8080
curl http://localhost:8080/metrics

# Check lifecycle operator logs
kubectl logs -n keptn-system deploy/lifecycle-operator

# Check metrics operator logs
kubectl logs -n keptn-system deploy/metrics-operator
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Pods not starting | Resource constraints | Increase CPU/memory limits |
| Metrics not collected | Prometheus not found | Verify monitoring stack deployed |
| Traces not sent | Jaeger not reachable | Check Jaeger collector endpoint |
| Pre-tasks failing | Validation errors | Check task logs for details |
| SLO evaluation failing | Metrics query errors | Verify KeptnMetricsProvider config |

### Metrics Troubleshooting

See [KEPTN_METRICS_TROUBLESHOOTING.md](KEPTN_METRICS_TROUBLESHOOTING.md) for detailed metrics troubleshooting guide.

---

## 🎯 Use Cases

### 1. Pre-Deployment Validation
```bash
# Define pre-deployment task
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnTaskDefinition
metadata:
  name: cluster-validation
spec:
  function:
    inline:
      code: |
        # Check cluster resources
        # Validate configurations
        # Verify prerequisites
```

### 2. Post-Deployment Smoke Tests
```bash
# Define post-deployment task
apiVersion: lifecycle.keptn.sh/v1alpha3
kind: KeptnTaskDefinition
metadata:
  name: smoke-tests
spec:
  function:
    inline:
      code: |
        # Run smoke tests
        # Verify endpoints
        # Check health status
```

### 3. SLO-Based Quality Gates
```bash
# Define SLO evaluation
apiVersion: metrics.keptn.sh/v1beta1
kind: AnalysisDefinition
metadata:
  name: response-time-slo
spec:
  objectives:
    - analysisValueTemplateRef:
        name: response-time
      target:
        failure:
          lessThan:
            fixedValue: 500ms
      weight: 1
```

---

## 🔗 Related Repositories

| Repository | Purpose | Relationship |
|------------|---------|--------------|
| **k8s-open5gs-fleet** | Multi-tenant GitOps fleet | Manages this tenant |
| **k8s-open5gs-deploy** | Open5GS 5G SA Core | Uses Keptn lifecycle hooks |
| **monitoring-deploy** | Prometheus/Grafana | Provides metrics for Keptn |
| **jaeger-deploy** | Distributed tracing | Receives OpenTelemetry traces |

---

## 📊 Deployment Status

**Current Status**: ✅ Active

**Deployed Components** (3 pods):
- `certificate-operator` - Certificate management
- `lifecycle-operator` - Deployment orchestration
- `metrics-operator` - SLO evaluation

**Dependencies Met**:
- ✅ Prometheus (monitoring namespace)
- ✅ Jaeger (jaeger namespace)
- ✅ Cert-Manager (deployed)

**Integration Status**:
- ✅ Open5GS deployments tracked
- ✅ Pre/post validation tasks active
- ✅ Traces sent to Jaeger
- ✅ Metrics exposed to Prometheus

---

## 🚦 Getting Started Workflow

1. **Prerequisites**: Deploy monitoring stack (Prometheus/Grafana)
2. **Deploy Keptn**: Flux auto-deploys from fleet repo
3. **Verify Pods**: Check 3 pods running in keptn-system
4. **Check CRDs**: Verify Keptn CRDs installed
5. **Test Integration**: Deploy Open5GS with Keptn hooks
6. **Monitor**: View Keptn metrics in Grafana
7. **Trace**: View deployment traces in Jaeger

---

**Maintainer**: Luis Felipe Ariza Vesga
**License**: MIT
**Keptn Version**: v0.11.0
**Last Updated**: 2026-02-02
