let k8s = ../kubernetes.dhall

let Team = ../shared/Team.dhall

let make
    : Team -> Text -> Text -> Text -> Text -> k8s.Service.Type
    = \(team : Team) ->
      \(componentName : Text) ->
      \(environmentName : Text) ->
      \(appName : Text) ->
      \(deploymentName : Text) ->
        k8s.Service::{
        , metadata = k8s.ObjectMeta::{
          , labels = Some
              ( toMap
                  { app = appName
                  , deployment = deploymentName
                  , team = team.name
                  }
              )
          , name = Some deploymentName
          , namespace = Some (componentName ++ "-" ++ environmentName)
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
              (toMap { app = appName, deployment = deploymentName })
          }
        }

let example0 =
        assert
      :     make
              { areaName = "areaName"
              , areaOwnerName = "areaOwnerName"
              , name = "team"
              , slackChannel = "slackChannel"
              }
              "component"
              "env"
              "service"
              "deployment"
        ===  k8s.Service::{
             , metadata = k8s.ObjectMeta::{
               , labels = Some
                   ( toMap
                       { app = "service"
                       , deployment = "deployment"
                       , team = "team"
                       }
                   )
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
