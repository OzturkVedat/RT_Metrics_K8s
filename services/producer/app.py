import logging
import time
import random
import json

from kafka import KafkaProducer
from kafka.errors import KafkaError, NoBrokersAvailable

logging.Formatter.converter = time.localtime
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)

BS_SERVERS = ["kafka.dev.svc.cluster.local:9092"]
KAFKA_TOPIC = "iot-sensor-data"

MAX_PROD_CON_RETRIES = 6
MAX_SEND_RETRIES = 5
RETRY_WAIT = 10


def create_producer():
    for attempt in range(1, MAX_PROD_CON_RETRIES + 1):
        try:
            logging.info(f"Connecting to kafka (attempt {attempt})..")
            producer = KafkaProducer(
                bootstrap_servers=BS_SERVERS,
                value_serializer=lambda v: json.dumps(v).encode("utf-8"),
                retries=MAX_SEND_RETRIES,
                linger_ms=10,
                request_timeout_ms=30000,
            )
            logging.info("Kafka producer connected")
            return producer
        except NoBrokersAvailable as e:
            logging.error(f"Kafka not available: {e}")
            time.sleep(RETRY_WAIT)

    logging.critical("Failed to connect to Kafka after multiple attempts.")
    exit(1)


producer = create_producer()


def gen_fake_sensor_data():
    return {
        "device_id": "sensor-001",
        "temperature": round(random.uniform(20.0, 30.0), 2),
        "humidity": round(random.uniform(40.0, 70.0), 2),
        "timestamp": time.time(),
    }


while True:
    try:
        data = gen_fake_sensor_data()
        future = producer.send(KAFKA_TOPIC, value=data)
        record_metadata = future.get(timeout=10)

        logging.info(
            f"Data sent: {data} -> partition {record_metadata.partition}, offset {record_metadata.offset}"
        )
        time.sleep(5)

    except KeyboardInterrupt:
        logging.info("Shutdown requested. Flushing and closing producer...")
        producer.flush()
        producer.close()
        logging.info("Producer shutdown complete.")
    except KafkaError as ke:
        logging.error(f"Kafka error during send: {ke}")
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
