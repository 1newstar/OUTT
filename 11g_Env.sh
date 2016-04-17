#!/bin/sh

export PARFILE='./bin/param.txt'
echo "Parameter File: $PARFILE"

#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi


export ORACLE_SID=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_UNQNAME=`grep ORACLE_SID $PARFILE  | awk -F"=" '{print $2}'`
export ORACLE_HOME=`grep OLD_ORA_HOME $PARFILE  | awk -F"=" '{print $2}'`
echo $ORACLE_SID
echo $ORACLE_UNQNAME
echo $ORACLE_HOME


PATH=/usr/sbin:$PATH; export PATH
PATH=$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH

