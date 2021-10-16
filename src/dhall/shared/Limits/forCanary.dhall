let Limits = ./Type.dhall

let forCanary
    : Limits -> Limits
    = \(limits : Limits) -> limits // { pods = 1 }

let example0 =
        assert
      :     forCanary { pods = 10, cpu = 100, memory = 200, storage = 300 }
        ===  { pods = 1, cpu = 100, memory = 200, storage = 300 }

in  forCanary
