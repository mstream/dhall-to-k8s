let ExampleConfigItem = ./ExampleConfigItem/package.dhall

let Config
    : Type
    = { exampleConfigItem : ExampleConfigItem.Type, foo : Text, bar : Text, biz : Double }

in  Config
