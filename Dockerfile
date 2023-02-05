ARG IMAGE=containers.intersystems.com/intersystems/iris-community:2022.3.0.606.0
FROM $IMAGE

USER root
## add git
RUN apt update && apt-get -y install git
        
WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

COPY requirements.txt requirements.txt
RUN  pip install -r requirements.txt

COPY src src
COPY iris.script iris.script

COPY iris-applications.yaml iris-applications.yaml
ENV ISC_IRIS_APPLICATIONS_FILE /opt/irisbuild/iris-applications.yaml

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
