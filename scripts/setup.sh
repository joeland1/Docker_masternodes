# setup master container
# setup.sh --key [optional mn key] --reset (will reset conf file if found)

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

BOOTSTRAP_LINK='https://www.dropbox.com/s/s4vy92sczk9c10s/blocks_n_chains.tar.gz'

DAEMON_PATH='./dogecashd'
CLI_PATH='./dogecash-cli'
DATA_PATH='/root/data'
CONF_FILE=$DATA_PATH'/dogecash.conf'
RPC_PORT=57740

function setup_tor () {
  echo "Setting up tor..."
  $hash_pw=$(tor --quiet --hash-password password)
  tor --quiet -controlport 9051 -runasdaemon 1 -hashedcontrolpassword "$hash_pw"

  if [ -z $(pidof tor) ];
  then
    echo -e "${RED}Tor has not started. Setup aborted.${NC}"
    exit -1
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
  echo "rpcuser="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10) > $CONF_FILE
  echo "rpcpassword="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 ) >> $CONF_FILE
  echo "rpcallowip=127.0.0.1" >> $CONF_FILE
}

function create_tor_creds_v2(){
  echo 'RSA1024:'$(echo $KEY | sed -r 's/-----BEGIN RSA PRIVATE KEY-----//g' | sed -r 's/-----END RSA PRIVATE KEY-----//g') > .dogecash/onion_private_key
  #for some reason cant do this all in 1 go, have to save file then redo. Something about null stuff
  echo -n $(tr -d "\n " < .dogecash/onion_private_key) > .dogecash/onion_private_key
  echo -n 'externalip=' >> $CONF_FILE
  echo $(openssl rsa -in <(cat <<< $KEY) -pubout -outform DER | tail -c +23 | sha1sum | head -c 20 | xxd -r -p | base32))'.onion' | tee -a $CONF_FILE | sed "s/.*/masternodeaddr=&:$RPC_PORT/" >> $CONF_FILE
}

function create_mn_key () {
  echo -e "No masternode key provided... generating own"
  $DAEMON_PATH -datadir=$DATA_PATH -paramsdir=$DATA_PATH -conf=$CONF_FILE -rpcallowip=127.0.0.1 -rpcport=$RPC_PORT

  "masternodeprivkey="$($CLI_PATH -rpcuser=$(grep 'rpcuser='$CONF_FILE | sed 's/rpcuser=//') -rpcpassword=$(grep 'rpcpassword='$CONF_FILE | sed 's/rpcpassword=//') -rpcport=$RPC_PORT creatematernodekey ) > $CONF_FILE
  $CLI_PATH -rpcuser=$(grep 'rpcuser='$CONF_FILE | sed 's/rpcuser=//') -rpcpassword=$(grep 'rpcpassword='$CONF_FILE | sed 's/rpcpassword=//') -rpcport=$RPC_PORT stop
}


function main () {
  setup_tor
  bootstrap
  create_rpc_credentials
  create_tor_creds_v2
  create_mn_key
}

main


<<'###BLOCK-COMMENT'
Follwing text below is cample.conf Might be removed later onbut not sure. good resource

rpcuser=root
rpcpassword=PasswordOfYourChoice
rpcallowip=127.0.0.1
externalip=101.168.87.207
masternodeaddr=101.168.87.207:51472
masternodeprivkey=87haGjw6ABVZfZTcMNX5c1E3HUVH4qWcdc823RBDHsGC5P8FohW
server=1
daemon=1
maxconnections=256
masternode=1

###BLOCK-COMMENT
