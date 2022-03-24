FROM osgeo/gdal:ubuntu-full-3.4.2

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      # For Psycopg2
      libpq-dev python3-dev \
      python3-pip \
      wget \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

COPY requirements.txt /conf/
RUN pip3 install --no-cache-dir --requirement /conf/requirements.txt

RUN cd /tmp \
  && git clone --depth 1 https://github.com/digitalearthafrica/deafrica-sandbox-notebooks.git \
  && cd deafrica-sandbox-notebooks \
  pip install Tools \
  rm -R Tools .git .github .gitignore DEAfrica_notebooks_template.ipynb README.md \
  mkdir /notebooks && cp -r . /notebooks

WORKDIR /notebooks

ENTRYPOINT ["/tini", "--"]

CMD ["jupyter", "notebook", "--allow-root", "--ip='0.0.0.0'", "--NotebookApp.token='secretpassword'"]
