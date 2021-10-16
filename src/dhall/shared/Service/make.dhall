let k8s = ../../kubernetes.dhall

let std = ../../prelude.dhall

let make
    : Text ->
      Optional Text ->
      Text ->
      Text ->
      std.Map.Type Text Text ->
        k8s.Service.Type
    = \(componentName : Text) ->
      \(environmentName : Optional Text) ->
      \(serviceName : Text) ->
      \(deploymentName : Text) ->
      \(selector : std.Map.Type Text Text) ->
        let namespace
            : Text
            = std.Optional.fold
                Text
                environmentName
                Text
                (\(env : Text) -> "${componentName}-${env}")
                componentName

        in  k8s.Service::{
            , metadata = k8s.ObjectMeta::{
              , name = Some deploymentName
              , namespace = Some namespace
              }
            , spec = Some k8s.ServiceSpec::{
              , ports = Some
                [ { name = Some "http"
                  , nodePort = None Natural
                  , protocol = Some "TCP"
                  , port = 80
                  , targetPort = Some (k8s.IntOrString.Int 8080)
                  }
                ]
              , selector = Some selector
              }
            }

let example0 =
        assert
      :     make
              "component"
              (Some "env")
              "service"
              "deployment"
              (toMap { app = "service", deployment = "deployment" })
        ===  k8s.Service::{
             , metadata = k8s.ObjectMeta::{
               , name = Some "deployment"
               , namespace = Some "component-env"
               }
             , spec = Some k8s.ServiceSpec::{
               , ports = Some
                 [ { name = Some "http"
                   , nodePort = None Natural
                   , protocol = Some "TCP"
                   , port = 80
                   , targetPort = Some (k8s.IntOrString.Int 8080)
                   }
                 ]
               , selector = Some
                   (toMap { app = "service", deployment = "deployment" })
               }
             }

in  make
