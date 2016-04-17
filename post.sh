#/bin/sh
#########################################################################################################
#
# Purpose: To automate the 12c Upgrade Process
# Author : Sharad Pendkar
#
# Modified On      Who               Purpose
# --------------   ----------------  -------------------------------------------------------------------
# 12-MAR-2015      Sharad Pendkar    Initial Version
# 05-AUG-2015      Huzaifa Zainuddin Call variables from PARFILE
#########################################################################################################

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
export PATH=$PATH:/usr/lib

usage ()
{
  echo "Usage : $0 someone@domain.com"
  exit
}
# Set 12c environment
. $WKDIR/12c_Env.sh
#-------------------------------------------------------
# Verify Script Arguments
#--------------------------------------------------------
if [ "$#" -gt 2 ]
then
  usage
fi

case "$#" in
   1)
      ORA_SID=$1
      MAILID=`grep MAILID $PARFILE  | awk -F"=" '{print $2}'`
	  ;;
   2)
      ORA_SID=$1
      MAILID=$2
      ;;
   *)  
    ORA_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
    MAILID=`grep MAILID $PARFILE  | awk -F"=" '{print $2}'`
      ;;
esac

HOSTNAME=`hostname`
TIMESTAMP=`date +%Y%m%d_%H%M%S`
ORATAB=/etc/oratab
OLD_ORA_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
NEW_ORA_HOME=`grep NEW_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
LOGDIR=$WKDIR/logs/${ORA_SID}

#-----------------------------------------------------------------
#Other variables leaving untouched no need to include in PARFILE
#-----------------------------------------------------------------
PFILE=${LOGDIR}/init${ORA_SID}.ora.${TIMESTAMP}

SRC_TNSNAMES=${OLD_ORA_HOME}/network/admin/tnsnames.ora
SRC_LISTENER=${OLD_ORA_HOME}/network/admin/listener.ora
SRC_SQLNET=${OLD_ORA_HOME}/network/admin/sqlnet.ora
SRC_PWD_FILE=${OLD_ORA_HOME}/dbs/orapwd${ORA_SID}
DEST_TNPSNAMES=${LOGDIR}/tnsnames.ora
DEST_LISTENER=${LOGDIR}/listener.ora
DEST_SQLNET=${LOGDIR}/sqlnet.ora
DEST_PWD_FILE=${LOGDIR}/orapwd${ORA_SID}
BACKUP_ORATAB=$LOGDIR/${HOSTNAME}.${ORA_SID}.oratab.$TIMESTAMP
ACTIVITY_LOG=${LOGDIR}/${HOSTNAME}.${ORA_SID}.activity.${TIMESTAMP}.log
ACTIVITY_TMP_LOG=${LOGDIR}/${HOSTNAME}.${ORA_SID}.tmp.${TIMESTAMP}.log
SUBJECT="AutoUpgrade"
  $NEW_ORA_HOME/bin/sqlplus "/ as sysdba" <<EOF>${LOGDIR}/${HOSTNAME}.${ORA_SID}.startup.${TIMESTAMP}.log
   STARTUP;
EOF

 UpdateLog ()
{
   msg="$1"
   echo "$msg" | tee -a $ACTIVITY_LOG
}

ExitAutoUpgrade()
{
   echo " "
   echo "        !!!!!!!!!!   $1 Upgrade check FAILED  !!!!!!!!!!  Please take corrective action."
   echo " "
   exit;
}

[ ! -d ${LOGDIR} ] && mkdir -p ${LOGDIR}

if [ ! -d ${LOGDIR} ]; then
   echo ""
   echo ""
   echo " Log Directory ${LOGDIR} does not exists!."
   echo ""
   echo ""
   exit
fi

UpdateLog " "
UpdateLog " "
clear
UpdateLog "============================================================================== "
UpdateLog " "
UpdateLog "       HOSTNAME : ${HOSTNAME}"
UpdateLog "     Oracle SID : $ORA_SID"
UpdateLog "Old Oracle Home : ${OLD_ORA_HOME}"
UpdateLog "New Oracle Home : ${NEW_ORA_HOME}"
UpdateLog "        Log Dir : $LOGDIR"
UpdateLog "   Activity Log : $ACTIVITY_LOG"
UpdateLog "        Mail ID : $MAILID"
UpdateLog "         OPTION : Post-Check"
UpdateLog " "
UpdateLog "============================================================================== "
UpdateLog " "
while true
do
   echo "Please confirm above inputs (Y/N) : "
   read ans
   case $ans in
     n|N)
         exit
         ;;
     y|Y)
         break
         ;;
   esac
done

echo "Please confirm above inputs (Y/N) : " >> $ACTIVITY_LOG
UpdateLog "Your answer : $ans"

UpdateLog " "
UpdateLog " "
UpdateLog "Validating Input Values..."
UpdateLog " "

if [ `cat $ORATAB | grep -v "^#" | grep "$ORA_SID" | wc -l` -ge 2 ]; then
   UpdateLog "Duplicate entry in $ORATAB file.  Needs manual intervention to correct it.  Quitting AutoUpgrade Script !!!!!!!!!!"
   ExitAutoUpgrade "INVALID Input"
elif [ `cat $ORATAB | grep -v "^#" | grep "$ORA_SID" | wc -l` -eq 1 ]; then
   OLD_ORA_HOME=`cat $ORATAB | grep -v "^#" | grep "$ORA_SID" | cut -d":" -f2`
else
   OLD_ORA_HOME=`cat $ORATAB | grep "^###AutoUpgradeScript###" | grep "$ORA_SID" | cut -d":" -f2`
   if [ -z "$OLD_ORA_HOME" ]; then
      UpdateLog "Old Oracle Home does not exists in $ORATAB file.  Quitting AutoUpgrade Script !!!!!!!!!!"
      ExitAutoUpgrade "INVALID Input"
   fi
fi

if [ ! -d "$NEW_ORA_HOME" ]; then
    UpdateLog "New Oracle home does not exists.  Quitting AutoUpgrade Script !!!!!!!!!!"
    exit
fi

export ORACLE_SID=$ORA_SID
export ORACLE_HOME=$NEW_ORA_HOME

export ORACLE_UNQNAME=${ORACLE_SID%?}PD
echo $ORACLE_UNQNAME
UpdateLog "Checking DB Connectivity with New Oracle Home ..."
UpdateLog " "

DB_STATUS=`$ORACLE_HOME/bin/sqlplus -s ' / as sysdba'<< EOF
   set head off
   select open_mode from v\\$database;
