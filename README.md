# Calendar Coordinator

A Web application that through the permissions of common calendars such as Google and Apple, compare the time and schedule a meeting.

## API Routes

All routes return JSON.

- GET `/`: Root route shows if Web API is running.
- GET `api/v1/events`: Get list of all events id.
- GET `api/v1/events/{id}`: Get event by id.
- POST `api/v1/events`: Create event.
- GET `api/v1/calendars`: Get list of all calendars id
- GET `api/v1/calendars/{id}`: Get calendar by id.
- POST `api/v1/calendars`: Create calendar.

## Install

Install by cloning the relevant branch and installing required gems from `Gemfile.lock`.

```
bundle install
```

## Execute

Run this app by using:

```
rackup
```

## Test

Run the test through Rakefile.

```
rake test
```
