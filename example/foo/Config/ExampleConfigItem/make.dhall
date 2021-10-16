let ExampleConfigItem = ./Type.dhall

let make
    : Text -> Text -> ExampleConfigItem
    = \(serverUrlPrefix : Text) ->
      \(clientId : Text) ->
    { serverUrlPrefix = serverUrlPrefix
        ,  clientId = clientId
        ,  cacheRefreshSeconds = 60
    }

let example0 =
        assert
      :     make "http://example.com" "exampleClientId"
        === { serverUrlPrefix = "http://example.com"
            ,  clientId = "exampleClientId"
            ,  cacheRefreshSeconds = 60
            }

in make