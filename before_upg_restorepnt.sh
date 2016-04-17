#Creates a restore point before 12c upgrade
# -----------------------------------------------
export PARFILE=./bin/param.txt
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"
#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi
echo "Setting Environment.."
. $WKDIR/11g_Env.sh



export LOGDIR=$WKDIR/logs/${ORACLE_SID}
export dblist=`grep DBLIST $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`

$ORACLE_HOME/bin/sqlplus "/as sysdba" <<EOF
sqlplus "/ as sysdba"  <<EOF
set echo on
spool ${LOGDIR}/before_12c_restorepoint.log
select * from gV$encryption_wallet;
select * from gv$restore_point;
create restore point before_12c_upgrade guarantee flashback database;
select * from gv$restore_point;
spool off;
EOF
