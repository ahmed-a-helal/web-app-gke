#!/bin/bash

VALID_ARGS=$(getopt -o n:z:c:r:p:R:D:K:w:d: --long node:,zone:,cluster:,region:,project:,registry:,dockerfolder:,kubernetisfolder:,webimage:,databaseimage: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while :
do 
  case "$1" in
    -c | --cluster)
        echo CLUSTER_NAME=$2
        CLUSTER_NAME=$2
        shift 2
        ;;
    -r | --region)
        echo REGION=$2
        REGION=$2
        shift 2
        ;;
    -z | --zone)
        echo ZONE=$2
        ZONE=$2
        shift 2
        ;;
    -p | --project)
        echo PROJECT=$2
        PROJECT=$2
        shift 2
        ;;
    -R | --registry)
        echo REGISTRY=$2
        REGISTRY=$2
        shift 2
        ;;
    -D | --dockerfolder)
        echo DOCKERFOLDER=$2
        DOCKERFOLDER=$2
        shift 2
        ;;
    -K | --kubernetisfolder)
        echo KUBERNETISFOLDER=$2
        KUBERNETISFOLDER=$2
        shift 2
        ;;
    -n | --node)
        echo NODE=$2
        NODE=$2
        shift 2
        ;;
    -d | --databaseimage)
        echo DATABASEIMAGE=$2
        DATABASEIMAGE=$2
        shift 2
        ;;
    -w | --webimage)
        echo WEBIMAGE=$2
        WEBIMAGE=$2
        shift 2
        ;;
    --) shift; 
        break 
        ;;
  esac
done
#gcloud container clusters get-credentials ${local.gke_cluster.name} --region ${data.google_compute_subnetwork.gke_subnet.region} --project ${data.google_compute_subnetwork.gke_subnet.project}
gcloud compute ssh  --zone "$ZONE" --tunnel-through-iap --project "$PROJECT" "$NODE" --command "gcloud container clusters get-credentials --region \"$REGION\" --project \"$PROJECT\" \"$CLUSTER_NAME\"" 
gcloud compute scp --recurse  --zone "$ZONE" --tunnel-through-iap --project "$PROJECT"  $KUBERNETISFOLDER $DOCKERFOLDER "$NODE":/tmp
gcloud compute ssh  --zone "$ZONE" --tunnel-through-iap --project "$PROJECT" "$NODE" --command " sudo gcloud auth configure-docker ${REGISTRY/%\/*} -q &&\
    sudo docker build /tmp/$DOCKERFOLDER -f /tmp/$DOCKERFOLDER/Dockerfile-web -t $REGISTRY/$WEBIMAGE&&\
    sudo docker push $REGISTRY/$WEBIMAGE &&\
    sudo docker build /tmp/$DOCKERFOLDER -f /tmp/$DOCKERFOLDER/Dockerfile-mongo -t $REGISTRY/$DATABASEIMAGE &&\
    sudo docker push $REGISTRY/$DATABASEIMAGE &&\
    kubectl apply -f /tmp/manifests"
# ./scripts/container_startup.sh  --zone "europe-west8-b" --project "ahmed-attia-iti"  --dockerfolder "docker" --kubernetisfolder "manifests"  --node "iti-webapp-project-managment-node"  --region "europe-west1" --cluster "iti-webapp-project-cluster"