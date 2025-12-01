# Kubernetes Guide for EKS

## What is Kubernetes?

Kubernetes (K8s) is an open-source container orchestration platform that automates deployment, scaling, and management of containerized applications.

## Key Concepts

### 1. Pods
- Smallest deployable unit in Kubernetes
- Contains one or more containers
- Shares network and storage
- Ephemeral (can be replaced)

### 2. Deployments
- Manages replica sets
- Ensures desired number of pods running
- Handles rolling updates
- Self-healing

### 3. Services
- Stable endpoint for pods
- Load balances traffic
- Types: ClusterIP, NodePort, LoadBalancer

### 4. ConfigMaps & Secrets
- ConfigMaps: Non-sensitive configuration
- Secrets: Sensitive data (passwords, tokens)

## Our Application Architecture

```
┌─────────────────────────────────────────┐
│          EKS Cluster                    │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │      Deployment: nodejs-app       │ │
│  │                                   │ │
│  │  ┌─────┐  ┌─────┐  ┌─────┐      │ │
│  │  │Pod 1│  │Pod 2│  │Pod 3│      │ │
│  │  └─────┘  └─────┘  └─────┘      │ │
│  └───────────────────────────────────┘ │
│              │                          │
│  ┌───────────▼───────────────────────┐ │
│  │   Service: nodejs-app-service     │ │
│  │   Type: LoadBalancer              │ │
│  └───────────────────────────────────┘ │
│              │                          │
└──────────────┼──────────────────────────┘
               │
               ▼
        AWS Load Balancer
               │
               ▼
            Internet
```

## Kubernetes Manifests Explained

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-app
spec:
  replicas: 3              # Run 3 pods
  selector:
    matchLabels:
      app: nodejs-app      # Select pods with this label
  template:
    metadata:
      labels:
        app: nodejs-app    # Label for pods
    spec:
      containers:
      - name: nodejs-app
        image: <ECR_IMAGE>
        ports:
        - containerPort: 3000
        resources:
          requests:         # Minimum resources
            memory: "128Mi"
            cpu: "100m"
          limits:           # Maximum resources
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:     # Is container alive?
          httpGet:
            path: /health
            port: 3000
        readinessProbe:    # Is container ready for traffic?
          httpGet:
            path: /ready
            port: 3000
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodejs-app-service
spec:
  type: LoadBalancer      # Creates AWS Load Balancer
  selector:
    app: nodejs-app       # Route to pods with this label
  ports:
  - protocol: TCP
    port: 80              # External port
    targetPort: 3000      # Container port
```

### configmap.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nodejs-app-config
data:
  APP_NAME: "nodejs-eks-app"
  LOG_LEVEL: "info"
```

## Common kubectl Commands

### Viewing Resources

```bash
# Get all resources
kubectl get all

# Get pods
kubectl get pods
kubectl get pods -o wide  # More details

# Get deployments
kubectl get deployments

# Get services
kubectl get svc

# Describe resource (detailed info)
kubectl describe pod <POD_NAME>
kubectl describe deployment nodejs-app
```

### Managing Deployments

```bash
# Apply manifests
kubectl apply -f k8s/

# Update deployment
kubectl set image deployment/nodejs-app nodejs-app=<NEW_IMAGE>

# Scale deployment
kubectl scale deployment nodejs-app --replicas=5

# Rollout status
kubectl rollout status deployment/nodejs-app

# Rollout history
kubectl rollout history deployment/nodejs-app

# Rollback
kubectl rollout undo deployment/nodejs-app
```

### Debugging

```bash
# View logs
kubectl logs <POD_NAME>
kubectl logs -f <POD_NAME>  # Follow logs
kubectl logs deployment/nodejs-app

# Execute command in pod
kubectl exec -it <POD_NAME> -- /bin/sh

# Port forward (local testing)
kubectl port-forward pod/<POD_NAME> 8080:3000

# Get events
kubectl get events --sort-by='.lastTimestamp'
```

### Resource Management

```bash
# View resource usage
kubectl top nodes
kubectl top pods

# Delete resources
kubectl delete -f k8s/
kubectl delete pod <POD_NAME>
kubectl delete deployment nodejs-app
```

## Deployment Strategies

### Rolling Update (Default)
- Gradually replaces old pods with new ones
- Zero downtime
- Can rollback if issues

### Recreate
- Terminates all old pods first
- Then creates new pods
- Brief downtime

### Blue/Green
- Run two identical environments
- Switch traffic between them
- Instant rollback

### Canary
- Deploy new version to small subset
- Gradually increase traffic
- Monitor before full rollout

## Auto-Scaling

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nodejs-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nodejs-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Apply:
```bash
kubectl apply -f hpa.yaml
kubectl get hpa
```

## Health Checks

### Liveness Probe
- Checks if container is alive
- Restarts container if fails
- Use for detecting deadlocks

### Readiness Probe
- Checks if container is ready for traffic
- Removes from service if fails
- Use for startup checks

### Startup Probe
- Checks if application has started
- Disables other probes until passes
- Use for slow-starting apps

## Best Practices

1. **Always set resource requests and limits**
2. **Use health checks (liveness & readiness)**
3. **Use ConfigMaps for configuration**
4. **Use Secrets for sensitive data**
5. **Label everything consistently**
6. **Use namespaces for isolation**
7. **Implement proper logging**
8. **Monitor resource usage**
9. **Use rolling updates**
10. **Test in staging first**

## Troubleshooting

### Pod not starting

```bash
# Check pod status
kubectl get pods
kubectl describe pod <POD_NAME>

# Check events
kubectl get events

# Check logs
kubectl logs <POD_NAME>
```

### Service not accessible

```bash
# Check service
kubectl get svc
kubectl describe svc nodejs-app-service

# Check endpoints
kubectl get endpoints

# Check if pods are ready
kubectl get pods
```

### Image pull errors

```bash
# Check if ECR credentials are correct
# Verify image exists in ECR
aws ecr describe-images --repository-name nodejs-eks-app --region eu-north-1

# Check node IAM role has ECR permissions
```

## Next Steps

1. Learn about Ingress Controllers
2. Explore Helm for package management
3. Implement monitoring (Prometheus/Grafana)
4. Set up logging (ELK/Fluentd)
5. Implement GitOps (ArgoCD/Flux)
6. Add service mesh (Istio/Linkerd)
