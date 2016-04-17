#!/bin/bash

export PARFILE=./bin/param.txt
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"
#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi
# Sets the 11g Environment before running the oracle SQL script
. $WKDIR/11g_Env.sh

export LOGDIR=$WKDIR/logs/${ORACLE_SID}
export ORACLE_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
sqlplus "/ as sysdba"  <<EOF
set echo on
spool ${LOGDIR}/Run_preuprade_sql.log
show parameter db_name
set lines 500 pages 500
@${ORACLE_HOME}/rdbms/admin/preupgrd.sql
spool off;
EOF

