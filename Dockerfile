FROM busybox:latest

WORKDIR /

COPY cploader2image.sh .
RUN  ["./cploader2image.sh"]
