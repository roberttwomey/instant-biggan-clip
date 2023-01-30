FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/prp:latest
LABEL authors="ayunami2000"

COPY environment.yml /tmp/environment.yml
# RUN perl -ne 'm/(?:\n|^)name: +([^\n]+)/ && print "$1"' /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

SHELL ["/opt/conda/bin/conda", "run", "--no-capture-output", "-n", "torch-gpu-clip", "/bin/bash", "-o", "pipefail", "-c"]

RUN python -m ipykernel install --user --name "torch-gpu-clip" --display-name "Python (torch-gpu-clip)"

EXPOSE 8080

CMD echo "c.NotebookApp.password=\"$(echo ${PASSWD:-mypasswd} | python -c 'from notebook.auth import passwd;print(passwd(input()))')\"" >> /home/jovyan/.jupyter/jupyter_notebook_config.py

ENTRYPOINT ["jupyter", "lab", "--port", "8080", "--no-browser", "--ip", "0.0.0.0"]
