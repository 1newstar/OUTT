#/bin/sh
export PARFILE='./bin/param.txt'
export WKDIR=`grep WKDIR $PARFILE  | awk -F"=" '{print $2}'`
echo "Parameter File: $PARFILE"

#Check if parameter file exists
if [ ! -f "$PARFILE" ]
then
        echo "Parameter file $PARFILE does not exists"
        exit 1
fi

OPTION1=${WKDIR}/.steps1
OPTION2=${WKDIR}/.steps2
OPTION3=${WKDIR}/.steps3
OPTION4=${WKDIR}/.steps4
echo "What Option will you use?"
echo "[0] Setup Environment"
echo "[1] Pre Upgrade"
echo "[2] Upgrade"
echo "[3] Post Upgrade"
read OPTION
case ${OPTION} in
     0) echo "setupEnv.sh"
		if [ $? -ne 0 ]; then
			echo "setupEnv.sh failed"
			break;
		fi
        echo `date` > ${OPTION1}
        ;;
     1) if [ ! -f ${OPTION1} ]; then
                echo "environment not setup"
                break;
        fi
        echo "preUpgrade.sh"
		if [ $? -ne 0 ]; then
			echo "preUpgrade.sh failed"
			break;
		fi
        echo "Run_preupgrade.sh"
		if [ $? -ne 0 ]; then
			echo "Run_preupgrade.sh failed"
			break;
		fi
        echo "before_upg_restorepnt.sh"
		if [ $? -ne 0 ]; then
			echo "before_upg_restorepnt.sh failed"
			break;
		fi
        echo "shtdwnSrc.sh"
		if [ $? -ne 0 ]; then
			echo "shtdwnSrc.sh failed"
			break;
		fi
        echo "Optional: emremove.sh"
		if [ $? -ne 0 ]; then
			echo "emremove.sh failed"
			break;
		fi
        echo `date` > ${OPTION2}
        ;;
     3) if [[ ! -f ${OPTION1} || ! -f ${OPTION2} ]]; then
                echo "Please perform setup of env, preupgrade"
                break;
        fi
        echo "upgrade.sh"
		if [ $? -ne 0 ]; then
			echo "upgrade.sh failed"
			break;
		fi
        echo `date` > ${OPTION3}
        ;;
     4) if [[ ! -f ${OPTION1} || ! -f ${OPTION2} || ! -f ${OPTION3} ]]; then
                echo "Please perform setup of env, preupgrade, and upgrade"

        echo "post.sh"
		if [ $? -ne 0 ]; then
			echo "post.sh failed"
			break;
		fi
        echo "post2.sh"
		if [ $? -ne 0 ]; then
			echo "post2.sh failed"
			break;
		fi
        echo "start_listner.sh"
		if [ $? -ne 0 ]; then
			echo "start_listner.sh failed"
			break;
		fi
        echo "post3.sh"
		if [ $? -ne 0 ]; then
			echo "post3.sh failed"
			break;
		fi
        echo `date` > ${OPTION4}
        ;;
     *) echo "invalid input";
        break
        ;;
esac
