FROM alpine

RUN apk update \
 && apk upgrade \
 && mkdir -p /app 

RUN apk add --update \
		bash \
		wget \
		coreutils \
		openssl

WORKDIR /app
ADD lco.sh /app
RUN chmod 755 lco.sh
CMD ./lco.sh --download
