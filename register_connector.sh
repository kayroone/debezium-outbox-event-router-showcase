#!/bin/bash

curl -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '
        {
          "name": "outbox-connector",
          "config": {
            "connector.class": "io.debezium.connector.mysql.MySqlConnector",
            "tasks.max": "1",
            "database.hostname": "mysql",
            "database.port": "3306",
            "database.user": "debezium",
            "database.password": "dbz",
            "database.server.id": "184054",
            "database.server.name": "dbserver1",
            "database.include.list": "debezium",
            "table.include.list": "debezium.outbox",
            "database.history.kafka.bootstrap.servers": "kafka:29092",
            "database.history.kafka.topic": "schema-changes.debezium",
            "database.allowPublicKeyRetrieval": "true",
            "tombstones.on.delete" : "false",
            "transforms": "outbox",
            "transforms.outbox.type": "io.debezium.transforms.outbox.EventRouter"
          }
        }'
