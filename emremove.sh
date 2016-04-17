#-----------------------------------------------------------------
#Script runs emremove.sql 
# This is an optional pre-upgrade step to remove enterprise manager 
# Huzaifa Z 8/11/2015
#------------------------------------------------------------------

export PARFILE=./bin/param.txt
echo "Parameter File: $PARFILE"
#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi

export LOGDIR=`grep LOGDIR $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`  

emctl stop dbconsole
$ORACLE_HOME/bin/sqlplus "/as sysdba" <<EOF
sqlplus "/ as sysdba"  <<EOF
set echo on
spool ${LOGDIR}/${ORACLE_SID}/emremove.log
@${ORACLE_HOME}/rdbms/admin/emremove.sql
spool off;
EOF
