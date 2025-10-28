kubectl apply -f /home/luis/keptn-deploy/helm/charts/keptn/templates/_keptnconfig.yaml
kubectl get keptnconfig -A
kubectl get keptnapp -A
kubectl get keptnappversion -Ao wide
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.2/cert-manager.crds.yaml
helm install cert-manager --namespace cert-manager --version v1.12.2 jetstack/cert-manager --create-namespace --wait
kubectl apply -f https://raw.githubusercontent.com/keptn/lifecycle-toolkit/keptn-v2.5.0/examples/support/observability/config/prometheus/grafana-config.yaml
kubectl apply -f https://raw.githubusercontent.com/keptn/lifecycle-toolkit/keptn-v2.5.0/examples/support/observability/config/prometheus/grafana-dashboard-keptn-applications.yaml
kubectl apply -f https://raw.githubusercontent.com/keptn/lifecycle-toolkit/keptn-v2.5.0/examples/support/observability/config/prometheus/grafana-dashboard-keptn-overview.yaml
kubectl apply -f https://raw.githubusercontent.com/keptn/lifecycle-toolkit/keptn-v2.5.0/examples/support/observability/config/prometheus/grafana-dashboard-keptn-workloads.yaml
kubectl apply -f datasources.yaml
