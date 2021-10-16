let k8s = ../kubernetes.dhall

let std = ../prelude.dhall

let Limits = ../shared/Limits/package.dhall

let Team = ../shared/Team.dhall

let make
    : Team -> Text -> Text -> Text -> Text -> Limits.Type -> k8s.Deployment.Type
    = \(team : Team) ->
      \(componentName : Text) ->
      \(environmentName : Text) ->
      \(appName : Text) ->
      \(deploymentName : Text) ->
      \(limits : Limits.Type) ->
        let resourcesMap
            : std.Map.Type Text Text
            = [ { mapKey = "cpu"
                , mapValue = std.Natural.show limits.cpu ++ "m"
                }
              , { mapKey = "memory"
                , mapValue = std.Natural.show limits.memory ++ "Mi"
                }
              ]

        let resourceRequirements
            : k8s.ResourceRequirements.Type
            = k8s.ResourceRequirements::{
              , limits = Some resourcesMap
              , requests = Some resourcesMap
              }

        in  k8s.Deployment::{
            , metadata = k8s.ObjectMeta::{
              , name = Some deploymentName
              , namespace = Some (componentName ++ "-" ++ environmentName)
              }
            , spec = Some k8s.DeploymentSpec::{
              , replicas = Some limits.pods
              , selector = k8s.LabelSelector::{
                , matchLabels = Some
                    (toMap { app = appName, deployment = deploymentName })
                }
              , template = k8s.PodTemplateSpec::{
                , metadata = k8s.ObjectMeta::{
                  , labels = Some
                      ( toMap
                          { app = appName
                          , deployment = deploymentName
                          , team = team.name
                          }
                      )
                  , name = Some deploymentName
                  }
                , spec = Some k8s.PodSpec::{
                  , containers =
                    [ k8s.Container::{
                      , image = Some env:IMAGE
                      , name = deploymentName
                      , resources = Some resourceRequirements
                      }
                    ]
                  }
                }
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
              { pods = 2, cpu = 1000, memory = 2000, storage = 4000 }
        ===  k8s.Deployment::{
             , metadata = k8s.ObjectMeta::{
               , name = Some "deployment"
               , namespace = Some "component-env"
               }
             , spec = Some k8s.DeploymentSpec::{
               , replicas = Some 2
               , selector = k8s.LabelSelector::{
                 , matchLabels = Some
                     (toMap { app = "service", deployment = "deployment" })
                 }
               , template = k8s.PodTemplateSpec::{
                 , metadata = k8s.ObjectMeta::{
                   , labels = Some
                       ( toMap
                           { app = "service"
                           , deployment = "deployment"
                           , team = "team"
                           }
                       )
                   , name = Some "deployment"
                   }
                 , spec = Some k8s.PodSpec::{
                   , containers =
                     [ k8s.Container::{
                       , image = Some env:IMAGE
                       , name = "deployment"
                       , resources = Some k8s.ResourceRequirements::{
                         , limits = Some
                             (toMap { cpu = "1000m", memory = "2000Mi" })
                         , requests = Some
                             (toMap { cpu = "1000m", memory = "2000Mi" })
                         }
                       }
                     ]
                   }
                 }
               }
             }

in  make
