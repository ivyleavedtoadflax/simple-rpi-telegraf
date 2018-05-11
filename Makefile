PWD = $(shell pwd)
LOG_SIZE=10m

all: telegraf.conf monitor

telegraf.conf: telegraf.template.conf .envrc Makefile
	echo "Creating telegraf.conf file"; \
	sed -e "s/\$${DATABASE}/$(DATABASE)/" \
	-e "s%\$${INFLUXDB_HOST}%$(INFLUXDB_HOST)%" \
	-e "s/\$${INFLUXDB_PORT}/$(INFLUXDB_PORT)/" \
	-e "s/\$${INTERVAL}/$(INTERVAL)/" \
	-e "s/\$${HOSTNAME}/$(HOSTNAME)/" \
	telegraf.template.conf > telegraf.conf

monitor: telegraf.conf
	sudo docker run \
	--log-opt max-size=${LOG_SIZE} \
	-d --restart unless-stopped \
	-v $(PWD)/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
	-v /data:/data:ro \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	--name monitor \
	-it bradsjm/rpi-telegraf:latest

clean:
	-sudo docker stop monitor
	-sudo docker rm monitor

help:
	@cat Makefile

.PHONY: clean help
