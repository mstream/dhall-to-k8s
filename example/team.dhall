let Team = ../src/dhall/shared/Team.dhall

let team
    : Team
    = { areaName = "MyDepartment"
      , areaOwnerName = "MyDepartmentHead"
      , name = "bobsleighteam"
      , slackChannel =
          "#bobsleighteigm (https://example.slack.com/messages/DEADBEEF/)"
      }

in  team
