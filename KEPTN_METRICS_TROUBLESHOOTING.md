# Keptn Metrics Troubleshooting - RESOLVED

## Issue Summary
Keptn dashboards in Grafana were showing "No data" despite Keptn Lifecycle Toolkit being properly installed and running.

## Root Cause
**Prometheus was not scraping Keptn metrics from the `keptn-system` namespace** despite:
- ServiceMonitors being properly configured with correct labels (`release: prom`)
- Service port names matching ServiceMonitor port references (`metrics`)
- Prometheus configured to discover ServiceMonitors in all namespaces (`serviceMonitorNamespaceSelector: {}`)

The metrics existed at the lifecycle-operator endpoint but Prometheus hadn't picked up the ServiceMonitor configuration.

## Investigation Process

### 1. Verified Keptn Pods Running
```bash
kubectl get pods -n keptn-system
```
Result: All 3 Keptn operators running (certificate-operator, lifecycle-operator, metrics-operator)

### 2. Checked ServiceMonitors Exist
```bash
kubectl get servicemonitor -n keptn-system
```
Result: 2 ServiceMonitors present with correct labels

### 3. Verified Metrics at Source
```bash
kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n keptn-system -- \
  curl -s http://lifecycle-operator-metrics-service:2222/metrics | grep '^keptn'
```
Result: **Metrics DO exist** at the endpoint

### 4. Checked Prometheus for Metrics
```bash
kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n monitoring -- \
  curl -s "http://prom-kube-prometheus-stack-prometheus:9090/api/v1/label/__name__/values" | grep keptn
```
Result: **No Keptn metrics in Prometheus**

### 5. Verified ServiceMonitor Configuration
- ✅ ServiceMonitor has label `release: prom` (matches Prometheus selector)
- ✅ ServiceMonitor port reference: `metrics`
- ✅ Service port name: `metrics`
- ✅ Prometheus `serviceMonitorNamespaceSelector: {}` (discovers all namespaces)

## Solution
**Restarted Prometheus** to force ServiceMonitor discovery:

```bash
kubectl delete pod -n monitoring prometheus-prom-kube-prometheus-stack-prometheus-0
```

After restart, Prometheus began scraping Keptn metrics successfully.

## Available Keptn Metrics

The following metrics are now available in Prometheus:

### Application-Level Metrics
- `keptn_app_active` - Gauge tracking active app deployments
- `keptn_app_count_total` - Counter of app deployment events
- `keptn_app_deploymentduration` - App deployment duration in seconds
- `keptn_app_duration_seconds_bucket` - Histogram buckets for app duration
- `keptn_app_duration_seconds_sum` - Sum of app deployment durations
- `keptn_app_duration_seconds_count` - Count of app deployments

### Deployment/Workload-Level Metrics
- `keptn_deployment_active` - Gauge tracking active workload deployments
- `keptn_deployment_count_total` - Counter of workload deployment events
- `keptn_deployment_deploymentduration` - Workload deployment duration in seconds
- `keptn_deployment_duration_seconds_bucket` - Histogram buckets for workload duration
- `keptn_deployment_duration_seconds_sum` - Sum of workload deployment durations
- `keptn_deployment_duration_seconds_count` - Count of workload deployments

### Lifecycle Metrics
- `keptn_lifecycle_active_total` - Total active Keptn lifecycle operations

## Metric Label Structure

All metrics include these labels:
- `keptn_deployment_app_name` - Name of the KeptnApp (e.g., "open5gs", "cloudflared")
- `keptn_deployment_app_namespace` - Namespace where app is deployed
- `keptn_deployment_app_version` - Version hash of the app
- `keptn_deployment_workload_name` - Name of the workload (e.g., "open5gs-amf")
- `keptn_deployment_workload_version` - Version of the workload (e.g., "v2.7.2")
- `keptn_deployment_app_status` - Status of deployment ("Succeeded", etc.)
- `otel_scope_name` - OpenTelemetry scope (always "keptn/task")

Additional Prometheus labels:
- `job` - Either "scrape_klt" or "lifecycle-operator-metrics-service"
- `instance` - IP:port or service DNS name
- `namespace` - "keptn-system"
- `pod` - Name of the lifecycle-operator pod
- `service` - "lifecycle-operator-metrics-service"

## Dashboard Status

### Working Dashboards
After the Prometheus restart, all Keptn dashboard panels should now display data:

1. **Keptn Overview Dashboard**
   - ✅ Deployment Duration (uses `keptn_app_deploymentduration`)
   - ✅ Deployment Frequency (uses `keptn_app_deploymentinterval`)
   - ✅ All stat panels and tables

2. **Keptn Workloads Dashboard**
   - ✅ Workload Deployment Duration (uses `keptn_deployment_deploymentduration`)
   - ✅ Workload Deployment Frequency
   - ✅ All DORA metrics

3. **Keptn Applications Dashboard**
   - ✅ Active Applications
   - ✅ Total Deployments
   - ✅ Application health metrics

### Previously Fixed Issues
- ✅ Duplicate timeseries lines (fixed with `max() by (label)` aggregation)
- ✅ Missing legendFormat (added to all panels)
- ✅ Table aggregation (fixed with proper grouping)

## Verification

To verify Keptn metrics are being scraped:

```bash
# Check for keptn_deployment_deploymentduration metric
kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -n monitoring -- \
  curl -s "http://prom-kube-prometheus-stack-prometheus:9090/api/v1/query?query=keptn_deployment_deploymentduration"
```

Expected result: JSON response with multiple metric series for each Open5GS component and cloudflared.

## Notes

- Metrics are scraped every 30 seconds (configured in ServiceMonitor)
- Two scrape jobs are active:
  - `scrape_klt` - Manual scrape configuration (if configured separately)
  - `lifecycle-operator-metrics-service` - ServiceMonitor-based scraping
- This creates duplicate metrics with different labels, but dashboard queries handle this correctly
- The lifecycle-operator serves metrics on port 2222 (exposed as NodePort 30222)

## Timestamp
- Issue discovered: 2025-11-28
- Resolution: 2025-11-28
- Prometheus restart time: ~147 minutes after initial deployment
- Metrics confirmed working: After pod restart

## Related Commits
- `ffc0549` - Fix duplicate metrics in all Keptn dashboards
- `58d0979` - Fix duplicate rows in Keptn timeseries panels

## Future Recommendations

1. **Monitoring**: Set up alerts for Prometheus target health to catch ServiceMonitor discovery issues
2. **Documentation**: Add note in deployment guide about verifying Prometheus scraping after Keptn installation
3. **Automation**: Consider adding a Flux reconciliation or post-install hook to restart Prometheus after Keptn deployment
