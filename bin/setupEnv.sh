#This shell script setups the environment for the OUTT upgrade automation process.
#Created by MSH on 8/5/2015
echo "---------------------- OUTT DB Upgrade Automation ---------------------------"
echo " Make sure to run  from OUTT directory"
echo "Script will create necessary parameters before upgrade automation can be run"
echo "----------------------------------------------------------------------------"

read -p"Working directory path:" WKDIR
PARFILE=$WKDIR/bin/param.txt
echo WKDIR=$WKDIR >> $PARFILE

read -p"Enter the database to be upgraded, seperate by space:" dblist
echo dblist=$dblist >> $PARFILE

read -p"Enter ORACLE_HOME for the source DB: " oldorahome
echo OLD_ORA_HOME=$oldorahome >> $PARFILE

read -p"Enter the ORACLE_HOME for the target DB: " neworahome
echo NEW_ORA_HOME=$neworahome >> $PARFILE

read -p "Enter ORACLE_SID: " oraclesid
echo ORACLE_SID=$oraclesid  >> $PARFILE

read -p "Email Address to Send Notificaitons: " elist
echo ELIST=$elist >> $PARFILE
echo MAILID=$elist >> $PARFILE
