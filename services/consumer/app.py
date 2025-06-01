import json
import logging
import time

from kafka import KafkaConsumer
from kafka.errors import KafkaError, NoBrokersAvailable
from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)

KAFKA_TOPIC = "iot-sensor-data"
BS_SERVERS = ["kafka.dev.svc.cluster.local:9092"]
PG_ADDRESS = "pushgateway-prometheus-pushgateway:9091"

MAX_KAFKA_RETRIES = 5
RETRY_WAIT = 5


def create_consumer():
    for attempt in range(1, MAX_KAFKA_RETRIES + 1):
        try:
            logging.info(f"Connecting to kafka (attempt {attempt})..")
            consumer = KafkaConsumer(
                KAFKA_TOPIC,
                bootstrap_servers=BS_SERVERS,
                auto_offset_reset="earliest",
                enable_auto_commit=False,
                group_id="sensor-group",
                value_deserializer=lambda x: json.loads(x.decode("utf-8")),
            )
            logging.info("Kafka consumer connected.")
            return consumer
        except NoBrokersAvailable as e:
            logging.error(f"No Kafka brokers available: {e}")
            time.sleep(RETRY_WAIT)

    logging.critical("Could not connect to Kafka after multiple attempts.")
    exit(1)


consumer = create_consumer()

logging.info("Entering polling loop...")

try:
    while True:
        records = consumer.poll(timeout_ms=2000)
        if not records:
            logging.info("No messages in this poll cycle.")
            time.sleep(1)
            continue

        for tp, messages in records.items():
            for message in messages:
                try:
                    data = message.value
                    logging.info(f"Received: {data}")

                    device_id = data.get("device_id")
                    if not device_id:
                        logging.error("Missing device_id")
                        continue

                    temp = float(data.get("temperature", 0))
                    hum = float(data.get("humidity", 0))

                    registry = CollectorRegistry()
                    temp_metric = Gauge(
                        "iot_device_temperature",
                        "Temp °C",
                        ["device_id"],
                        registry=registry,
                    )
                    hum_metric = Gauge(
                        "iot_device_humidity",
                        "Humidity %",
                        ["device_id"],
                        registry=registry,
                    )

                    temp_metric.labels(device_id=device_id).set(temp)
                    hum_metric.labels(device_id=device_id).set(hum)

                    push_to_gateway(
                        PG_ADDRESS, job="iot_kafka_consumer", registry=registry
                    )
                    logging.info(f"Pushed to Prometheus: temp={temp}, hum={hum}")

                    consumer.commit()  # mark as processed

                except Exception as e:
                    logging.error(f"Error processing message: {e}")

except KeyboardInterrupt:
    logging.info("Shutting down consumer...")
    consumer.close()
