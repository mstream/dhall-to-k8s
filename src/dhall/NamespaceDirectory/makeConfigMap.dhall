let k8s = ../kubernetes.dhall

let std = ../prelude.dhall

let make
    : Text ->
      Text ->
      Text ->
      Text ->
      std.Map.Type Text std.JSON.Type ->
        k8s.ConfigMap.Type
    = \(componentName : Text) ->
      \(environmentName : Text) ->
      \(appName : Text) ->
      \(deploymentName : Text) ->
      \(entries : std.Map.Type Text std.JSON.Type) ->
        k8s.ConfigMap::{
        , metadata = k8s.ObjectMeta::{
          , name = Some deploymentName
          , namespace = Some (componentName ++ "-" ++ environmentName)
          }
        , data = Some
            (std.Map.map Text std.JSON.Type Text std.JSON.renderYAML entries)
        }

let example0 =
        assert
      :     make
              "component"
              "env"
              "service"
              "deployment"
              (toMap { entry1 = std.JSON.null, entry2 = std.JSON.null })
        ===  k8s.ConfigMap::{
             , metadata = k8s.ObjectMeta::{
               , name = Some "deployment"
               , namespace = Some "component-env"
               }
             , data = Some
                 ( toMap
                     { entry1 =
                         ''
                         null
                         ''
                     , entry2 =
                         ''
                         null
                         ''
                     }
                 )
             }

in  make
