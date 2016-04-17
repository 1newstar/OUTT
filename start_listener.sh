#Stops 11g Database Listener
#Created by MSH on 8/10/2015
export PARFILE='./param.config'
echo "Parameter File: $PARFILE"

#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi

./11g_Env.sh
lsnrctl start 
