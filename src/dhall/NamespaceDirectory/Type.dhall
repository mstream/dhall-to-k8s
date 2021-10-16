let k8s = ../kubernetes.dhall

in  { configMaps : k8s.ConfigMapList.Type
    , deployments : k8s.DeploymentList.Type
    , ingresses : k8s.IngressList.Type
    , services : k8s.ServiceList.Type
    }
