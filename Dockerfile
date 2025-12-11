FROM golang:1.25.5-alpine3.23

USER app

COPY ./simple_time_service/* ./app/
EXPOSE 8080

ENTRYPOINT [ "go", "run", "./app/main.go" ]