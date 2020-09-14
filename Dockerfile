FROM debian:bullseye-slim as builder
ARG VERSION=3.9
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -qq \
		--no-install-recommends \
		git ca-certificates gcc libc-dev make \
	&& git clone https://github.com/esnet/iperf.git \
	&& cd iperf \
	&& git checkout $VERSION \
	&& mkdir -vp /iperf3-$VERSION-build \
	&& ./configure --prefix=/iperf3-$VERSION-build --enable-static-bin \
	&& make -j $(nproc) \
	&& make install \
	&& strip /iperf3-$VERSION-build/bin/iperf3 \
	&& rm -vrf /tmp/*


FROM scratch
ARG VERSION=3.9
LABEL maintainer="ckatsak@cslab.ece.ntua.gr" version=$VERSION port="55000"

COPY --from=builder /iperf3-$VERSION-build/bin/iperf3 /iperf3
### NOTE(ckatsak): [This](https://stackoverflow.com/a/50164749) is probably
###                still true, so let's include an empty /tmp.
COPY --from=builder /tmp /tmp

EXPOSE 55000

ENTRYPOINT [ "/iperf3" ]
CMD [ "--server", "--port", "55000" ]


### Deploy as a server:
###   $ docker run -it --rm -p 55000:55000 ckatsak/iperf3:$VERSION
### Deploy as a client:
###   $ docker run -it --rm ckatsak/iperf3:$VERSION --client <ip-addr-only> \
###             --port 55000 --time 5 --length --zerocopy --json
