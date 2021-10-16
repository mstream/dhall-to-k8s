let std = ../../../src/dhall/prelude.dhall

let ExampleConfigItem = ./ExampleConfigItem/package.dhall

let Config = ./Type.dhall

let toJSON
    : Config -> std.JSON.Type
    = \(config : Config) ->
        std.JSON.object
          ( toMap
              { exampleConfigItem = ExampleConfigItem.toJSON config.exampleConfigItem
              , foo = std.JSON.string config.foo
              , bar = std.JSON.string config.bar
              , biz = std.JSON.number config.biz
              }
          )

in  toJSON
