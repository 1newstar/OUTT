#Set location of where param file will be/ needs to be discussed
export PARFILE='./bin/param.txt'
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"

#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi
# For notifying out of DR
date
. $WKDIR/12c_Env.sh
export ELIST=`grep ELIST $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_SID=$1
export ORACLE_HOME=`grep NEW_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
export PATH=${ORACLE_HOME}/bin:$PATH
export TNS_ADMIN=$ORACLE_HOME/network/admin
DT=`date +%Y-%m-%d`
#export UNQNAME=$2
export UNQNAME=`grep ELIST $ORACLE_SID  | awk -F"=" '{print $2}'`
echo "Displaying DB Unique Name"
echo $UNQNAME
echo "Checking Status of Database"
 srvctl status database -d $UNQNAME
echo "Stopping Database"
 srvctl stop database -d $UNQNAME
echo "Checking Dataabse of Database After Stopping Database"
 srvctl status database -d $UNQNAME
echo "Starting Cluster Database"
 srvctl start database -d $UNQNAME
echo "Databse startup completed,Checking the Status Again"
 srvctl status database -d $UNQNAME
echo "This Will Create Restore Point and Display Wallet Status"
${ORACLE_HOME}/bin/sqlplus -s -l  '/ as sysdba' << EOF2 
set lines 200 
set pages 200
set head off
show parameter pfile
show parameter compatible
select * from gV$encryption_wallet;
select * from gv$restore_point;
create restore point after_12c_upgrade_05172015 guarantee flashback database;
select * from gv$restore_point;
EOF2

exit;
