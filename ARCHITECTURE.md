# EKS Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                               │
│                      Region: eu-north-1                         │
└─────────────────────────────────────────────────────────────────┘

                    Internet
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    Developer      End Users      GitHub
        │              │              │
        │              │              │
┌───────┼──────────────┼──────────────┼───────────────────────────┐
│ VPC   │              │              │                           │
│       │              │              │                           │
│   ┌───▼────┐    ┌────▼─────┐   ┌───▼────┐                     │
│   │Jenkins │    │   NLB    │   │  NAT   │                     │
│   │  EC2   │    │(K8s Svc) │   │Gateway │                     │
│   └───┬────┘    └────┬─────┘   └────────┘                     │
│       │              │                                          │
│       │         ┌────▼──────────────────────────────┐          │
│       │         │      EKS Control Plane            │          │
│       │         │      (Managed by AWS)             │          │
│       │         └────┬──────────────────────────────┘          │
│       │              │                                          │
│       │         ┌────▼──────────────────────────────┐          │
│       │         │      Worker Nodes                 │          │
│       │         │  ┌──────────┐  ┌──────────┐      │          │
│       │         │  │  Node 1  │  │  Node 2  │      │          │
│       │         │  │t3.medium │  │t3.medium │      │          │
│       │         │  │          │  │          │      │          │
│       │         │  │ ┌──────┐ │  │ ┌──────┐ │      │          │
│       │         │  │ │ Pod1 │ │  │ │ Pod2 │ │      │          │
│       │         │  │ └──────┘ │  │ └──────┘ │      │          │
│       │         │  │ ┌──────┐ │  │ ┌──────┐ │      │          │
│       │         │  │ │ Pod3 │ │  │ │ Pod4 │ │      │          │
│       │         │  │ └──────┘ │  │ └──────┘ │      │          │
│       │         │  └──────────┘  └──────────┘      │          │
│       │         └─────────────────────────────────┘          │
│       │                                                        │
│   ┌───▼────┐                                                  │
│   │  ECR   │                                                  │
│   └────────┘                                                  │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Components

### EKS Control Plane
- Managed by AWS
- Runs Kubernetes API server
- Handles scheduling
- Manages cluster state
- High availability across 3 AZs

### Worker Nodes
- EC2 instances (t3.medium)
- Run containerized applications
- Managed by EKS Node Group
- Auto-scaling capable
- 2-4 nodes (configurable)

### Pods
- Smallest deployable unit
- Contains Node.js container
- 3 replicas for high availability
- Auto-healing
- Rolling updates

### Service (LoadBalancer)
- Creates AWS Network Load Balancer
- Routes traffic to healthy pods
- Stable endpoint
- Health checks

### Jenkins
- CI/CD automation
- Builds Docker images
- Pushes to ECR
- Deploys to EKS via kubectl

### ECR
- Private Docker registry
- Stores container images
- Integrated with EKS
- Image scanning

## Network Flow

```
User Request:
    User → NLB → K8s Service → Pod (Port 3000) → Response

Jenkins Deploy:
    Jenkins → ECR (push image) → 
    kubectl apply → K8s API → 
    Nodes pull from ECR → Pods running

Pod-to-Pod:
    Pod → K8s Service → Pod (via ClusterIP)
```

## Security

### IAM Roles
- **EKS Cluster Role**: Manages cluster
- **Node Role**: Allows nodes to join cluster, pull images
- **Jenkins Role**: Push to ECR, access EKS API

### Security Groups
- **Jenkins SG**: Ports 8080, 22
- **Node SG**: Managed by EKS
- **Control Plane SG**: Managed by EKS

### RBAC (Role-Based Access Control)
- Kubernetes native authorization
- Fine-grained permissions
- Service accounts for pods

## High Availability

- **Control Plane**: 3 AZs (managed by AWS)
- **Worker Nodes**: 2 AZs
- **Pods**: 3 replicas across nodes
- **Auto-healing**: Failed pods restarted automatically
- **Rolling Updates**: Zero downtime deployments

## Scalability

### Horizontal Pod Autoscaler (HPA)
- Scales pods based on CPU/memory
- Min: 2, Max: 10 pods

### Cluster Autoscaler
- Adds/removes nodes based on demand
- Min: 2, Max: 4 nodes

### Manual Scaling
```bash
# Scale pods
kubectl scale deployment nodejs-app --replicas=5

# Scale nodes (update CloudFormation)
```

## Monitoring & Logging

### CloudWatch Container Insights
- Cluster metrics
- Node metrics
- Pod metrics

### Application Logs
```bash
kubectl logs -f deployment/nodejs-app
```

### Kubernetes Dashboard (Optional)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

## Cost Breakdown

```
Monthly Costs (24/7):

EKS Control Plane          $73  ████████████████
Worker Nodes (2x t3.medium)$60  ████████████
Jenkins (t3.medium)        $30  ██████
Network Load Balancer      $20  ████
ECR + Data Transfer        $6   ██
                          ────
Total                     $189/month
```

## Comparison: ECS vs EKS

| Feature | ECS | EKS |
|---------|-----|-----|
| Cost | $76/month | $189/month |
| Complexity | Simple | Moderate |
| Portability | AWS only | Multi-cloud |
| Features | Basic | Advanced |
| Learning Curve | Easy | Moderate |
| Community | AWS | Kubernetes |
| Best For | Simple apps | Complex microservices |
