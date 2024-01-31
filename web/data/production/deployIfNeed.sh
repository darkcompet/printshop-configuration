cd /var/www/printshop/web

git fetch
local_latest_commit_id=$(git rev-parse HEAD)
remote_latest_commit_id=$(git rev-parse @{u})

if [[ $local_latest_commit_id == $remote_latest_commit_id ]]; then
	echo "Skip deploy since local is synced with remote."
	exit
fi

echo "Local is out of date. Start deploy server..."

echo $(date "+%Y-%m-%d %H-%M-%S") | cat > public/version.txt

./local/deploy.sh

echo $(date "+%Y-%m-%d %H-%M-%S") | cat >> public/version.txt
