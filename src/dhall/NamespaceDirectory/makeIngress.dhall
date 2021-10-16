let k8s = ../kubernetes.dhall

let make
    : Text -> Text -> Text -> Text -> Text -> Text -> Text -> Text -> k8s.Ingress.Type
    = \(componentName : Text) ->
      \(environmentName : Text) ->
      \(appName : Text) ->
      \(hostName : Text) ->
      \(ingressName : Text) ->
      \(ingressClass : Text) ->
      \(frontentElbScheme : Text) ->
      \(extLabelPrefix : Text) ->
        let metadata =
              k8s.ObjectMeta::{
              , annotations = Some
                  [ { mapKey = "kubernetes.io/ingress.class", mapValue = ingressClass }
                  , { mapKey = "${extLabelPrefix}/frontend-elb-scheme", mapValue = frontentElbScheme }
                  , { mapKey = "${extLabelPrefix}/exact-path", mapValue = "false" }
                  , { mapKey = "${extLabelPrefix}/strip-path", mapValue = "false" }
                  , { mapKey = "${extLabelPrefix}/allow", mapValue = "0.0.0.0/0" }
                  ]
              , labels = Some (toMap { service = appName })
              , name = Some ingressName
              , namespace = Some (componentName ++ "-" ++ environmentName)
              }

        let spec
            : k8s.IngressSpec.Type
            = k8s.IngressSpec::{
              , rules = Some
                [ k8s.IngressRule::{
                  , host = Some hostName
                  , http = Some k8s.HTTPIngressRuleValue::{
                    , paths =
                      [ k8s.HTTPIngressPath::{
                        , backend = k8s.IngressBackend::{
                          , serviceName = appName
                          , servicePort = k8s.IntOrString.Int 80
                          }
                        , path = Some "/"
                        }
                      ]
                    }
                  }
                ]
              }

        in  k8s.Ingress::{ metadata, spec = Some spec }

let example0 =
        assert
      :     make
              "component"
              "env"
              "service"
              "example.com"
              "ingress"
              "ingress-class"
              "frontend-elb-scheme"
              "example.com"
        ===  k8s.Ingress::{
             , metadata = k8s.ObjectMeta::{
               , annotations = Some
                  [ { mapKey = "kubernetes.io/ingress.class", mapValue = "ingress-class" }
                  , { mapKey = "example.com/frontend-elb-scheme", mapValue = "frontend-elb-scheme" }
                  , { mapKey = "example.com/exact-path", mapValue = "false" }
                  , { mapKey = "example.com/strip-path", mapValue = "false" }
                  , { mapKey = "example.com/allow", mapValue = "0.0.0.0/0" }
                  ]
               , labels = Some (toMap { service = "service" })
               , name = Some "ingress"
               , namespace = Some "component-env"
               }
             , spec = Some k8s.IngressSpec::{
               , rules = Some
                 [ k8s.IngressRule::{
                   , host = Some "example.com"
                   , http = Some k8s.HTTPIngressRuleValue::{
                     , paths =
                       [ k8s.HTTPIngressPath::{
                         , backend = k8s.IngressBackend::{
                           , serviceName = "service"
                           , servicePort = k8s.IntOrString.Int 80
                           }
                         , path = Some "/"
                         }
                       ]
                     }
                   }
                 ]
               }
             }

in  make
