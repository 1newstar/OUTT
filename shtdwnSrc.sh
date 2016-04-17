#--------------------------------------------------------------------
# Shutdown source database
# Run script after preupgrade is completed and all warnings have been taken care of 
#
# Created 8/11/15 Huzaifa.Z 
#---------------------------------------------------------------------
export PARFILE=./bin/param.txt
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"
#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi

echo "Setting environment..."
. $WKDIR/11g_Env.sh

export LOGDIR=$WKDIR/logs/${ORACLE_SID}
export ORACLE_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`


echo "Preparing to shut down database..."
sqlplus "/ as sysdba"  <<EOF
set echo on
spool ${LOGDIR}/shutdownsrc.log
show parameter db_name
set lines 500 pages 500
shutdown immediate
spool off;
EOF

echo "Stopping listener service..."
lsnrctl stop
