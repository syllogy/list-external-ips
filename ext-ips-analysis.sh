#!/bin/bash

echo "Project	Instance_Name	External_Ip	Is_Preemptible	Monthly_Cost" > projectsIPs.csv

while read project_to_list_ips; do
	COMPUTE_API_ENABLED=$(gcloud services list --project=$project_to_list_ips | grep compute.googleapis.com | wc -l)
	if [ "$COMPUTE_API_ENABLED" -eq "1" ] 
	then
		gcloud compute instances list --flatten="networkInterfaces[].accessConfigs[]" --filter="networkInterfaces.accessConfigs.natIP:*" --format="value(name, networkInterfaces.accessConfigs.natIP, scheduling.preemptible)" --project $project_to_list_ips > temp.csv	
		sed -i -e "s/^/$project_to_list_ips	/" temp.csv	
	fi
	cat temp.csv >> projectsIPs.csv
done <projects
rm temp.csv

INSTANCE_LINE=1
while read instance; do
	if [ "$INSTANCE_LINE" -eq "1" ]
	then
		((INSTANCE_LINE=INSTANCE_LINE+1))
		continue
	fi
	IS_PREEMTIBLE=$(echo $instance | awk '{ print $4 }')
	if [ "$IS_PREEMTIBLE" != "true" ]
	then
		INSTANCE_LINE_S="${INSTANCE_LINE}s"
		if [ $(uname) == "Darwin" ]
		then
			sed -i '' "$INSTANCE_LINE_S/	/	false/3" projectsIPs.csv
		else
			sed -i "$INSTANCE_LINE_S/	/	false/3" projectsIPs.csv
		fi
	fi
	((INSTANCE_LINE=INSTANCE_LINE+1))
done <projectsIPs.csv

if [ $(uname) == "Darwin" ]
then
	sed -i '' "s/false/false	2.92/" projectsIPs.csv
	sed -i '' "s/true/true	1.46/" projectsIPs.csv
else
	sed "s/false/false	2.92/" projectsIPs.csv
	sed "s/true/true	1.46/" projectsIPs.csv
fi

