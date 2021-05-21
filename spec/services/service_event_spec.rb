# frozen_string_literal: true

require_relative '../spec_helper'
require 'date'

describe 'Test CalendarCoordinator Web API - event' do
  include Rack::Test::Methods
  # Common_busy_time
  it 'HAPPY: 2 events not overlap, should get 2 common busy time' do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T18:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 2
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 13:30:00 +0800'
    _(common_busy_time[1].start_date_time.to_s).must_equal '2021-05-19 15:30:00 +0800'
    _(common_busy_time[1].end_date_time.to_s).must_equal '2021-05-19 18:30:00 +0800'
  end

  it "HAPPY: event2's start time equal to event1's end time, should combine and get 1 common busy time" do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 15:30:00 +0800'
  end

  it "HAPPY: event2's start time equals to event1's start time,
             and event2's end time is smaller than event1's end time,
             should combine and get 1 common busy time" do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 15:30:00 +0800'
  end

  it "HAPPY: event2's time equals to event1's time, should get 1 common busy time" do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 15:30:00 +0800'
  end

  it "HAPPY: event2's start time equals to event1's start time,
             and event2's end time is larger than event1's end time,
             should combine and get 1 common busy time" do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T18:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 18:30:00 +0800'
  end

  it "HAPPY: event2's start time is in event1's whole time,
             and event2's end time is larger than event1's end time,
             should combine and get 1 common busy time" do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T18:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 18:30:00 +0800'
  end

  it 'HAPPY: event2 completely overlaps in event1' do
    event1 = CalendarCoordinator::Event.new
    event1.start_date_time = DateTime.parse('2021-05-19T12:30:00+08:00')
    event1.end_date_time = DateTime.parse('2021-05-19T15:30:00+08:00')

    event2 = CalendarCoordinator::Event.new
    event2.start_date_time = DateTime.parse('2021-05-19T13:30:00+08:00')
    event2.end_date_time = DateTime.parse('2021-05-19T14:30:00+08:00')

    events_arr = [event1, event2]

    common_busy_time = CalendarCoordinator::EventService.common_busy_time(events_arr)

    _(common_busy_time.count).must_equal 1
    _(common_busy_time[0].start_date_time.to_s).must_equal '2021-05-19 12:30:00 +0800'
    _(common_busy_time[0].end_date_time.to_s).must_equal '2021-05-19 15:30:00 +0800'
  end

  it 'SAD: should not be able not get common busy time if argument is nil' do
    common_busy_time = CalendarCoordinator::EventService.common_busy_time(nil)

    _(common_busy_time.count).must_equal 0
  end

  it 'SAD: should not be able not get common busy time if argument is empty' do
    common_busy_time = CalendarCoordinator::EventService.common_busy_time([])

    _(common_busy_time.count).must_equal 0
  end
end
