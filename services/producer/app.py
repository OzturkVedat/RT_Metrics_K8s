from flask import Flask, Response
import time
import random
import prometheus_client
from prometheus_client import Gauge

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
        time.sleep(5)


if __name__ == "__main__":
    from threading import Thread

    Thread(target=generate_metrics).start()
    app.run(host="0.0.0.0", port=5000)
