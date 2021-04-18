# calendar-coordinator

## Event
### Create
#### Request
```
POST 'http://127.0.0.1:9292/api/v1/events' 

{
  "id": 1001,
  "status": "confirmed",
  "summary": "Project Meeting",
  "description": "Discuss the progress of the project.",
  "location": "NTHU",
  "start": {
      "date": "",
      "date_time": "2021-06-12 14:00:00.00+08:00",
      "time_zone": "Taiwan"
  },
  "end": {
      "date": "",
      "date_time": "2021-06-12 15:30:50.00+08:00",
      "time_zone": "Taiwan"
  }
}
```

#### Response
```
{
    "message": "Event saved",
    "event_id": 1001
}
```

### Get by id
#### Request
```
GET 'http://127.0.0.1:9292/api/v1/events/{id}'
```

#### Response
```
{
    "id": 1001,
    "status": "confirmed",
    "summary": "Project Meeting",
    "description": "Discuss the progress of the project.",
    "location": "NTHU",
    "start": {
        "date": "",
        "date_time": "2021-06-12 14:00:00.00+08:00",
        "time_zone": "Taiwan"
    },
    "end": {
        "date": "",
        "date_time": "2021-06-12 15:30:50.00+08:00",
        "time_zone": "Taiwan"
    }
}
```

### Get all id
#### Request
```
GET 'http://127.0.0.1:9292/api/v1/events'
```

#### Response
```
[
    "1001",
    "1002",
    "1003"
]
```