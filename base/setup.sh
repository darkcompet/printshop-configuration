# Import functions from core
source ../tool/compet/shell-ubuntu/installer.sh


_CheckCurrentEnvInfo() {
	echo "Current env info:"
	echo "ENV: ${ENV}"
	echo "BRANCH: ${BRANCH}"

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

__CloneProject() {
	echo "Complete below settings:"
	echo "1. Register with gitlab.com to allow connection from this server:"
	echo "- Run: ssh-keygen -t ed25519 -C \"ec2 ${GIT_REPO_NAME}\""
	echo "- Copy/Paste the public key (cat ~/.ssh/id_ed25519.pub) to: https://gitlab.com/-/profile/keys"
	printf "Press y to continue? (y/*): "
	read ans
	if [[ $ans != "y" ]]; then
		echo "Aborted"
		return
	fi

	# Make parent project
	if [[ ! -d "/var/www/${PARENT_PROJ_ID}" ]]; then
		sudo mkdir -p /var/www/${PARENT_PROJ_ID}
		sudo chown ${SERVICE_USER}:${SERVICE_USER} -R /var/www/${PARENT_PROJ_ID}
		echo "[Info] Created new dir: /var/www/${PARENT_PROJ_ID}, and make owner as ${SERVICE_USER}"
	fi

	# Make tmp-user folder
	if [[ ! -d "/var/www/tmp-${SERVICE_USER}" ]]; then
		sudo mkdir -p /var/www/tmp-${SERVICE_USER}
		sudo chown ${SERVICE_USER}:${SERVICE_USER} -R /var/www/tmp-${SERVICE_USER}
		echo "[Info] Created new dir: /var/www/tmp-${SERVICE_USER}, and make owner as ${SERVICE_USER}"
	fi

	# Please config in advance to use gitlab SSH connection
	cd /var/www/tmp-${SERVICE_USER}
	git clone ${GIT_REPO_BASE_URL}/${GIT_REPO_NAME}.git
	sudo mv ${GIT_REPO_NAME} ../${PARENT_PROJ_ID}
}

_CreateAspProject() {
	__CloneProject

	# Setup env
	cd /var/www/${PARENT_PROJ_ID}/${GIT_REPO_NAME}
	git checkout ${BRANCH}
	cp Properties/launchSettings.sample Properties/launchSettings.json
	cp appsettings.sample appsettings.json

	# Move convenience files to local folder
	mkdir local
	cp ${CONFIG_PROJ_ROOT_DIR_PATH}/data/${ENV}/*.sh local/
	chmod +x local/*.sh

	echo "=> Done make project"

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

_CreateNodejsProject() {
	__CloneProject

	# Setup env
	cd /var/www/${PARENT_PROJ_ID}/${GIT_REPO_NAME}
	git checkout ${BRANCH}
	cp .env.sample .env
	npm install

	# Move convenience files to local folder
	mkdir local
	cp ${CONFIG_PROJ_ROOT_DIR_PATH}/data/${ENV}/*.sh local/
	chmod +x local/*.sh

	echo "=> Done setup project"

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

_ConfigNginxForProject() {
	# Remove default config
	sudo rm /etc/nginx/sites-available/default
	sudo rm /etc/nginx/sites-enabled/default

	# Create nginx config file
	sudo cp ${CONFIG_PROJ_ROOT_DIR_PATH}/data/${ENV}/${NGINX_CONFIG_FILE_NAME}.config /etc/nginx/sites-available/

	# Enable our site
	sudo ln -s /etc/nginx/sites-available/${NGINX_CONFIG_FILE_NAME}.config /etc/nginx/sites-enabled/

	# Validate config grammar
	sudo nginx -t

	# Done, reload config
	sudo service nginx reload

	echo "=> Done config nginx for the project"

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

_CreateServiceForProject() {
	# Create service file
	sudo cp ${CONFIG_PROJ_ROOT_DIR_PATH}/data/${ENV}/${SERVICE_IDENTIFIER}.service /etc/systemd/system/

	# Enable service start when machine boots.
	# To disable, just change enable -> disable.
	sudo systemctl enable ${SERVICE_IDENTIFIER}

	# Reload services
	sudo systemctl daemon-reload

	# Commented out since we should start service at final stage
	# Start service
	# sudo systemctl restart ${SERVICE_IDENTIFIER}
	# sudo systemctl status ${SERVICE_IDENTIFIER}

	echo "=> Created service /etc/systemd/system/${SERVICE_IDENTIFIER}.service for ${GIT_REPO_NAME}"

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

_ConfigSSH() {
	echo "Complete below settings:"
	echo "1. Domain is pointing to server"
	echo "- Domain xxx.abc.com and www.xxx.abc.com are pointing to the server public IP address??"
	echo "2. Enable firewall at ec2"
	echo "- Allow ports 80, 443 to the server by edit inbounds rules."
	printf "Press y to continue? (y/*): "
	read ans
	if [[ $ans != "y" ]]; then
		echo "Aborted"
		return
	fi

	Install_Certbot

	# Obtain ssh cert and Reload nginx
	sudo certbot --nginx -d ${RAW_URL} -d www.${RAW_URL}
	sudo service nginx reload

	echo "=> Done config SSH."

	cd ${CONFIG_PROJ_ROOT_DIR_PATH}
}

_CompleteSetupForAspProject() {
	cd /var/www/${PARENT_PROJ_ID}/${GIT_REPO_NAME}
	git branch

	echo "=> Congratulation ! Please follow below steps before start server:"
	echo "- Confirm current branch is matching with current env (${ENV})?"
	echo "- Modify setting to match with current env: nano appsettings.json"
	echo "- Deploy server: ./local/deploy.sh"
	echo "- Check service status: sudo systemctl status ${SERVICE_IDENTIFIER}"
	echo "- Check service log: journalctl --unit=${SERVICE_IDENTIFIER} --follow"
}

_CompleteSetupForNodejsProject() {
	cd /var/www/${PARENT_PROJ_ID}/${GIT_REPO_NAME}
	git branch

	echo "=> Congratulation ! Please follow below steps before start server:"
	echo "- Confirm current branch is matching with current env (${ENV})?"
	echo "- Modify setting to match with current env: nano .env"
	echo "- Deploy server: ./local/deploy.sh"
	echo "- Check service status: sudo systemctl status ${SERVICE_IDENTIFIER}"
	echo "- Check service log: journalctl --unit=${SERVICE_IDENTIFIER} --follow"
}
