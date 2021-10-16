let k8s = ../kubernetes.dhall

let std = ../prelude.dhall

let Limits = ./Limits/package.dhall

let sumUpLimits
    : List Limits.Type -> Limits.Type
    = \(allLimits : List Limits.Type) ->
        std.List.fold
          Limits.Type
          allLimits
          Limits.Type
          ( \(limits : Limits.Type) ->
            \(acc : Limits.Type) ->
              Limits::{
              , pods = acc.pods + limits.pods
              , memory = acc.memory + limits.memory * limits.pods
              , cpu = acc.cpu + limits.cpu * limits.pods
              , storage = acc.storage + limits.storage * limits.pods
              }
          )
          Limits.default

let makeQuota
    : Text -> Optional Text -> List Limits.Type -> k8s.ResourceQuota.Type
    = \(componentName : Text) ->
      \(environmentName : Optional Text) ->
      \(allLimits : List Limits.Type) ->
        let namespace
            : Text
            = std.Optional.fold
                Text
                environmentName
                Text
                (\(env : Text) -> "${componentName}-${env}")
                componentName

        let limits
            : Limits.Type
            = sumUpLimits allLimits

        let metadata
            : k8s.ObjectMeta.Type
            = k8s.ObjectMeta::{
              , name = Some "quota"
              , namespace = Some namespace
              }

        let spec
            : k8s.ResourceQuotaSpec.Type
            = k8s.ResourceQuotaSpec::{
              , hard = Some
                  ( toMap
                      { resourcequotas = "1"
                      , pods = std.Natural.show limits.pods
                      , `requests.cpu` = std.Natural.show limits.cpu ++ "m"
                      , `requests.memory` =
                          std.Natural.show limits.memory ++ "Mi"
                      , `requests.storage` =
                          std.Natural.show limits.storage ++ "Gi"
                      }
                  )
              }

        in  k8s.ResourceQuota::{ metadata, spec = Some spec }

let example0 =
        assert
      :     makeQuota
              "component"
              (Some "env")
              [ { pods = 1, cpu = 1000, memory = 2000, storage = 3000 }
              , { pods = 2, cpu = 100, memory = 200, storage = 300 }
              , { pods = 3, cpu = 10, memory = 20, storage = 30 }
              ]
        ===  k8s.ResourceQuota::{
             , metadata = k8s.ObjectMeta::{
               , name = Some "quota"
               , namespace = Some "component-env"
               }
             , spec = Some k8s.ResourceQuotaSpec::{
               , hard = Some
                   ( toMap
                       { resourcequotas = "1"
                       , pods = "6"
                       , `requests.cpu` = "1230m"
                       , `requests.memory` = "2460Mi"
                       , `requests.storage` = "3690Gi"
                       }
                   )
               }
             }

in  makeQuota
