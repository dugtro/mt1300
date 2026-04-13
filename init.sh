#############################################################
#
# MT1300 - Cliet 모드 
#
# : curl -sSL https://raw.githubusercontent.com/dugtro/mt1300/main/init.sh | bash
#
#############################################################

function mt1300_init()
{
  A=`which igmpproxy`
  if [ "$A" == "" ]; then
    opkg update
    opkg install igmpproxy tcpdump kmod-macvlan
  else
    echo "PACKAGE : igmpproxy is already installed."
  fi
}

function add_wg0lan()
{
  A=`cat /etc/config/network  | grep wg0lan`
  if [ "$A" == "" ]; then
    uci set network.wg0lan=interface
    uci set network.wg0lan.ifname='wg0'
    uci set network.wg0lan.hostname=`uci get network.lan.hostname`
    uci commit
    #/etc/init.d/network restart
  else
    echo "NETWORK : wg0lan is already added."
  fi
}

function set_igmpproxy()
{
  FROM=$1
  TO=$2
  echo "from:" $FROM
  echo "to  :" $TO

  uci set igmpproxy.@phyint[0].network=$FROM
  uci set igmpproxy.@phyint[0].zone=$FROM
  uci set igmpproxy.@phyint[0].direction='upstream'
  uci set igmpproxy.@phyint[0].altnet='0.0.0.0/0'

  uci set igmpproxy.@phyint[1].network=$TO
  uci set igmpproxy.@phyint[1].zone=$TO
  uci set igmpproxy.@phyint[1].direction='downstream'
  uci commit

  /etc/init.d/igmpproxy restart
}

mt1300_init
add_wg0lan
set_igmpproxy "wg0lan" "lan"

