# setup master container
# setup.sh [ip_address] [masternode_key]
MN_IP=${1-null}
MN_KEY=${2-null}

function test()
{
  echo $MN_IP
  echo $MN_KEY
}

test
