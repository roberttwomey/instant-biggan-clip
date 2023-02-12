FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/prp:latest
LABEL authors="ayunami2000"

COPY environment.yml /tmp/environment.yml
# RUN perl -ne 'm/(?:\n|^)name: +([^\n]+)/ && print "$1"' /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

RUN conda run --no-capture-output -n "torch-gpu-clip" python -m pip install torch==1.7.1+cu101 torchvision==0.8.2+cu101 -f https://download.pytorch.org/whl/torch_stable.html

RUN conda run --no-capture-output -n "torch-gpu-clip" python -m ipykernel install --user --name "torch-gpu-clip" --display-name "Python (torch-gpu-clip)"

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-o", "pipefail", "-c", "source activate torch-gpu-clip && jupyter lab --port 8080 --no-browser --ip 0.0.0.0 --NotebookApp.password \"$HASHED_PASSWD\""]
