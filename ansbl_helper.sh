! /bin/bash
# purpose is to handle playbooks according existing setup and execute them against d
# dedCENTREed scenario within ansible and dedCENTREed datacenters
# changelog:
# 01/02/20 added basic construct / idea
# 10/02/20 added case support
# 20/02/20 added case checks, to avoid running non-sense params
# 25/02/20 tuned exit codes handling
# 25/02/20 cosmetic adjusts
# 27/02/20 added encrypted SHA256 password for switch user/pass (ansible side)
# 03/02/20 added handling tags for ansible tasks as its reducing number of playbooks here
# 03/03/20 added handling based on dedCENTREed tags for required tasks
# 13/05/21 added to git


export HOME="/home/net"
#since tagging support lets use it to reduce amount of workbooks
function __S4HCX () { "${_EXEC[@]}" "${_PARM[@]}" "${_hSITE014[@]}" "${_PLA4[@]}" "${_TAGS[@]}" ""${_ACT4[@]}"" | grep --color 'PLAY' ; }
function __S4HCH () { "${_EXEC[@]}" "${_PARM[@]}" "${_kSITE024[@]}" "${_PLA4[@]}" "${_TAGS[@]}" "${_ACT4[@]}" | grep --color 'PLAY' ; }
function __CCdCENTRE () { if [ "$opt1" = "dCENTRE" ] ; then return 0; else return 1; fi }
function __DChSITE01 () { if [ "$opt2" = "hSITE01" ] ; then return 0; else return 1; fi }
function __DCkSITE02 () { if [ "$opt3" = "kSITE02" ] ; then return 0; else return 1; fi }
function __CLRDY () { if [ "$opt4" = "portstatsclear" ] || [ "$opt4" = "statsclear"  ]; then return 0; else return 1; fi }
function __PRINT () { cat $ANSIBLE_LOG_PATH | awk '/..|../{print substr( $0, index($0,"|") - 0, 100);}' ; }
function __COLOR () { awk 'function color(c,s) { printf ("\033[%dm%s\033[0m\n",30+c,s)} ; \
												/localhost/ {color(2,$0); next} ; \
												/ok/ {color(2,$0);next} ; \
												/TASK/ {color(6,$0); next} ; \
												/PLAY/ {color(14,$0);next} ; \
												/error || ERROR/ {color(1,$0);next} {print}' ; }
function __banner(){
cat <<"EOT"
________                                .___             
\______   _______  ____   ____ _____    __| _/____         
 |    |  _\_  __ \/  _ \_/ ___\\__  \  / __ _/ __ \        
 |    |   \|  | \(  <_> \  \___ / __ \/ /_/ \  ___/        
 |______  /|__|   \____/ \___  (____  \____ |\___  >>>>>>>       
___.    \/                   \/     ._____.\/ .__\/        
\_ |__ ___.__. _____    ____   _____|__\_ |__ |  |   ____  
 | __ <   |  | \__  \  /    \ /  ___|  || __ \|  | _/ __ \ 
 | \_\ \___  |  / __ \|   |  \\___ \|  || \_\ |  |_\  ___/ 
 |___  / ____| (____  |___|  /____  |__||___  |____/\___  >>>>
     \/\/           \/     \/     \/        \/          \/ 
	                             |_____|    ItchdCENTREgerCracker!
EOT
# // 
# // blah blah
# // 
echo '                                                v0.1' | grep --color 'v0.1'
echo
}
msg.portstatsclear() {
	echo "╔════════════════════════════════════════════════════════╗";
	echo "║ RUNNING: portstatsclear ..                             ║";
	echo "╚════════════════════════════════════════════════════════╝";
}
msg.statsclear() {
	echo "╔════════════════════════════════════════════════════════╗";
	echo "║ RUNNING: statsclear ......                             ║";
	echo "╚════════════════════════════════════════════════════════╝";
}

function __usage (){
		 __banner
	echo " ║ USAGE: $0 -c <dCENTRE> -s <hSITE01|kSITE02> -a <portstatsclear>" | grep --color 'USAGE'
	echo " ║" 
	echo " ║ Options:" | grep --color 'Options'
	echo " ║ -c like: country"
	echo " ║ -s like: DC site"
	echo " ║ -a like: action "
	echo " ║ note: all three parametrs are mandatory"
	echo " ║       otherwise script is not executed"
	echo " ║" 
	echo " ║ EX: $0 -c dCENTRE -s hSITE01 -a portstatsclear" | grep --color 'EX'
	echo " ║ EX: $0 -c dCENTRE -s hSITE01 -a statsclear" | grep --color 'EX'
	echo " ║ EX: $0 -c dCENTRE -s kSITE02 -a mapsclear" | grep --color 'EX'
	echo   
	exit   
}

while getopts "c:s:a:v" o; 
do
    shopt -s nocasematch
	case "${o}" in

		c)  opt1="$OPTARG";
			__CCdCENTRE
			;;
		s)  
			opt2="$OPTARG"; 
			__DChSITE01 
			opt3="$OPTARG";
			__DCkSITE02
			;;
		a)  
			opt4="$OPTARG";
			__CLRDY
			_ACT4=("\"$opt4\"")
			;;
	 
	    *)  echo "Unknown Parameters provided!" | grep --color 'Unknown Parameters provided'; 
		   __usage #WTF? 
	        ;;
    esac;
	shopt -u nocasematch
