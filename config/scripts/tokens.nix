{ fetchurl, pkgs }:

with pkgs;

let
  tokens-data = fetchurl {
    name = "tokens-data";
    url = "https://api.coingecko.com/api/v3/search?locale=en";
    sha256 = "sha256-3ujTAZfpnhUqHBpmwZFLn8rbTkQEbFITwekaU+3FNFo=";
  };
in
writeShellScriptBin "tokens" ''
  rofi="${pkgs.rofi}/bin/rofi"
  curl="${pkgs.curl}/bin/curl"
  jq="${pkgs.jq}/bin/jq"
  awk="${pkgs.gawk}/bin/awk"
  data="${tokens-data}"

  if [ -z "$ROFI_OUTSIDE" ]
  then
    $rofi -modi "token:$0" -show token
    exit
  fi

  query=$1

  if [ -n "$ROFI_INFO" ]
  then
    info=$ROFI_INFO
    id=$(echo $info | cut -d ";" -f1)
    symbol=$(echo $info | cut -d ";" -f2)
    price=$($curl -s "https://api.coingecko.com/api/v3/simple/price?ids=$id&vs_currencies=usd" | $jq ".\"$id\".usd")
    echo -ne "-> 1 $symbol = $price USD\0nonselectable\x1ftrue\n"
  fi
  list=$($jq -r ".coins | .[] | [ .market_cap_rank // \"-\", .symbol, .name, .id ] | join(\";\")" $data | $awk -F ";" '{ printf "%s\t%s\t%s\\0info\\x1f%s;%s\n", $1, $2, $3, $NF, $2 }')
  echo -ne "$list"
''
