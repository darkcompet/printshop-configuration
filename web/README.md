# cardano-node-wrapper


## Configuration

- Flow

	```bash
	# Create .env file
	cp .env.sample .env

	# Import setup file at each session
	source ./setup.sh

	# Start flow
	_CheckCurrentEnvInfo

	Install_Nginx
	InstallAndSetupNodejs_ViaNvm_PreSetup

	# Please kill terminal and re-enter before run it
	InstallAndSetupNodejs_ViaNvm_PostSetup

	_CreateNodejsProject
	_ConfigNginxForProject
	_CreateServiceForProject

	_CompleteSetupForNodejsProject

	_ConfigSSH
	```