EOF`

if [ `echo $DB_STATUS | grep "READ WRITE" | wc -l` -eq 0 ]; then
   UpdateLog "Database ${ORA_SID} is not Open.  Please Startup the database."   
   ExitAutoUpgrade " "
fi


UpdateLog " "
UpdateLog " "
UpdateLog "Input Values Validated by AutoUpgrade Script on `date` "
UpdateLog " "
UpdateLog " "
UpdateLog "------------------------------------------------------------------------------------------"
UpdateLog "Activity Log File: $ACTIVITY_LOG "
UpdateLog "------------------------------------------------------------------------------------------"
UpdateLog " "

$ORACLE_HOME/bin/sqlplus "/as sysdba" <<EOF >> $ACTIVITY_TMP_LOG
@${NEW_ORA_HOME}/rdbms/admin/catuppst.sql
@${NEW_ORA_HOME}/rdbms/admin/utlrp.sql
@/u01/app/oracle/cfgtoollogs/$ORACLE_UNQNAME/preupgrade/postupgrade_fixups.sql 
@${NEW_ORA_HOME}/rdbms/admin/utlu121s.sql 
@${NEW_ORA_HOME}/rdbms/admin/utluiobj.sql 
@${WKDIR}/sql/postUpg.sql 
EOF

cat $ACTIVITY_TMP_LOG >> $ACTIVITY_LOG

cat $ACTIVITY_LOG

UpdateLog " "
UpdateLog "------------------------------------------------------------------------------------------"
UpdateLog "Activity Log File: $ACTIVITY_LOG "
UpdateLog "------------------------------------------------------------------------------------------"
UpdateLog " "
echo
echo

SUBJECT="AutoUpgrade : STATUS : 12c Post Upgrade Verification - ${ORA_SID}@${HOSTNAME}"

#echo "Post Upgrade Verification - ${ORA_SID}@${HOSTNAME}  - AutoGenerated by AutoUpgrade" | mailx -s "$SUBJECT" -a $ACTIVITY_LOG $MAILID
cat $ACTIVITY_LOG | mail -s "$SUBJECT" $MAILID

