require 'thread'
require 'time'

class CallbackTimer

  # I would like to use a priority queue here but I need to be able to remove sleepers randomly.
  #@timers = PQueue.new { |a, b| a < b }
  @timers = []
  @condition_variable = ConditionVariable.new
  @mutex = Mutex.new
  @thread = Thread.new { worker_loop }
  
  # Add {CallbackTimer} to the scheduler.
  # @api private
  # @param timer [CallbackTimer]
  # @return [void]
  def self.add(timer)
    @mutex.synchronize do
      @timers.push(timer)
      @timers.sort_by!(&:deadline)
      if @timers.first == timer
        @condition_variable.signal
      end
    end
    nil
  end
  
  # Remove {CallbackTimer} from scheduler.
  # @api private
  # @param timer [CallbackTimer]
  # @return [void]
  def self.cancel(timer)
    @mutex.synchronize do
      @condition_variable.signal if @timers.first == timer
      @timers.delete(timer)
    end
    nil
  end
  
  # Scheduler worker loop to run in it's own thread.
  # @api private
  # @return [void]
  def self.worker_loop
    @mutex.lock
    loop do
      next_timer = @timers.first
      unless next_timer
        @condition_variable.wait(@mutex)
        next
      end
      next_deadline = next_timer.deadline
      duration = next_deadline - Time.now
      @condition_variable.wait(@mutex, duration) if duration.positive?
      if @timers.first != next_timer
        # timer may have been canceled or a new timer has been added to @timers with an earlier deadline
        next
      end
      @timers.shift
      @mutex.unlock
      next_timer.time_has_elapsed
      @mutex.lock
    end
    nil
  end
  
  # Time that the {CallbackTimer} should call it's callback.
  # @api private
  # @return [Time]
  attr_reader :deadline
  
  # Creates and starts a new {CallbackTimer}.
  # @param callback [#to_proc]
  # @param duration [Numeric] non-negative number specified in seconds
  # @return [CallbackTimer]
  def initialize(callback: , duration: )
    raise ArgumentError, "'callback' must respond to 'to_proc'" unless callback.respond_to?(:to_proc)
    @callback = callback.to_proc
    unless duration.is_a?(Numeric) && duration >= 0
      raise ArgumentError, "'duration' must be a non-negative Numeric"
    end
    @start_time = Time.now
    @deadline = @start_time + duration
    @mutex = Mutex.new
    @complete = false
    self.class.add(self)
  end
  
  # Cancels the {CallbackTimer}.
  # Will ignore if already called or if callback has already been called.
  # @return [void]
  def cancel
    @mutex.synchronize do
      return if @complete
      @complete = true
    end
    self.class.cancel(self)
    nil
  end
  
  # Tells {CallbackTimer} it has reached it's deadline.
  # @api private
  # @return [void]
  def time_has_elapsed
    @mutex.synchronize do
      return if @complete
      @complete = true
    end
    elapsed_time = Time.now - @start_time
    @callback.call(elapsed_time)
    nil
  end
  
end
