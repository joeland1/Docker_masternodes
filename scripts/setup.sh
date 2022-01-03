# setup master container
# setup.sh --key [optional mn key] --reset (will reset conf file if found)

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

BOOTSTRAP_LINK='https://www.dropbox.com/s/s4vy92sczk9c10s/blocks_n_chains.tar.gz'
ADDNODE_LINK='https://www.dropbox.com/s/s0pdil1rehsy4fu/peers.txt'

DAEMON_PATH='./dogecashd'
CLI_PATH='./dogecash-cli'
DATA_PATH='/root/data'
CONF_FILE=$DATA_PATH'/dogecash.conf'
RPC_PORT=56740
PARAMS_DIR='/root/params'

function setup_tor () {
  echo "Setting up tor..."
  hash_pw=$(tor --quiet --hash-password password)
  tor --quiet -controlport 9051 -runasdaemon 1 -hashedcontrolpassword "$hash_pw"

  if [ -z $(pidof tor) ]; then
    echo -e "${RED}Tor has not started. Setup aborted.${NC}"
    exit -1
  else
    echo -e "${GREEN}Tor successfully started.${NC}"
  fi
}

function download_wallet () {
  #wget https://api.github.com/repos/dogecash/dogecash/releases/latest -s | jq -r '.assets[]|select(.browser_download_url|test(".*aarch64.*(?<!debug).tar.gz"))| .browser_download_url'
  wget https://api.github.com/repos/dogecash/dogecash/releases/latest -O current_wallet.json
  case $(uname -m) in
  aarch64)
      wget $(jq -r '.assets[]|select(.browser_download_url|test(".*aarch64.*(?<!debug).tar.gz"))| .browser_download_url' current_wallet.json) -O "binaries.tar.gz"
    ;;
  Darwin | darwin)
    #might be useless idk
    wget $(jq -r '.assets[]|select(.browser_download_url|test(".*osx64.*(?<!debug).tar.gz"))| .browser_download_url' current_wallet.json) -O "binaries.tar.gz"
    ;;
  x86_64)
    wget $(jq -r '.assets[]|select(.browser_download_url|test(".*x86_64.*(?<!debug).tar.gz"))| .browser_download_url' current_wallet.json) -O "binaries.tar.gz"
    ;;
  i686)
    SEARCH_FACTOR+="i686"
    ;;
  *)
    echo -e "${RED}Cannot automatically get wallet.${NC}"
    exit 1
    ;;
  esac
  #for some reason jq wont use variables so just manually make links
  mv $(tar -xzvf binaries.tar.gz --wildcards '*dogecash-cli') ${CLI_PATH:2}
  mv $(tar -xzvf binaries.tar.gz --wildcards '*dogecashd') ${DAEMON_PATH:2}
  mv $(tar -xzvf binaries.tar.gz --wildcards '*sapling-output.params') $PARAMS_DIR
  mv $(tar -xzvf binaries.tar.gz --wildcards '*sapling-spend.params') $PARAMS_DIR
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
  echo "rpcport=$RPC_PORT" >> $CONF_FILE
}

function create_tor_creds_v2(){
  KEY=$(openssl genrsa 1024)
  echo 'RSA1024:'$(cat <<< $KEY | sed -r 's/-----BEGIN RSA PRIVATE KEY-----//g;s/-----END RSA PRIVATE KEY-----//g') > $DATA_PATH/onion_private_key
  #for some reason cant do this all in 1 go, have to save file then redo. Something about null stuff
  echo -n $(tr -d "\n " < $DATA_PATH/onion_private_key) > $DATA_PATH/onion_private_key
  echo -n 'externalip=' >> $CONF_FILE
  echo $(openssl rsa -in <(cat <<< $KEY) -pubout -outform DER | tail -c +23 | sha1sum | head -c 20 | xxd -r -p | base32)'.onion' | tee -a $CONF_FILE | sed "s/.*/masternodeaddr=&:$RPC_PORT/" >> $CONF_FILE
}

function create_mn_key () {
  echo -e "No masternode key provided... generating own"
  $DAEMON_PATH -datadir=$DATA_PATH -paramsdir=$PARAMS_DIR -conf=$CONF_FILE -rpcallowip=127.0.0.1 -rpcport=$RPC_PORT -daemon

  sleep 5

  echo -n "masternodeprivkey=" >> $CONF_FILE
  echo "pass"
  $CLI_PATH -rpcuser=$(grep 'rpcuser=' $CONF_FILE | sed 's/rpcuser=//') -rpcpassword=$(grep 'rpcpassword=' $CONF_FILE | sed 's/rpcpassword=//') -rpcport=$RPC_PORT createmasternodekey >> $CONF_FILE
}

function run () {
  source $CONF_FILE
  $CLI_PATH -rpcuser=$rpcuser -rpcpassword=$rpcpassword -rpcport=$rpcport initmasternode $masternodeprivkey $masternodeaddr
  echo "add the following line to your masternode.conf"
  echo -e "the information for the collateral transactions can be determined by using the ${BOLD}getmasternodeoutputs${NC} from your personal wallet."
  echo -e "${BLUE}alias $masternodeaddr $masternodeprivkey collateral_tx collateral_index${NC}"
}

function addnodes () {
  source $CONF_FILE
  echo -e "--------- adding addnodes ---------"
  for i in $(wget $ADDNODE_LINK -O - | sed ':a;N;$!ba;s/\n/ /g;s/addnode=//g;s/:[0-9]\+//g'); do
    $CLI_PATH -rpcuser=$rpcuser -rpcpassword=$rpcpassword -rpcport=$rpcport addnode $i add
    $CLI_PATH -rpcuser=$rpcuser -rpcpassword=$rpcpassword -rpcport=$rpcport addnode $i onetry
    echo -e "added addnode ${BOLD}$i${NC}"
  done;
}

function main () {
  setup_tor
  download_wallet
  #bootstrap
  create_rpc_credentials
  create_tor_creds_v2
  create_mn_key
  addnodes
  run
}

main
