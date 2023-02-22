#### Create a single Linux VM

## Create single Linux VM with:

* 2 NICs
* Set autoshutdown
* Enable boot diagnotics for Serial Console
* Public IP
* NSG that filters on incoming IP

## This config is under development (ToDo):

* Experiment with using a json source for "multivm"
* cleanup network config - single VM
* Use existing NSG - test for region
* Use "remote_exec" to run some CPUinfo commands

#### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

#### Acknowledgments

* None so far other than the many good examples out there.