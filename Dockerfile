FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/prp:latest
LABEL authors="ayunami2000"

COPY environment.yml /tmp/environment.yml
# RUN perl -ne 'm/(?:\n|^)name: +([^\n]+)/ && print "$1"' /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

RUN conda run --no-capture-output -n "torch-gpu-clip" python -m ipykernel install --user --name "torch-gpu-clip" --display-name "Python (torch-gpu-clip)"

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-o", "pipefail", "-c", "jupyter lab --port 8080 --no-browser --ip 0.0.0.0 --NotebookApp.password \"$(echo ${PASSWD:-mypasswd} | python -c 'from notebook.auth import passwd;print(passwd(input()))')\""]
