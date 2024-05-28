FROM ruby:3.2-alpine

RUN apk add make gcc musl-dev

RUN addgroup -S app && adduser -S app -G app
USER app

WORKDIR /tmp/bundle
COPY . /tmp/bundle/
RUN bundle install

WORKDIR /app
COPY . /app/

ENTRYPOINT [ "ash" ]
