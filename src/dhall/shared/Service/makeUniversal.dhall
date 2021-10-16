let k8s =
      https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/v5.0.0/package.dhall sha256:ef3845f617b91eaea1b7abb5bd62aeebffd04bcc592d82b7bd6b39dda5e5d545

let make = ./make.dhall

let makeUniversal
    : Text ->
      Optional Text ->
        k8s.Service.Type
    = \(componentName : Text) ->
      \(environmentName : Optional Text) ->
        make
          componentName
          environmentName
          componentName
          componentName
          (toMap { app = componentName })

in  makeUniversal
