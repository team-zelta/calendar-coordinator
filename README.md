# Calendar Coordinator
A Web application that through the permissions of common calendars such as Google and Apple, compare the time and schedule a meeting.
 
## API Routes
All routes return JSON.

* GET `/`: Root route shows if Web API is running.
* GET `api/v1/events`: Get list of all events id.
* GET `api/v1/events/{id}`: Get event by id.
* POST `api/v1/events`: Create event.

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