done

if [ $# = 0 ]; then
	__usage
    exit 1;
fi

_EXEC=(ansible-playbook)
_PARM=(-i)
_TAGS=(--tags)
_hSITE014=(in2.yml)
_kSITE024=(in2.yml)
_PLA4=(test2.yml) 
"${_EXEC[@]}" "${_PARM[@]}" "${_hSITE014[@]}" "${_PLA4[@]}" "${_TAGS[@]}"  "${_ACT4[@]}"

#string=$(echo $opt4 | awk 'BEGIN{IGNORECASE=1} $1~/'${opt4}'/ {print}')

if [ ! "$opt1" ] || [ ! "$opt2" ] || [ ! "$opt4" ]; then __usage; exit 1
	else 
if  [[ "$__CCdCENTRE" ]] && [[ "$__DChSITE01" ]] && [[ "$__CLRDY" ]] || ( __CCdCENTRE && __DChSITE01 && __CLRDY ); then
		idx0=$(basename "$0") && idx1=$(basename "$2") && idx2=$(basename "$4") && idx3=$(basename "$6") && trnc="${idx0%.sh}";
		msg.portstatsclear;
		ANSIBLE_LOG_PATH="$HOME"/"$(date +%a-%F-%H_%M)""-""${trnc}""-""[$idx1]""-""[$idx2]""-""[$idx3]".log
	export ANSIBLE_LOG_PATH 
	__S4HCX >/dev/null 2>&1;
	__PRINT | __COLOR
	else 
if [ ! "$opt1" ] || [ ! "$opt2" ] || [ ! "$opt4" ]; then __usage; exit 1
	else 
if  [[ "$__CCdCENTRE" ]] && [[ "$__DChSITE01" ]] && [[ "$__CLRDY" ]] || ( __CCdCENTRE && __DChSITE01 && __CLRDY ); then
		idx0=$(basename "$0") && idx1=$(basename "$2") && idx2=$(basename "$4") && idx3=$(basename "$6") && trnc="${idx0%.sh}";
		msg.statsclear;
		ANSIBLE_LOG_PATH="$HOME"/"$(date +%a-%F-%H_%M)""-""${trnc}""-""[$idx1]""-""[$idx2]""-""[$idx3]".log
	export ANSIBLE_LOG_PATH 
	__S4HCX >/dev/null 2>&1;
	__PRINT | __COLOR
	else 
if [ ! "$opt1" ] || [ ! "$opt3" ] || [ ! "$opt4" ]; then __usage; exit 1
	else 
if  [[ "$__CCdCENTRE" ]] && [[ "$__DCkSITE02" ]] && [[ "$__CLRDY" ]] || ( __CCdCENTRE && __DCkSITE02 && __CLRDY ); then
		idx0=$(basename "$0") && idx1=$(basename "$2") && idx2=$(basename "$4") && idx3=$(basename "$6") && trnc="${idx0%.sh}";
		msg.portstatsclear;
		ANSIBLE_LOG_PATH="$HOME"/"$(date +%a-%F-%H_%M)""-""${trnc}""-""[$idx1]""-""[$idx2]""-""[$idx3]".log
	export ANSIBLE_LOG_PATH 
	__S4HCH >/dev/null 2>&1;
	__PRINT | __COLOR
fi
fi
fi
fi
fi
fi
