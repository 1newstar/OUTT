export PARFILE=./bin/param.txt
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"

#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi
#Sets 12c environment before running upgrade
. $WKDIR/12c_Env.sh
export LOGDIR=$WKDIR/logs/${ORACLE_SID}
export ORACLE_HOME=`grep NEW_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`

echo "Note: You are about to start the database upgrade"
echo "Make sure you have ran both preupgrade scripts and    "
echo "corrected any errors and warnings, please view activity logs"
echo "for more details under: $LOGDIR"
read -p"Do you wish to continue? (y/n)" choice
case "$choice" in
        y|Y ) echo "Starting upgrade script...";;
        n|N ) exit 1;;
        * ) echo "invalid";;
esac


$ORACLE_HOME/bin/sqlplus "/as sysdba" <<EOF
set echo on
spool ${LOGDIR}/upgradesh.log
shutdown immediate
startup upgrade
spool off
exit;
EOF

cd $ORACLE_HOME/rdbms/admin
$ORACLE_HOME/perl/bin/perl catctl.pl -n 6 -l $ORACLE_HOME/diagnostics/$1 catupgrd.sql

