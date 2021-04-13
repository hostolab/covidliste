# Introduction
This document contains development notes about the covidliste
application.

# Configuration
The application use the following environment variables:

| Name                  | Description                                                                         |
|-----------------------|-------------------------------------------------------------------------------------|
| `RAILS_ENV`           | The environment of the application (warning some behaviours are based on this value |
| `PORT`                | The application port to bind                                                        |
| `RAILS_LOG_TO_STDOUT` | Write application logs to stdout                                                    |
| `DATABASE_URL`        | The PostgreSQL databse url                                                          |
| `REDIS_URL`           | The Redis database url                                                              |
| `BLAZER_DATABASE_URL` | ??                                                                                  |
| `BLAZER_UPLOADS_URL`  | ??                                                                                  |

Geocoding configuration uses the following environment variables:

| Name             | Description                                 |
|------------------|---------------------------------------------|
| `PLACES_APP_ID`  | The Algolia places API application id       |
| `PLACES_API_KEY` | The Algolia places API authentication token |

E-Mail configuration uses the following environment variables:

| Name                 | Description                             |
|----------------------|-----------------------------------------|
| `SMTP_ADDRESS`       | The SMTP server address                 |
| `SMPT_PORT`          | The SMTP server submission port         |
| `SMTP_DOMAIN`        |                                         |
| `SMTP_USERNAME`      | The SMTP server authentication username |
| `SMTP_PASSWORD`      | The SMTP server authentication password |

E-Mail dashboard reports use the following environment variables:

| Name                 | Description                             |
|----------------------|-----------------------------------------|
| `SENDINBLUE_API_KEY` | The Sendinblue API authentication token |

Twilio configuration uses the following environment variables:

| Name                 | Description                         |
|----------------------|-------------------------------------|
| `TWILIO_ACCOUNT_SID` | The Twilio account id               |
| `TWILIO_AUTH_TOKEN`  | The Twilio API authentication token |

AppSignal configuration uses the following environment variables:

| Name                     | Description                                 |
|--------------------------|---------------------------------------------|
| `APPSIGNAL_PUSH_API_KEY` | The AppSignal push API authentication token |

Slack configuration uses the following environment variables:

| Name                         | Description                                                  |
|------------------------------|--------------------------------------------------------------|
| `SLACK_INCOMING_WEBHOOK_URL` | The webhook URL to send message on the covidliste slack team |
