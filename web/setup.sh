# Check/Import env file
if [[ ! -f ".env" ]]; then
	echo "File .env does not exist !"
	echo "Please create it by running: cp .env.sample .env"
	exit
fi

source .env
source ../base/setup.sh
