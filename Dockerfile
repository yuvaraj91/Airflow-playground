FROM apache/airflow:2.5.1-python3.9

ARG AIRFLOW_HOME_ARG=/opt/airflow
ENV AIRFLOW_HOME=${AIRFLOW_HOME_ARG}

USER airflow
# each folder in AIRFLOW_HOME can be used as import in python
ENV PYTHONPATH ${AIRFLOW_HOME}:$PYTHONPATH

# install extra requirements
COPY requirements-providers.txt /
RUN pip install --user --no-cache-dir -r /requirements-providers.txt
COPY requirements.txt /
RUN pip install --user --no-cache-dir -r /requirements.txt

# copy dags, plugins and utils after install requirementsto avoid to install requirements on each code change
# add always chwown to each COPY to make airflow the owner
COPY --chown=airflow:airflow dags ${AIRFLOW_HOME}/dags

WORKDIR ${AIRFLOW_HOME}
