FROM python:3.10-alpine

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

EXPOSE 8000

COPY local.requirements.txt /opt/requirements.txt

RUN apk update && \
    apk add --no-cache \
        bash

RUN cd /opt/ && mkdir -p /opt/cc && python3 -m venv py && \
    /opt/py/bin/python3 -m pip install --upgrade pip && \
    /opt/py/bin/python3 -m pip install -r /opt/requirements.txt --no-build-isolation --disable-pip-version-check && \
    chmod -R 777 /opt && \
    mkdir -p /opt/cc/logs/app && \
    chmod 755 /opt/cc/logs

COPY ./compose/entrypoint /entrypoint
COPY ./compose/start /start
COPY ./compose/celery/worker/start /start-celeryworker
COPY ./compose/celery/beat/start /start-celerybeat
COPY ./compose/celery/flower/start /start-flower

RUN sed -i 's/\r$//g' /entrypoint && \
    sed -i 's/\r$//g' /start && \
    sed -i 's/\r$//g' /start-celeryworker && \
    sed -i 's/\r$//g' /start-celerybeat && \
    sed -i 's/\r$//g' /start-flower && \
    chmod +x /entrypoint && \
    chmod +x /start && \
    chmod +x /start-celeryworker && \
    chmod +x /start-celerybeat && \
    chmod +x /start-flower

ENV PATH="/opt/py/bin:$PATH"

COPY ./app /opt/сс/
WORKDIR /opt/сс/

ENTRYPOINT ["/entrypoint"]
