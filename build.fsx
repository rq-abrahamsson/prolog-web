#r "paket:
nuget Fake.DotNet.Cli
nuget Fake.IO.FileSystem
nuget Fake.Core.Target //"

#r "paket: nuget Farmer 1.6.24"

#load ".fake/build.fsx/intellisense.fsx"
open Fake.Core
open Fake.DotNet
open Fake.IO
open Fake.IO.FileSystemOperators
open Fake.IO.Globbing.Operators
open Fake.Core.TargetOperators
open Farmer
open Farmer.Builders

let registryName = "prologregistry"
let myRegistry = containerRegistry {
  name registryName
  sku ContainerRegistry.Basic
  enable_admin_user
}

let imageName = "prolog-image"

let myWebApp = webApp {
  name "sudoku-prolog"
  operating_system OS.Linux
  docker_use_azure_registry registryName
  docker_image $"{imageName}" $"swipl ./app/start.pl"
  docker_ci
}

let containerRegistryDeployment = arm {
  location Location.NorthEurope
  add_resource myRegistry
  output "container_registry_password" myRegistry.Password

}

let deployment = arm {
  location Location.NorthEurope
  add_resources [
    myWebApp
  ]
}

Target.initEnvironment ()

Target.create "DeployInfra" (fun _ ->

  let outputs =
    containerRegistryDeployment
    |> Deploy.execute "prolog-rg" Deploy.NoParameters

  deployment
  |> Deploy.execute "prolog-rg" 
      [
        $"docker-password-for-prologregistry", outputs.["container_registry_password"]
      ]
  |> ignore
)

Target.create "DeployApp" (fun _ ->
  CreateProcess.fromRawCommand "/usr/local/bin/az" ["acr"; "login"; "--name"; $"{registryName}.azurecr.io"]
  |> Proc.run
  |> ignore

  CreateProcess.fromRawCommand "/usr/local/bin/az" ["acr"; "build"; "--image"; imageName; "--registry"; registryName; "."]
  |> Proc.run
  |> ignore

)

Target.create "Default" ignore

"DeployInfra"
  ==> "DeployApp"
  ==> "Default"

// "DeployApp"
//   ==> "Default"

Target.runOrDefaultWithArguments "Default"