# Reset package-lock before pull
cd /var/www/printshop/web
git checkout -- package-lock.json

# Pull
prev_package_json=$(cat package.json)
prev_package_lock=$(cat package-lock.json)
./git-pull-current.sh
cur_package_json=$(cat package.json)
cur_package_lock=$(cat package-lock.json)

# Use node v20 for this project
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 20

# Rebuild if package is newer
if [[ "$prev_package_json" != "$cur_package_json" || "$prev_package_lock" != "$cur_package_lock" ]]; then
	echo "[Notice] Some module was changed -> Run: npm install"
	npm install
fi

# Build
npm run build

# echo "Please ensure you uploaded new .next.zip first !"
# sleep 2
# rm -rf .next && unzip .next.zip

# Restart service and View log
sudo systemctl restart printshop_webService
echo "[Info] printshop_webService was restarted."
