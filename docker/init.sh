    #! /bin/bash
    mongod --replSet $replicaName --bind_ip "0.0.0.0" 
    sleep 30
    mongosh --eval "rs.status()" &> result.txt
    if [ $(grep -c "no replset config" result.txt) -eq 1 ]; then
      mongosh --eval "rs.initiate( {
      _id : /"$replicaName/" ,
      members: [
          { _id: 0, host: /"$DBNAME-0.$DBDNS/" },
          { _id: 1, host: /"$DBNAME-1.$DBDNS/" },
          { _id: 2, host: /"$DBNAME-2.$DBDNS/" }
      ]
        })"
    fi
    wait < <(jobs -p)