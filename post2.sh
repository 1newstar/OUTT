#Check if parameter file exists
export PARFILE=./bin/param.txt
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi
# For notifying out of DR
date
. $WKDIR/12c_Env.sh
#export  ELIST="Calheers_dba@accenture.com,CalHEERS_DBA@calheers.ca.gov"
export LOGDIR=$WKDIR/logs/${ORACLE_SID}
export ELIST=`grep ELIST $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_HOME=`grep NEW_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
export PATH=${ORACLE_HOME}/bin:$PATH
export TNS_ADMIN=$ORACLE_HOME/network/admin
DT=`date +%Y-%m-%d`
export UNQNAME=${ORACLE_SID%?}PD
echo $UNQNAME

${ORACLE_HOME}/bin/sqlplus -s -l  '/ as sysdba' << EOF1 >> $LOGDIR/post2${ORACLE_SID}_${DT}.log 
Drop Restore Point before_12c_upgrade;
alter system set compatible='12.1.0' scope=spfile sid='*';
set lines 200
set pages 200
set head off
select * from gV$restore_point;
--shutdown immediate;
EOF1
exit

