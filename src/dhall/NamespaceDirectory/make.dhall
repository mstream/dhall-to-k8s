let k8s = ../kubernetes.dhall

let std = ../prelude.dhall

let Limits = ../shared/Limits/package.dhall

let NamespaceDirectorySpec = ./NamespaceDirectorySpec.dhall

let NamespaceDirectory = ./Type.dhall

let makeConfigMap = ./makeConfigMap.dhall

let makeDeployment = ./makeDeployment.dhall

let makeIngress = ./makeIngress.dhall

let makeService = ./makeService.dhall

let ExtraApplicationArgs
    : Type
    = { configs : std.Map.Type Text std.JSON.Type, limits : Limits.Type }

let make
    : NamespaceDirectorySpec -> NamespaceDirectory
    = \(args : NamespaceDirectorySpec) ->
        let canaryDeployment
            : k8s.Deployment.Type
            = makeDeployment
                args.team
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-canary")
                (Limits.forCanary args.componentLimits)

        let nonCanaryDeployment
            : k8s.Deployment.Type
            = makeDeployment
                args.team
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-non-canary")
                (Limits.forNonCanary args.componentLimits)

        let extraApplicationDeployments
            : List k8s.Deployment.Type
            = let argsToDeployment =
                    \(entry : std.Map.Entry Text ExtraApplicationArgs) ->
                      makeDeployment
                        args.team
                        args.componentName
                        args.environmentName
                        entry.mapKey
                        entry.mapKey
                        entry.mapValue.limits

              in  std.List.map
                    (std.Map.Entry Text ExtraApplicationArgs)
                    k8s.Deployment.Type
                    argsToDeployment
                    args.extraApplications

        let canaryConfigMap
            : k8s.ConfigMap.Type
            = makeConfigMap
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-canary")
                args.configs

        let nonCanaryConfigMap
            : k8s.ConfigMap.Type
            = makeConfigMap
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-non-canary")
                args.configs

        let extraApplicationConfigMaps
            : List k8s.ConfigMap.Type
            = let argsToConfigMap =
                    \(entry : std.Map.Entry Text ExtraApplicationArgs) ->
                      makeConfigMap
                        args.componentName
                        args.environmentName
                        entry.mapKey
                        entry.mapKey
                        entry.mapValue.configs

              in  std.List.map
                    (std.Map.Entry Text ExtraApplicationArgs)
                    k8s.ConfigMap.Type
                    argsToConfigMap
                    args.extraApplications

        let originInternalIngress
            : k8s.Ingress.Type
            = makeIngress
                args.componentName
                args.environmentName
                args.componentName
                (     args.componentName
                  ++  "-"
                  ++  args.environmentName
                  ++  "-"
                  ++  "internal.${args.subDomain}.${args.originDomain}"
                )
                (args.componentName ++ "origin-internal")
                "main-nlb-internal"
                "internal"
                "example.com"

        let originExternalIngress
            : k8s.Ingress.Type
            = makeIngress
                args.componentName
                args.environmentName
                args.componentName
                (     args.componentName
                  ++  "-"
                  ++  args.environmentName
                  ++  "-"
                  ++  "external.${args.subDomain}.${args.originDomain}"
                )
                (args.componentName ++ "origin-external")
                "main-nlb-external"
                "internet-facing"
                "example.com"

        let gtmInternalIngress
            : k8s.Ingress.Type
            = makeIngress
                args.componentName
                args.environmentName
                args.componentName
                (     args.componentName
                  ++  "-"
                  ++  "internal-gtm.${args.gtmSubDomain}."
                  ++  args.environmentName
                  ++  ".${args.gtmDomain}"
                )
                (args.componentName ++ "-gtm-internal")
                "main-nlb-internal"
                "internal"
                "example.com"

        let gtmExternalIngress
            : k8s.Ingress.Type
            = makeIngress
                args.componentName
                args.environmentName
                args.componentName
                (     args.componentName
                  ++  "-"
                  ++  "external-gtm.${args.gtmSubDomain}."
                  ++  args.environmentName
                  ++  ".${args.gtmDomain}"
                )
                (args.componentName ++ "-gtm-external")
                "main-nlb-external"
                "internet-facing"
                "example.com"

        let canaryService
            : k8s.Service.Type
            = makeService
                args.team
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-canary")

        let nonCanaryService
            : k8s.Service.Type
            = makeService
                args.team
                args.componentName
                args.environmentName
                args.componentName
                (args.componentName ++ "-non-canary")

        let extraApplicationServices
            : List k8s.Service.Type
            = let argsToService =
                    \(entry : std.Map.Entry Text ExtraApplicationArgs) ->
                      makeService
                        args.team
                        args.componentName
                        args.environmentName
                        entry.mapKey
                        entry.mapKey

              in  std.List.map
                    (std.Map.Entry Text ExtraApplicationArgs)
                    k8s.Service.Type
                    argsToService
                    args.extraApplications

        in  { configMaps = k8s.ConfigMapList::{
              , items =
                  std.List.concat
                    k8s.ConfigMap.Type
                    [ [ canaryConfigMap, nonCanaryConfigMap ]
                    , extraApplicationConfigMaps
                    ]
              , metadata = k8s.ListMeta.default
              }
            , deployments = k8s.DeploymentList::{
              , items =
                  std.List.concat
                    k8s.Deployment.Type
                    [ [ canaryDeployment, nonCanaryDeployment ]
                    , extraApplicationDeployments
                    ]
              , metadata = k8s.ListMeta.default
              }
            , ingresses = k8s.IngressList::{
              , items =
                  std.List.concat
                    k8s.Ingress.Type
                    [ [ originInternalIngress, gtmInternalIngress ]
                    , args.extraIngresses
                    , if    args.isPublic
                      then  [ originExternalIngress, gtmExternalIngress ]
                      else  [] : List k8s.Ingress.Type
                    ]
              , metadata = k8s.ListMeta.default
              }
            , services = k8s.ServiceList::{
              , items =
                  std.List.concat
                    k8s.Service.Type
                    [ [ canaryService, nonCanaryService ]
                    , extraApplicationServices
                    ]
              , metadata = k8s.ListMeta.default
              }
            }

in  make
