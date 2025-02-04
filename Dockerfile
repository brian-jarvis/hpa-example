ARG TAG
ARG GO_VERSION
FROM golang:1.17-alpine as builder
ENV XDG_CACHE_HOME /tmp/.cache
WORKDIR /app
LABEL maintainer="Byron Collins <byronical@gmail.com>"
# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

COPY main.go .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

######## Start a new stage from scratch #######
## FROM scratch
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
LABEL maintainer="Byron Collins <byronical@gmail.com>" \
      go_version="1.17"


WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port 8080 to the outside world
EXPOSE 8080
USER 226655

# Command to run the executable
CMD ["./main"] 
