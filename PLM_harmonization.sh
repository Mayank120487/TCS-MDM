#!/usr/bin/ksh

if [ $# -eq 0 ] || [ $# -gt 3 ] || [ $# -eq 1 ] || [ $# -eq 2 ]
then	
	echo "Info: run a script as following <script name> <source> <load> <environment>"
	echo "Ex: harmonization.sh plm delta qual"
	exit
fi

source=`echo $1 | tr '[:upper:]' '[:lower:]'`
load=`echo $2 | tr '[:upper:]' '[:lower:]'`
env=`echo $3 | tr '[:upper:]' '[:lower:]'`
path='/ML-Config/SDH/PF/Alstom-DHF-Proj'

date=`date +%s`
datetime=`date '+%D %R'`

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
	${path}/gradlew hubRunLegacyFlow -PentityName=GoldenPart -PflowName=harmonizePLM -PflowType=harmonize -Pdhf.source=PLM -Pdhf.system=PLM -Pdhf.load=${load} -PshowOptions=true -PenvironmentName=${env} > ${path}/Logs/${env}/Step1_${source}_${date}.txt 
	if [ $? == 0 ]
	then
		echo "`date '+%D %R'` Step-1 plm completed"
		${path}/gradlew step2Harmonization -PenvironmentName=${env} > ${path}/Logs/${env}/Step2_PF_${date}.txt
		if [ $? == 0 ]
		then
			echo "`date '+%D %R'` Step-2 PF completed"
			echo "`date '+%D %R'` Step-2 PC started"
			${path}/gradlew step2HarmonizationPC -PenvironmentName=${env} > ${path}/Logs/${env}/Step2_PC_${date}.txt
			if [ $? == 0 ]
			then
				echo "`date '+%D %R'` Step-2 PC completed"
			else
				echo "`date '+%D %R'` Step-2 PC failed , check ${path}/Logs/${env}/Step2_PC_${date}.txt"
			fi
		else
			echo "`date '+%D %R'` Step-2 PF failed , check ${path}/Logs/${env}/Step2__PF_${date}.txt"
		fi
	else
		echo "`date '+%D %R'` Step-1 plm failed , check ${path}/Logs/${env}/Step1_${source}_${date}.txt"
		exit
	fi
else
	echo "Error:input correct source,applicable only for PLM"
	echo "Ex: harmonization.sh plm qual"
	exit
fi
