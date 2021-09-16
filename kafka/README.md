# Kafka

### Start kafka

```
$ cd /usr/local/bin/kafka
$ sudo bin/zookeeper-server-start.sh config/zookeeper.properties
```

### Test that it's running

```
$ telnet 127.0.0.1 2181
```

### Start a single kafka broker

```
$ sudo bin/kafka-server-start.sh config/server.properties
```

Should see:

```
INFO Registered broker 0 at path ...
```

### Create a topic

```
$ bin/kafka-topics.sh \
    --create \
    --topic mytopic \
    --zookeeper 127.0.0.1:2181 \
    --replication-factor 1 \
    --partitions 1
```

### List topics available on the cluster

```
$ bin/kafka-topics.sh \
    --list \
    --zookeeper 127.0.0.1:2181
```

### Instantiate a producer

```
$ bin/kafka-console-producer.sh \
    --broker-list 127.0.0.1:9092 \
    --topic my_topic
[write messages here, as many as you'd like]
```

This writes to a pipe (?).

### Read the messages

```
$ bin/kafka-console-consumer.sh \
    --bootstrap-server 127.0.0.1:9092 \
    --topic my_topic \
    --from-beginning
```

