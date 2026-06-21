## Architectural Reasoning

### 1. Structural Decoupling via Node Pool Pruning
[cite_start]GKE requires an initial node group when instantiating a control plane[cite: 89]. [cite_start]However, embedding system utilities on default-configured hardware blends your operational management framework with erratic workload dependencies[cite: 28]. [cite_start]By declaring `remove_default_node_pool = true` and defining a discrete `google_container_node_pool.system_pool`, we isolate the foundational background orchestration infrastructure[cite: 28, 29]. Critical structural agents like `kube-dns` are safely allocated on right-sized resources (`e2-standard-4`)[cite: 29, 67].  

### 2. High Availability Anchoring vs. Scale-To-Zero
[cite_start]The `system_pool` is statically anchored across a minimum size of two live compute instances[cite: 31, 68]. Conversely, the expensive `de-team-pool1` data engineering sandbox contains configurations allowing elastic contractions down to zero (`min_node_count = 0`)[cite: 71, 72, 143]. [cite_start]Statically reserving space on the infrastructure anchors guarantees that even when consumer demand completely flatlines and the expensive worker fleet scales down to zero, the core scheduling plane, service discovery endpoints, and operational logging remain functional[cite: 32].  

### 3. Blast Radius Mitigation via Taints & Network Tags
[cite_start]Large compute platforms like `n4-standard-16` hyperdisk blocks incur heavy idle operational expenses[cite: 72, 74, 175].  

* [cite_start]**Taints:** Applying `workload=heavy:NoSchedule` acts as an entry guard[cite: 155, 176]. [cite_start]Standard applications will not accidentally schedule here, preserving the zero-instance cost target[cite: 175, 176]. [cite_start]Workloads must explicitly match this profile using a pod-level `tolerations` configuration block to signal the autoscaler to scale up from zero[cite: 180].  
* [cite_start]**Network Tags:** Passing `vast-client` network tags separates cloud security structures from ephemeral IP changes[cite: 79, 84]. [cite_start]Firewall rules utilize these labels directly to track traffic footprints, maintaining zero-trust network integrity regardless of node scale status[cite: 84].