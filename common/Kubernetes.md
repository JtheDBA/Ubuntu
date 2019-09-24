# Kubernetes

Nothing here yet

Kubernetes Objects
Kubernetes defines a set of building blocks ("primitives"), which collectively provide mechanisms that deploy, maintain, and scale applications based on CPU, memory[14] or custom metrics.[15] Kubernetes is loosely coupled and extensible to meet different workloads. This extensibility is provided in large part by the Kubernetes API, which is used by internal components as well as extensions and containers that run on Kubernetes.[16] The platform exerts its control over compute and storage resources by defining resources as Objects, which can then be managed as such. The key objects are:

Pods
A pod is a higher level of abstraction grouping containerized components. A pod consists of one or more containers that are guaranteed to be co-located on the host machine and can share resources.[16]. The basic scheduling unit in Kubernetes is a pod.[17]

Each pod in Kubernetes is assigned a unique Pod IP address within the cluster, which allows applications to use ports without the risk of conflict.[18] Within the pod, all containers can reference each other on localhost, but a container within one pod has no way of directly addressing another container within another pod; for that, it has to use the Pod IP Address. An application developer should never use the Pod IP Address though, to reference / invoke a capability in another pod, as Pod IP addresses are ephemeral - the specific pod that they are referencing may be assigned to another Pod IP address on restart. Instead, they should use a reference to a Service, which holds a reference to the target pod at the specific Pod IP Address.

A pod can define a volume, such as a local disk directory or a network disk, and expose it to the containers in the pod.[19] Pods can be managed manually through the Kubernetes API, or their management can be delegated to a controller.[16] Such volumes are also the basis for the Kubernetes features of ConfigMaps (to provide access to configuration through the filesystem visible to the container) and Secrets (to provide access to credentials needed to access remote resources securely, by providing those credentials on the filesystem visible only to authorized containers).

Services

Simplified view showing how Services interact with Pod networking in a Kubernetes cluster
A Kubernetes service is a set of pods that work together, such as one tier of a multi-tier application. The set of pods that constitute a service are defined by a label selector.[16] Kubernetes provides two modes of service discovery, using environmental variables or using Kubernetes DNS.[20] Service discovery assigns a stable IP address and DNS name to the service, and load balances traffic in a round-robin manner to network connections of that IP address among the pods matching the selector (even as failures cause the pods to move from machine to machine).[18] By default a service is exposed inside a cluster (e.g., back end pods might be grouped into a service, with requests from the front-end pods load-balanced among them), but a service can also be exposed outside a cluster (e.g., for clients to reach front-end pods).[21]

Volumes
Filesystems in the Kubernetes container provide ephemeral storage, by default. This means that a restart of the pod will wipe out any data on such containers, and therefore, this form of storage is quite limiting in anything but trivial applications. A Kubernetes Volume provides persistent storage that exists for the lifetime of the pod itself. This storage can also be used as shared disk space for containers within the pod. Volumes are mounted at specific mount points within the container, which are defined by the pod configuration, and cannot mount onto other volumes or link to other volumes. The same volume can be mounted at different points in the filesystem tree by different containers.

Namespaces
Kubernetes provides a partitioning of the resources it manages into non-overlapping sets called namespaces. They are intended for use in environments with many users spread across multiple teams, or projects, or even separating environments like development, test, and production.

Secrets
A common application challenge is deciding where to store and manage sensitive information, such as passwords, OAuth tokens, and ssh keys. The Kubernetes-provided mechanism for this is called "secrets". Secrets are safer and more flexible than putting the sensitive data in a pod definition or in a container image. The data itself is stored on the master which is a highly secured machine which nobody should have login access to. A secret is only sent to a node if a pod on that node requires it. Kubernetes will keep it in memory on that node. Once the pod that depends on the secret is deleted, the in-memory copy is deleted as well. The data is accessible to the pod through one of two ways: a) as environment variables (which will be created by Kubernetes when the pod is started) or b) available on a filesystem that is visible only from within the pod.

Deployments
Deployments are made of replica set containing identical pods. The replica set is 1 or more pods that are exactly the same. Deployments can be scaled up or down manually or automatically using things like CPU and memory. You can update deployments by using commands such as kubectl set image deploy/deployment podname=(image_name) Deployments describe a declarative state meaning that if you delete pods the pods will regenerate until the declared number of replicas are met. Ex: I scale the deploy to 3 replicas and delete 1 pod, Kubernetes will start up 1 pod to replace the deleted pod.


Managing Kubernetes objects
