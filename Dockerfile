FROM golang:1.25.5-alpine3.23

COPY ./simple_time_service/* ./app/
EXPOSE 8081
ENTRYPOINT [ "go", "run", "./app/main.go" ]