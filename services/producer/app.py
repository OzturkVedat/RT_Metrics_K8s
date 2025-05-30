from flask import Flask, Response
import time
import random
import prometheus_client
from prometheus_client import Gauge
import logging

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
app = Flask(__name__)

cpu_usage = Gauge("app_cpu_usage_perc", "Simulated CPU usage")
mem_usage = Gauge("app_mem_usage_perc", "Simulated memory usage")


@app.route("/")
def home():
    return "Producer service is running.."


@app.route("/metrics")
def metrics():
    return Response(prometheus_client.generate_latest(), mimetype="text/plain")


def generate_metrics():
    while True:
        cpu = random.uniform(0, 100)
        mem = random.uniform(100, 1000)
        cpu_usage.set(cpu)
        mem_usage.set(mem)
        logging.info(f"Simulated CPU: {cpu:.2f}% | Memory: {mem:.2f}MB")
        time.sleep(5)


if __name__ == "__main__":
    from threading import Thread

    logging.info("Starting metric generation thread...")
    Thread(target=generate_metrics).start()

    logging.info("Starting Flask app on 0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000)
