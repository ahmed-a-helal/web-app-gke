#! /bin/bash
eval $@ &
VALID_ARGS=$(getopt -q --long port:,replSet: -- "$@")
eval set -- "$VALID_ARGS"
PORT="27017"
while :
do 
  case "$1" in
    --replSet )
      replicaName=$2
      shift 2 
    ;;
    --port )
      PORT=$2
      shift 2 
    ;;
    --) 
    shift
    break; 
    ;;
  esac
done
DBDNS="$(domainname -d)"
DBNAME="$(domainname -a)"
DBNAMECOMMON="${DBNAME%-*}"
sleep 10
if [ -n "$replicaName" ];then
  mongosh "mongodb://$DBNAME.$DBDNS:$PORT/" --eval "rs.status()" &> result.txt
  if [ $(grep -c "no replset config" result.txt) -eq 1 ]; then
    mongosh "mongodb://$DBNAME.$DBDNS:$PORT/" --eval "
        rs.initiate( {_id : \"$replicaName\", members: [
        { _id: 0, host: \"$DBNAMECOMMON-0.$DBDNS:$PORT\" },
        { _id: 1, host: \"$DBNAMECOMMON-1.$DBDNS:$PORT\" },
        { _id: 2, host: \"$DBNAMECOMMON-2.$DBDNS:$PORT\" }
        ]})"
  fi
fi
sleep 40
MONGO_INITDB_ROOT_USERNAME=$(echo $MONGO_INITDB_ROOT_USERNAME| sed 's/ *$//')
MONGO_INITDB_ROOT_PASSWORD=$(echo $MONGO_INITDB_ROOT_PASSWORD| sed 's/ *$//')
mongosh "mongodb://$DBNAME.$DBDNS:$PORT/admin" --eval "db.createUser({ user: \"${MONGO_INITDB_ROOT_USERNAME}\" , pwd: \"${MONGO_INITDB_ROOT_PASSWORD}\", roles: [\"root\"] })"
wait < <(jobs -p)