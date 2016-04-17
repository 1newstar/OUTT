###############################################################
# Step-wise procedure for automated upgrade of DB
# Run script in the following order: 
###############################################################
1. setupEnv.sh         			--> Creates PARFILE which holds all variables required for scripts

##PREUPGRADE SCRIPTS###

2. preUpgrade.sh     			--> Runs preupg.sql, copies oracle preupgd.sql, tnsnames, orapwd,listner from NEW_ORA_HOME to OLD_ORA_HOME 
3. Run_preupgrade.sh 			--> Runs preupgd.sql
4. before_upg_restorepnt.sh 		--> Creates Restore Point before upgrade
5. shtdwnSrc.sh				--> Shutdown db before upgrade and stop listener service

*. emremove.sh				--> Runs emremove.sql (Optional step)

##UPGRADE SCRIPTS##
8. upgrade.sh				--> Starts db in startup upgrade, runs catctl.perl

##POST UPGRADE SCRIPTS##
9.  post.sh				--> Runs postupgrade_fixups.sql, utlu121s.sql, utluiobjs.sql
10. post2.sh 				--> Set 12c compatability and drops before upgrade restore point
11. start_listner.sh			--> Starts listner
*.  post3.sh				--> bounces db, creates restore point after upgrade, start database cluster

Note: You must update ORATAB with NEW_ORA_HOME after upgrade is complete
