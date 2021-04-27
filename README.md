# Calendar Coordinator

A Web application that through the permissions of common calendars such as Google and Apple, compare the time and schedule a meeting.

## API Routes

All routes return JSON.

- GET `/`: Root route shows if Web API is running.

- GET `api/v1/calendars`: Get all calendars.
- GET `api/v1/calendars/{id}`: Get calendar by id.
- POST `api/v1/calendars`: Create calendar.

- GET `api/v1/calendars/{calendar_id}/events`: Get all events by calendar id.
- GET `api/v1/calendars/{calendar_id}/events/{event_id}`: Get event by calendar id and event id.
- POST `api/v1/calendars/{calendar_id}/events`: Create event.

## Install

Install by cloning the relevant branch and installing required gems from `Gemfile.lock`.

```
bundle install
```

Setup development database once:
```
rake db:migrate
```

## Execute

Run this app by using:

```
rackup
```

## Test

Run the test through Rakefile.

Setup test database once:
```
RACK_ENV=test rake db:migrate
```

```
rake spec
```
