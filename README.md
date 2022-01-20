# README

<img src="./scoutplan_logo.png" width="150"/>



## Application Performance

[![View performance data on Skylight](https://badges.skylight.io/problem/O56zZFqqFZWO.svg)](https://oss.skylight.io/app/applications/O56zZFqqFZWO)
[![View performance data on Skylight](https://badges.skylight.io/typical/O56zZFqqFZWO.svg)](https://oss.skylight.io/app/applications/O56zZFqqFZWO)
[![View performance data on Skylight](https://badges.skylight.io/rpm/O56zZFqqFZWO.svg)](https://oss.skylight.io/app/applications/O56zZFqqFZWO)
[![View performance data on Skylight](https://badges.skylight.io/status/O56zZFqqFZWO.svg)](https://oss.skylight.io/app/applications/O56zZFqqFZWO)

## Assumptions & pre-reqs

* You have a FontAwesome kit defined

* You have an Adobe Fonts kit defined

* Docker & docker-compose installed

* Mapbox account


## Set up local HTTPS

Docker-compose includes Caddy for serving the app through TLS locally.

See https://codewithhugo.com/docker-compose-local-https/ for inspiration

* `brew install mkcert`

* `mkcert -install`

* add to /etc/hosts: `127.0.0.1 local.scoutplan.org`

## Rails credentials

* twilio.account_sid (requires a Twilio account)
* twilio.auth_token

## ENV vars (.env in dev, K8S in production as described below)

### Secrets (stored as Kubernetes secrets)

* DATABASE_PASSWORD
* DO_STORAGE_SECRET (S3-compatible storage at Digital Ocean)
* MAPBOX_TOKEN (requires a Mapbox account)
* RAILS_MASTER_KEY
* SECRET_KEY_BASE (generated by Rails)
* SENTRY_DSN (requires a Sentry.io subscription)
* SKYLIGHT_AUTHENTICATION (requires a Skylight subscription)
* SMTP_PASSWORD

### Config vars (stored as Kubernetes configmap)

* ADOBE_KIT_ID (aka Typekit...requires an Adobe subscription)
* APP_HOST (e.g. my.app.com)
* DATABASE_HOST (expects a Postgres server)
* DATABASE_NAME
* DATABASE_PORT
* DATABASE_USER
* DO_BUCKET
* DO_STORAGE_ENDPOINT
* DO_STORAGE_KEY_ID
* DO_STORAGE_REGION
* FONT_AWESOME_KIT_ID (requires a Fontawesome subscription)
* RAILS_ENV
* RAILS_SERVE_STATIC_FILES (set to true in production)
* REDIS_URL
* SKYLIGHT_ENABLED (set to true in production)
* SMTP_ADDRESS
* SMTP_DOMAIN
* SMTP_PORT
* SMTP_USERNAME
* TWILIO_NUMBER
* TWILIO_SID

## Docker Compose

Create docker-compose.override.yml in the project root and populate thusly:

```
services:
  db:
    image: postgres:13-alpine
    command: ["postgres", "-c", "fsync=false", "-c", "full_page_writes=off"]
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - ./tmp/db:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  app:
    depends_on:
      - db
```

Tag and push the image to DO...

```
docker tag scoutplan_app registry.digitalocean.com/scoutplan/scoutplan_app
docker push registry.digitalocean.com/scoutplan/scoutplan_app
```

## Email in development

The Docker Compose stack includes mailcatcher. Once the stack's up, visit http://localhost:1080 to see your mail


## Flipper

Some features are gated by Flipper and need to be enabled:

* :daily_reminder
* :receive_event_publish_notice
* :receive_bulk_publish_notice
* :receive_rsvp_confirmation
* :receive_digest
* :receive_daily_reminder

## Code Conventions

We're using Tailwind for styling, which results in potentially lots of classes for a single element. For elements
containing more than, let's say, four classes, we're adopting the following convention when using a Rails helper:

* Use string continuation (\) to categorically organize classes across multiple lines
* Spaces belong at the start of each line, except the first
* Place the ending comma on its own line along with an empty string (can be omitted if `class` is the last argument)
* Gang variations together (e.g. color and hover:color) on their own lines
* Order categories thusly:

1. Font and text
1. Display: block, inline, flex, etc.
1. Layout: padding, margins, width, min-width, etc.
1. Background colors
1. Foreground colors
1. Other appearance classes (e.g. borders, rounded, etc.)

Example:
```
class:  "text-sm font-bold no-underline tracking-wider uppercase text-center" \
        " hidden md:inline-block" \
        " px-6 py-3 mr-2" \
        " bg-scoutplan-100 hover:bg-scoutplan-200" \
        " text-scoutplan-500 hover:text-scoutplan-600" \
        "",
```

In the case of non-helper Slim elements, up to four classes can be specified inline:

```
header.px-6.py-4.overflow-auto.sticky
```

Elements needing more than four elements should be specified using Slim attribute notation (note use of ugly Slim comment
to straighten out code coloring):

```
header(class="px-6 py-4 \
              overflow-auto sticky \
              top-0 bg-white z-50")

  // " <- necessary evil comment to restore proper code highlighting in VS Code
```