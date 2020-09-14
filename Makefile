all: build

build:
	docker build --no-cache --build-arg VERSION=$(VERSION) \
		-t ckatsak/iperf3:$(VERSION) .
	docker image prune -f

run-server: build
	-docker run -it --rm -p 55000:55000 ckatsak/iperf3:$(VERSION)

clean:
	-docker rmi ckatsak/iperf3:$(VERSION)
	docker image prune -f

.PHONY: all build run-server clean
