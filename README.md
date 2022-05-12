#  Debezium Outbox Demo

## Build and Run

1. Start the docker compose file

```shell
docker compose up
```

2. Register the debezium kafka connector

```shell
./register_connector.sh
```

3. Insert data into database and check kafka UI for new topics and messages

```shell
docker exec -it mysql bash
mysql -u root -p <PASSWORD=debezium>
```

```shell
USE debezium;
INSERT INTO outbox (aggregatetype, aggregateid, type, payload) VALUES ("customer", "1", "customer_created", '{"name": "foo", "email": "foo@bar.com"}');
```

4. Check topics via kafka UI

```shell
http://localhost:8888
```

Here you should see a new topic created by debezium called _outbox.event.customer_ with a message containing the
above mentioned payload.

5. Do another INSERT on the same outbox table with another aggregatetype

```shell
INSERT INTO outbox (aggregatetype, aggregateid, type, payload) VALUES ("payment", "1", "payment_completed", '{"name": "foo", "email": "foo@bar.com"}');
```

6. Again check topics via kafka UI

Here you should see another new topic created by debezium called _outbox.event.payment_ with a message containing the 
above mentioned payload.

## Whats happening?

1. The docker compose will spin up the following services:

    - zookeeper
    - kafka
    - kafka-ui
    - kafka connect service with debezium

2. The following connector will be registered at the kafka connect service:

```json
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
        }
```

Here we use the MySqlConnector from Debezium to catch database events from a MySql database. Also we use an Outbox 
EventRouter provided by Debezium. This EventRouter will create a custom topics based on the aggregatetype we defined 
above in our INSERT statements. The naming notation for the topics created by Debezium are:

```shell
<connector-config-transforms-value>.event.<aggregatetype>
```
