let std = ../../../src/dhall/prelude.dhall

let ExampleConfigItem = ../Config/ExampleConfigItem/package.dhall

let NamespaceDirectory = ../../../src/dhall/NamespaceDirectory/package.dhall

let Config = ../Config/package.dhall

let componentName = ../componentName.dhall

let environmentName = "stable-int"

let namespaceDirectory
    : NamespaceDirectory.Type
    = NamespaceDirectory.make
        { componentLimits = ../componentLimits.dhall // { pods = 2 }
        , componentName
        , configs = toMap
            { `config.yml` =
                Config.toJSON
                  { exampleConfigItem =
                      ExampleConfigItem.make "http://example.com" "exampleClientId"
                  , foo = "fooVal"
                  , bar = "barVal"
                  , biz = 11.0
                  }
            }
        , environmentName
        , extraApplications = toMap
            { prometheus =
              { configs = toMap
                  { `prometheus.yml` =
                      std.JSON.object (toMap { global = std.JSON.null })
                  }
              , limits = { cpu = 200, memory = 1024, pods = 1, storage = 50 }
              }
            }
        , extraIngresses =
          [ NamespaceDirectory.makeIngress
              componentName
              environmentName
              componentName
              (componentName ++ ".example.com")
              "extra-ingress"
              "main-nlb-external"
              "internet-facing"
              "example.com"
          ]
        , isPublic = ../isPublic.dhall
        , team = ../../team.dhall
        , originDomain = "ex-npdc.com"
        , gtmDomain = "example.com"
        , gtmSubDomain = "xyz"
        , subDomain = "dev-eu-west-1"
        }

in  namespaceDirectory
