# Callback Timer
A Ruby Gem to create timers. The timer objects will call a given callback when the time has elapsed or can be canceled before then. *Callback Timer* only uses a single thread to schedule all the timers.

# Install
`gem install callback_timer`

# Documentation
[![Yard Docs](https://img.shields.io/badge/yard-docs-blue.svg?style=for-the-badge)](http://www.rubydoc.info/gems/callback_timer)

# Example
```ruby
require 'callback_timer'

greeting_callback = proc { puts 'Hello World!' }
CallbackTimer.new(callback: greeting_callback, duration: 5)
```
