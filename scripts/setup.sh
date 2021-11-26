# setup master container
# setup.sh --key [optional mn key]

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

BOOTSTRAP_LINK='https://www.dropbox.com/s/s4vy92sczk9c10s/blocks_n_chains.tar.gz'

DAEMON_PATH='/root/bin/dogecashd'
CLI_PATH='/root/bin/dogecash-cli'
DATA_PATH='/root/data'
CONF_FILE=$DATA_PATH'/dogecash.conf'
RPC_PORT=57740

function setup_tor () {
  echo "Setting up tor..."
  hash_pw = $(tor --hash-password password)
  tor -controlport 9051 -runasdaemon 1 -hashedcontrolpassword $hash_pw

  #sleep 3

  if [ -z $(pidof tor) ];
  then
    echo -e "${RED}Tor has not started. Setup aborted.${NC}"
  else
    echo -e "${GREEN}Tor successfully started.${NC}"
  fi
}

function bootstrap () {
  echo -e "Downloading and extracting bootstrap, this may take a while."
  wget $BOOTSTRAP_LINK -q -o "bootstrap.tar.gz"
  tar -xf "bootstrap.tar.gz" -C "/root/data"
  echo -e "${GREEN}Bootstrap installed.${NC}"
}

function create_rpc_credentials () {
  "rpcuser="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10) > $CONF_FILE
  "rpcpassword="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ) > $CONF_FILE
}

function create_mn_key () {
  $DAEMON_PATH -datadir=$DATA_PATH -paramsdir=$DATA_PATH -conf=$CONF_FILE -rpcallowip=127.0.0.1 -rpcport=$RPC_PORT

  "masternodeprivkey="$($CLI_PATH -rpcuser=$(grep 'rpcuser='$CONF_FILE | sed 's/rpcuser=//') -rpcpassword=$(grep 'rpcpassword='$CONF_FILE | sed 's/rpcpassword=//') -rpcport=$RPC_PORT creatematernodekey ) > 
}

function main () {
  setup_tor
  bootstrap
  create_rpc_credentials
  create_mn_key

}

main