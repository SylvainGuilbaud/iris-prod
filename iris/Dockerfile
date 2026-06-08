# ========= Base IRIS =========
ARG IMAGE=containers.intersystems.com/intersystems/iris:latest-em
FROM $IMAGE

COPY key/iris.key /usr/irissys/mgr/iris.key

WORKDIR /home/irisowner/dev
COPY . /home/irisowner/dev/

RUN --mount=type=bind,src=.,dst=. \
	iris start IRIS && \
	iris merge IRIS merge.cpf && \
	iris session IRIS < iris.script && \
	iris stop IRIS quietly