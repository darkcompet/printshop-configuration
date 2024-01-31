# Configuration for servers

For configuring a server by executing bash.


## Quick start

- Config

	```bash
	# Update OS
	sudo apt-get update -y && sudo apt-get upgrade -y

	# Pull source and Init submodules
	./git-pull.sh
	```


## How this project was made

- Make project

	```bash
	# Make git
	git init

	# Add git submodules
	mkdir -p tool/compet && cd tool/compet
	git submodule add https://github.com/darkcompet/shell-ubuntu.git
	cd ../..
	```


## Info

Current ports:
- web: 7001
