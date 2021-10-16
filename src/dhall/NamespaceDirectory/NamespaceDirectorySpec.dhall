let k8s = ../kubernetes.dhall

let std = ../prelude.dhall

let ExtraApplicationSpec = ./ExtraApplicationSpec.dhall

let Limits = ../shared/Limits/package.dhall

let Team = ../shared/Team.dhall

in  { componentLimits : Limits.Type
    , componentName : Text
    , configs : std.Map.Type Text std.JSON.Type
    , environmentName : Text
    , extraApplications : std.Map.Type Text ExtraApplicationSpec
    , extraIngresses : List k8s.Ingress.Type
    , isPublic : Bool
    , team : Team
    , originDomain : Text
    , gtmDomain : Text
    , gtmSubDomain : Text
    , subDomain : Text
    }
