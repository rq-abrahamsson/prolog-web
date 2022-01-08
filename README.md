# prolog-web

## Setup development
Install SWI-Prolog: https://www.swi-prolog.org/Download.html
Suggest using VS code with: https://marketplace.visualstudio.com/items?itemName=arthurwang.vsc-prolog

## Setup deployment
### Requirements
* Docker
### Deploy infrastructure
To setup infrastructure and push app to Azure run:
```
./fake.sh run build.fsx
```
The webhook setup from container registry to the app seems to not be added automatically every time so maybe have to be done manually.

### Only push app to Azure
```
./fake.sh run build.fsx -t "DeployApp" --single-target
```