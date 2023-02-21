#!/bin/bash -x
################################################################################
LANG="en_US.UTF8" ; export LANG
MYDIR="$(dirname `readlink -f -- $0`)";
CURDAT="$(date +"%Y%m%d_%H")";
ALTDAT="$(date +"%M"m"")";
##############################################################
typeset -A SVC
SVC[SVC1]="SVC1"
SVC[SVC2]="SVC2"
SVC[SVC3]="SVC3"
SVC[SVC4]="SVC4"
#......others
##############################################################
mkdir -p "$MYDIR/SVC_ALL/WARNING/RUN"
mkdir -p "$MYDIR/SVC_ALL/WARNING/LOG/$CURDAT"
export SVCRUN="$MYDIR/SVC_ALL/WARNING/RUN"
export SVCLOG="$MYDIR/SVC_ALL/WARNING/LOG"
export SVCNFO="$MYDIR/SVC_ALL/WARNING/LOG/$CURDAT"
export _WRLOG="$MYDIR/SVC_ALL/WARNING/LOG/ibm_warn_A_"$CURDAT"";
export _WRBSH="$MYDIR/SVC_ALL/WARNING/LOG/ibm_warn_B_"$CURDAT"";
export _WRRUN="$MYDIR/SVC_ALL/WARNING/RUN/ibm_warn_C_"$CURDAT".sh";
# SVC     WARNING LOG DATE
# 		  DECOM    LOG DATE
# 		  RUN
##############################################################
USER1=xxx
PASS2=xxx
###
function ob_info () {
    for i in "${!SVC[@]}"
    do
        $(echo | (echo 'svcinfo lsvdisk -delim " " -nohdr | \
        cut -d " " -f1,2,7,9' && exit) | \
        sshpass -p $PASS2 ssh -T $USER1"@"${SVC[$i]} > "$SVCNFO"/"$i")
        $(echo | (echo 'lssevdiskcopy -delim " " -nohdr | \
        cut -d " " -f 1-2,11,12,14,15' && exit) | \
        sshpass -p $PASS2 ssh -T $USER1"@"${SVC[$i]} > "$SVCNFO"/"$i".b)
    done
}
###
function ob_warning () {
    pushd "$SVCNFO" >/dev/null 2>&1;
    if [ "$(ls -A $SVCNFO)" ]; then
        echo "Directory is not Empty, running.."
    else
        echo "Directory is Empty, exiting.."
        exit 1
    fi
    for i in "${!SVC[@]}"
    do
		awk 'FNR==NR{a[$1]=$0;next}; \
			{print FILENAME,$0, (($1 in a) ? a[$1]: \
			" NA NA NA NA NA NA")}' "$i".b "$i" >> "$_WRLOG"
	done
}
###
function ob_vals () {
    pushd "$SVCLOG" >/dev/null 2>&1;
    if [ -e "$_WRLOG" ]; then
        echo "File is present, running.."
    else
        echo "File is not present, exiting.."
        exit 1
    fi
    awk '{if ( !/NA NA NA/ && $9>/^[:digit:]/ && $9 !~/[[:alpha:]]/) \
    { $12=0; printf ("%s %s %s %s %s %s %s %s %s %s %s %s\n", \
             $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) }}' "$_WRLOG" | \
             awk '{BEGiN} {for(i = 11; i < NF; i++) if($i != $12) \
             {print "sshpass","-p","$PASS2","ssh","-T","$USER1""@"$1,\
              "svctask","chvdisk","-unit","mb","-warning",$12"%",$3,"#","PREV:",\
              $1,$2,$3,$8,$9,$10,$11; next }}' >> "$_WRBSH"
    mv "$_WRLOG" "$_WRLOG"_"$ALTDAT"  >/dev/null 2>&1;
    ebck
}
###
function ob_gen () {
    cnt=`grep '[ t]*$' "$_WRBSH" | wc -l`
    if [ "$cnt" -ne 0 ]; then
        echo "..not empty, running.."
        GEN1=$(echo | cat "$_WRBSH" | sort -k6,6 -k8,8)
        cat <<EOF  > "$_WRRUN"
#!/bin/bash -x
############################
USER1=xxx
PASS2=xxx
############################
############################
$GEN1
############################
EOF
        mv "$_WRBSH" "$_WRBSH"_"$ALTDAT"  >/dev/null 2>&1; 
    else 
        echo " ..is empty, exiting.."
        echo " ..removing.. "
        rm "$_WRBSH" >/dev/null 2>&1;
        exit 1
    fi
}
###
function ob_exec () {
    pushd "$SVCRUN"
    chmod u+x *
    time ./ibm_warn_C_"$CURDAT".sh;
    shred -f -u "$_WRRUN"  >/dev/null 2>&1;
}
###
function exea () {
    ob_info
    ob_warning
    ob_vals
    ob_gen
    ob_exec
}
function exed () {
    pushd "$SVCLOG"
    touch dummy_B_2020
    echo "## FILENAME TIMESTAMP ##"
    awk '{print FILENAME,$13,$14,$15,$16,"VALUE:",$20,"NOW:",$12}' *_B_2020*
}
###
function ebck () {
for bck in "$SVCNFO"; do
    tar czfP  "$SVCNFO"_"$ALTDAT".tar.gz "$SVCNFO" --remove-files >/dev/null 2>&1;
done
}
###
usage() {
    cat  << EOF
    # " ____ ____ ____ ____ ____ ____ ____ ";
    # "||I |||B |||M|||   |||  |||  |||  ||";
    # "||  |||  ||| |||  |||  |||  |||  ||";
    # "|/__\|/__\|/__\|/__\|/__\|/__\|/__\|";
    # params: -warn    : execute, check and align threshold to zero value
    # params: -see     : see which vdisks were aligned in time
EOF
}
###
case "$1" in
        -warn)
           	exea
            ;; 
        -see)
           	exed
            ;;
        *)
            echo $"Usage: $0 {SVC_THRO}"
            usage
            exit 1
esac
 
