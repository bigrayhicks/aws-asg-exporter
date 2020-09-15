FROM --platform=$BUILDPLATFORM golang:1.15

ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
ENV GO111MODULE=on
WORKDIR /go/src/github.com/wish/aws-asg-exporter

# Cache dependencies
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . /go/src/github.com/wish/aws-asg-exporter/
RUN CGO_ENABLED=0 GOARCH=${TARGETARCH} GOOS=${TARGETOS} go build -o exporter -a -installsuffix cgo .

FROM alpine:3.12
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /go/src/github.com/wish/aws-asg-exporter/exporter /root/exporter
CMD /root/exporter
