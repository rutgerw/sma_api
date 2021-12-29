FROM ruby:3.0.3-alpine3.15

RUN apk add make gcc musl-dev

RUN addgroup -S app && adduser -S app -G app

USER app
WORKDIR /tmp/bundle
COPY --chown=app:app . /tmp/bundle/
RUN bundle install

WORKDIR /app
COPY . /app/

ENTRYPOINT [ "ash" ]
