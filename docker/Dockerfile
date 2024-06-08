# syntax=docker/dockerfile:1

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl lsof
RUN curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash
RUN cd /root/gaianet
RUN curl -LO https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/nodeid.json
RUN touch /root/gaianet/log/start-llamaedge.log

CMD tail -f /root/gaianet/log/start-llamaedge.log
