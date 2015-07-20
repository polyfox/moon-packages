# Events

# Example

```ruby

# Common transducers

def map(transform)
  return -> (input) {
    return transform.(input)
  }
end

def filter(predicate)
  return -> (input) {
    predicate.(input) ? input : nil
  }
end

# To be moon stdlib

# Generates a filter step function using the filtering transducer, matching the
# pressed key.
def key(sym)
  filter(-> (k) { event.key == sym })
end

fn = -> (e) {
  puts "Got enter key!"
}

# * is our compose operator, where fn compose(f, g) = f(g(x))

ch = key(:enter) * fn
@window.on(:press, &ch)
```

## Dragging filter

More complex example using a gate filter and a key filter to produce a dragging
filter.

```ruby
def gate(opener, closer)
  var open = false;
  return -> (e) {
    open = true if e.type == opener
    open = false if e.type == closer
    return open
  }
end


ch = compose(
  # Only allow through when mouse has been down
  filter(gate(:mousedown, :mouseup)),
  # Filter by e.type === 'mousemove'
  filter(key(:mousemove)),
  # e -> [type, x, y]
  map(-> (e) {
      return [e.x, e.y]
  })
)

fn = -> (e) {
  puts "Got a dragging event!"
  trigger :dragging, self # generates a new event
}

# Listen for relevant events
on :mousemove, :mouseup, :mousedown, &(ch * fn)
```
