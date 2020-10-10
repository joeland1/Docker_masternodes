# setup master container
# setup.sh --ip [ip addpress] --key [masternode_key]

if [ $# -gt 4 ]; then
  echo "too many peram"
  exit 1
fi

MN_IP=
MN_KEY=

while [ "$1" != "" ]; do
    case $1 in
      -h|--help)
        echo "help"
        exit 1
        ;;
      -i|--ip)
        MN_IP=$2
        ;;
      -k|--key)
        MN_KEY=$2
        ;;
      *)
    esac
    shift
    shift
done

RED='\033[0;31m'
GREEN='\033[0;32m'
NEXT='\033[0;34m'
NC='\033[0m'

COIN_NAME='dogecash'
CLI_NAME=${COIN_NAME}"-cli"
DAEMON_NAME=${COIN_NAME}"d"

HOME_PATH="/home/$COIN_NAME"

DAEMON_CONFIG_LAUNCH="-daemon -datadir=${HOME_PATH}/.${COIN_NAME}"

HAS_IP=false
HAS_KEY=false

#ifconfig.me
#ifconfig.co
#icanhazip.com
SECOND_LINK='ifconfig.me'
function get_ip()
{
  MN_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

  if [ -z "$MN_IP" ]; then
      #echo -e "${RED}$(date '+%F %r') [ERROR]: Could not get external ip from opendns.com${NC}" -> maybe add timestamps later
      echo -e "${RED}[ERROR]: Could not get external ip from opendns.com${NC}"
      echo -e "[INFO]: Trying to get ip from ${SECOND_LINK}"

      MN_IP=$(curl -s ${SECOND_LINK})

      if [ -z "$MN_IP" ]; then
        echo -e "${RED}[ERROR]: Could not get external ip from ${SECOND_LINK}${NC}"
        echo -e "${NEXT}[NEXT]: Please use another link or manually enter in an ip address${NC}"

        exit 1
      fi
  fi
  echo -e "${GREEN}[INFO]: IP Address Aquired -> ${MN_IP}${NC}"
}

function getmnkey()
{
  echo -e "[INFO]: Generating ${COIN_NAME} masternode key"
  exec "$(pwd)/${DAEMON_NAME} ${DAEMON_CONFIG_LAUNCH}"
  MN_KEY=$(pwd"/${CLI_NAME} getblockcount")
  while [${MN_KEY} -eq -1]; do
    sleep 1
    MN_KEY=$(pwd)"/${CLI_NAME} getblockcount"
  done
}
