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

let myWebApp = webApp {
  name "sudoku-prolog"
  docker_use_azure_registry registryName
}

let containerRegistryDeployment = arm {
  location Location.NorthEurope
  add_resource myRegistry
  output "container_registry_password" myRegistry.Password

}

let deployment = arm {
  location Location.NorthEurope
  add_resource myWebApp
}

Target.initEnvironment ()

Target.create "Deploy" (fun _ ->

  let outputs =
    containerRegistryDeployment
    |> Deploy.execute "prolog-rg" Deploy.NoParameters

  deployment
  |> Deploy.execute "prolog-rg" 
      [
        $"docker-password-for-prologregistry", outputs.["container_registry_password"]
      ]
  ()
)

Target.create "Default" ignore

"Deploy"
  ==> "Default"

Target.runOrDefaultWithArguments "Default"