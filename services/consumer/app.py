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
BS_SERVERS = ["kafka:9092"]
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
                enable_auto_commit=True,
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
for message in consumer:
    try:
        data = message.value
        logging.info(f"Consumer received: {data}")

        device_id = data["device_id"]
        temp = float(data.get("temperature", 0))
        hum = float(data.get("humidity", 0))

        if not device_id:
            logging.error("Missing device_id in message")
            continue

        registry = CollectorRegistry()
        temp_metric = Gauge(
            "iot_device_temperature",
            "Temperature in Celcius",
            ["device_id"],
            registry=registry,
        )
        hum_metric = Gauge(
            "iot_device_humidity",
            "Humidity in Percent",
            ["device_id"],
            registry=registry,
        )

        temp_metric.labels(device_id=device_id).set(temp)
        hum_metric.labels(device_id=device_id).set(hum)

        push_to_gateway(PG_ADDRESS, job="iot_kafka_consumer", registry=registry)
        logging.info(f"Pushed to Prometheus: temp={temp}, hum={hum}")

    except (ValueError, KeyError) as data_error:
        logging.warning(
            f"Invalid message format: {data_error} - Raw message: {message.value}"
        )

    except KafkaError as kafka_error:
        logging.error(f"Kafka error: {kafka_error}")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
