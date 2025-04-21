FROM docker.elastic.co/kibana/kibana:7.17.16

USER root
RUN mkdir -p /opt/setup
COPY setup.sh /opt/setup/setup.sh
COPY dashboard.ndjson /opt/setup/dashboard.ndjson
RUN chmod +x /opt/setup/setup.sh
USER kibana

CMD ["/opt/setup/setup.sh"]