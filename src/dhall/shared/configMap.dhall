let k8s = ../kubernetes.dhall

let data
    : Text
    = env:DATA as Text

let name
    : Text
    = env:NAME as Text

let namespace
    : Text
    = env:NAMESPACE as Text

let metadata
    : k8s.ObjectMeta.Type
    = k8s.ObjectMeta::{ name = Some name, namespace = Some namespace }

in  k8s.ConfigMap::{
    , data = Some [ { mapKey = name, mapValue = data } ]
    , metadata
    }
