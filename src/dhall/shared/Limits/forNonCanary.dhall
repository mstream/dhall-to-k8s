let std = ../../prelude.dhall

let Limits = ./Type.dhall

let forNonCanary
    : Limits -> Limits
    = \(limits : Limits) ->
        limits // { pods = std.Natural.subtract 1 limits.pods }

let example0 =
        assert
      :     forNonCanary { pods = 10, cpu = 100, memory = 200, storage = 300 }
        ===  { pods = 9, cpu = 100, memory = 200, storage = 300 }

in  forNonCanary
