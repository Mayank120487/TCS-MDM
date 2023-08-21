#!/usr/bin/sh

if [ $# -eq 0 ] || [ $# -gt 2 ] || [ $# -eq 1 ]
then	
	echo "Info: run a script as following <script name> <source> <environment>"
	echo "Ex: harmonization.sh plm qual"
	echo "Ex: harmonization.sh clamp qual"
	echo "Ex: harmonization.sh gsi qual"
	echo "Ex: harmonization.sh step2 qual"
	echo "Ex: harmonization.sh all qual"
	echo "Ex: harmonization.sh plmclamp qual"
	exit
fi

source=`echo $1 | tr '[:upper:]' '[:lower:]'`
date=`date +%s`
datetime=`date '+%D %R'`
env=`echo $2 | tr '[:upper:]' '[:lower:]'`

case $env in
	"dev") environment=$env;;
	"qual") environment=$env;; 
	"preprod") environment=$env;;
	"prod") environment=$env;;
	*)
		echo "Error:Input proper environment name"
		echo "Ex: harmonization.sh plm qual"
		exit
esac

echo "$datetime source = $source"
echo "$datetime environment = $environment"

if [ $source == "plm" ]
then
	echo "$datetime plm run on $environment"
	nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizePLM -PflowType=harmonize -Pdhf.source=PLM -Pdhf.system=PLM -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_${source}_${date}.txt 
	if [ $? == 0 ]
	then
		echo "`date '+%D %R'` Step-1 plm completed"
	else
		echo "`date '+%D %R'` Step-1 plm failed , check ./Logs/${env}/Step1_${source}_${date}.txt"
		exit
	fi

elif [ $source == "clamp" ]
then
	echo "$datetime clamp run on $environment"
	nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizeCLAMP -PflowType=harmonize -Pdhf.source=CLAMP -Pdhf.system=CLAMP -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_${source}_${date}.txt
	if [ $? == 0 ]
        then
                echo "`date '+%D %R'` Step-1 clamp completed"
	else
		echo "`date '+%D %R'` Step-1 clamp failed , check ./Logs/${env}/Step1_${source}_${date}.txt"
	fi

elif [ $source == "gsi" ]
then
	echo "$datetime gsi run on $environment"
	nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizeGSI -PflowType=harmonize -Pdhf.source=GSI -Pdhf.system=ERP -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_${source}_${date}.txt
	if [ $? == 0 ]
        then
                echo "`date '+%D %R'` Step-1 gsi completed"
	else
		echo "`date '+%D %R'` Step-1 gsi failed , check ./Logs/${env}/Step1_${source}_${date}.txt"
	fi

elif [ $source == "step2" ]
then
	echo "$datetime step-2 run on $environment"
	./gradlew step2Harmonization -PenvironmentName=${env} > ./Logs/${env}/Step2_${date}.txt
	if [ $? == 0 ]
        then
                echo "`date '+%D %R'` Step-2 completed"
	else
		echo "`date '+%D %R'` Step-2 failed , check ./Logs/${env}/Step2_${date}.txt"
	fi

elif [ $source == "all" ]
then
	echo "$datetime plm ,clamp ,gsi run on $environment"
	nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizePLM -PflowType=harmonize -Pdhf.source=PLM -Pdhf.system=PLM -Pdhf.load=full -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_plm_${date}.txt
        if [ $? == 0 ]
        then
                echo "`date '+%D %R'` Step-1 plm completed"	
		nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizeCLAMP -PflowType=harmonize -Pdhf.source=CLAMP -Pdhf.system=CLAMP -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_clamp_${date}.txt
		if [ $? == 0 ]
        	then
			echo "`date '+%D %R'` Step-1 clamp completed"
			nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizeGSI -PflowType=harmonize -Pdhf.source=GSI -Pdhf.system=ERP -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_gsi_${date}.txt
		 	if [ $? == 0 ]
                	then
				echo "`date '+%D %R'` Step-1 gsi completed"
				./gradlew step2Harmonization -PenvironmentName=${env} > ./Logs/${env}/Step2_${date}.txt
				if [ $? == 0 ]
				then
					echo "$datetime step-2 run on $environment"
				else
					echo "`date '+%D %R'` Step-2 failed , check ./Logs/${env}/Step2_${date}.txt"
				fi
			else
				 echo "`date '+%D %R'` Step-1 gsi failed , check ./Logs/${env}/Step1_gsi_${date}.txt"
			fi
		else
			echo "`date '+%D %R'` Step-1 clamp failed , ./Logs/${env}/Step1_clamp_${date}.txt"
		fi
	else
		echo "`date '+%D %R'` Step-1 plm failed , ./Logs/${env}/Step1_plm_${date}.txt"	
	fi
elif [ $source == "plmclamp" ]
then
	echo "plm ,clamp , step-2 on $environment"
	nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizePLM -PflowType=harmonize -Pdhf.source=PLM -Pdhf.system=PLM -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_plm_${date}.txt
        if [ $? == 0 ]
        then
                echo "`date '+%D %R'` Step-1 plm completed"
                nohup ./gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizeCLAMP -PflowType=harmonize -Pdhf.source=CLAMP -Pdhf.system=CLAMP -PshowOptions=true -PenvironmentName=${env} > ./Logs/${env}/Step1_clamp_${date}.txt
                if [ $? == 0 ]
                then
			 echo "`date '+%D %R'` Step-1 clamp completed"
                                ./gradlew step2Harmonization -PenvironmentName=${env} > ./Logs/${env}/Step2_${date}.txt
                                if [ $? == 0 ]
                                then
                                        echo "$datetime step-2 run on $environment"
                                else
                                        echo "`date '+%D %R'` Step-2 failed , check ./Logs/${env}/Step2_${date}.txt"
                                fi
		else
                        echo "`date '+%D %R'` Step-1 clamp failed , ./Logs/${env}/Step1_clamp_${date}.txt"
                fi
        else
                echo "`date '+%D %R'` Step-1 plm failed , ./Logs/${env}/Step1_plm_${date}.txt"
        fi

else
	echo "Error:input correct source"
	echo "Ex: harmonization.sh plm qual"
        echo "Ex: harmonization.sh clamp qual"
        echo "Ex: harmonization.sh gsi qual"
        echo "Ex: harmonization.sh step2 qual"
        echo "Ex: harmonization.sh all qual"
	echo "Ex: harmonization.sh plmclamp qual"
	exit
fi
