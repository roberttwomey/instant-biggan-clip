FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/prp:latest
LABEL authors="ayunami2000"

ARG CONDA_ENV_NAME=torch-gpu-clip

COPY environment.yml /tmp/environment.yml
# RUN perl -ne 'm/(?:\n|^)name: +([^\n]+)/ && print "$1"' /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

SHELL ["conda", "run", "--no-capture-output", "-n", "${CONDA_ENV_NAME}", "/bin/bash", "-o", "pipefail", "-c"]

RUN python -m ipykernel install --user --name "${CONDA_ENV_NAME}" --display-name "Python (${CONDA_ENV_NAME})"

EXPOSE 8080

CMD echo "c.NotebookApp.password=\"$(echo ${PASSWD:-mypasswd} | python -c 'from notebook.auth import passwd;print(passwd(input()))')\"" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

ENTRYPOINT ["jupyter", "lab", "--port", "8080", "--no-browser", "--ip", "0.0.0.0"]
