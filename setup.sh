# setup master container
# setup.sh [ip_address] [masternode_key]
MN_IP=${1-}
MN_KEY=${2-}

RED='\033[0;31m'
NC='\033[0m'
NEXT='\033[0;34m'

#ifconfig.me
#ifconfig.co
#icanhazip.com
SECOND_LINK='ifconfig.me'

function get_ip()
{
  MN_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
  MN_IP=
  if [ -z "$MN_IP" ]; then
      echo -e "${RED}[ERROR]: Could not get external ip from opendns.com${NC}"
      echo -e "[INFO]: Trying to get ip from ${SECOND_LINK}"

      MN_IP=$(curl -s ${SECOND_LINK})
      MN_IP=

      if [ -z "$MN_IP" ]; then
        echo -e "${RED}[ERROR]: Could not get external ip from ${SECOND_LINK} ${NC}"
        echo -e "${NEXT}[NEXT]: Please use another link or manually enter in an ip address${NC}"

        exit 1
      fi

  fi
  echo "[INFO]: IP Address Aquired -> ${MN_IP}"
}

function getmnkey()
{
  echo "generate mn key"
}

get_ip
