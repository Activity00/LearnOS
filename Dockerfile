FROM busybox:latest

WORKDIR /

COPY cploader2image_formac.sh .
RUN  ["./cploader2image.sh"]
