let std = ../../../../src/dhall/prelude.dhall

let Config = ./Type.dhall

let toJSON
    : Config -> std.JSON.Type
    = \(config : Config) ->
        std.JSON.object
          ( toMap
              { serverUrlPrefix = std.JSON.string config.serverUrlPrefix
              , clientId = std.JSON.string config.clientId
              , cacheRefreshSeconds = std.JSON.natural config.cacheRefreshSeconds
              }
          )

in  toJSON