#!/bin/bash

VALID_ARGS=$(getopt -o n:z:c:r:p:R:D:K:H:w:d:a: --long node:,zone:,cluster:,region:,project:,registry:,dockerdir:,kubernetisdir,helmdir:,webimage:,databaseimage:,alpineimage: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while :
do 
  case "$1" in
    -c | --cluster)
        CLUSTER_NAME=$2
        shift 2
        ;;
    -r | --region)
        REGION=$2
        shift 2
        ;;
    -z | --zone)
        ZONE=$2
        shift 2
        ;;
    -p | --project)
        PROJECT=$2
        shift 2
        ;;
    -R | --registry)
        REGISTRY=$2
        shift 2
        ;;
    -D | --dockerdir)
        DOCKERDIR=$2
        shift 2
        ;;
    -K | --kubernetisdir)
        KUBEDIR=$2
        shift 2
        ;;
    -H | --helmdir)
        HELMDIR=$2
        shift 2
        ;;
    -n | --node)
        NODE=$2
        shift 2
        ;;
    -d | --databaseimage)
        DATABASEIMAGE=$2
        shift 2
        ;;
    -w | --webimage)
        WEBIMAGE=$2
        shift 2
        ;;
    -a | --alpineimage)
        ALPINEIMAGE=$2
        shift 2
        ;;
    --) shift; 
        break 
        ;;
  esac
done
gcloud compute scp --recurse  --zone "$ZONE" --tunnel-through-iap --project "$PROJECT"  $KUBEDIR $DOCKERDIR $HELMDIR "$NODE":/tmp
gcloud compute ssh  --zone "$ZONE" --tunnel-through-iap --project "$PROJECT" "$NODE" --command " gcloud container clusters get-credentials --region \"$REGION\" --project \"$PROJECT\" \"$CLUSTER_NAME\" &&\
    sudo gcloud auth configure-docker ${REGISTRY/%\/*} -q &&\
    sudo docker build /tmp/$DOCKERDIR -f /tmp/$DOCKERDIR/Dockerfile-web -t $REGISTRY/$WEBIMAGE&&\
    sudo docker push $REGISTRY/$WEBIMAGE &&\
    sudo docker build /tmp/$DOCKERDIR -f /tmp/$DOCKERDIR/Dockerfile-mongo -t $REGISTRY/$DATABASEIMAGE &&\
    sudo docker push $REGISTRY/$DATABASEIMAGE &&\
    sudo docker build /tmp/$DOCKERDIR -f /tmp/$DOCKERDIR/Dockerfile-alpine -t $REGISTRY/$ALPINEIMAGE &&\
    sudo docker push $REGISTRY/$ALPINEIMAGE &&\
    { [ -n \"$HELMDIR\" ] && echo -e \"MongoImage: $REGISTRY/${DATABASEIMAGE%:*}\nAppImageTag: ${DATABASEIMAGE/#*:}\nAppImage: $REGISTRY/${WEBIMAGE%:*}\nAppImageTag: ${WEBIMAGE/#*:}\nInitImage: $REGISTRY/${ALPINEIMAGE%:*}\nInitImageTag: ${ALPINEIMAGE/#*:}\">/tmp/images.yaml &&\
    helm install --values  /tmp/images.yaml gke-iti-project  /tmp/$HELMDIR || helm upgrade --values  /tmp/images.yaml gke-iti-project  /tmp/$HELMDIR;  }||\
    { [ -n \"$KUBEDIR\" ] && kubectl apply -f /tmp/$KUBEDIR; } || true"