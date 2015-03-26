Advance Events
==============
This is an alternative, and incompatable take on Moon's Event system, the 
main difference is ADV uses the Event class as its key instead of the event type.

This means you can use an Event superclass to get all child events of that type.

```ruby
# equivalent to `on :all do` in std version
on Moon::Event do 
end
```
