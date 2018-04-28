require 'callback_timer'


RSpec.describe CallbackTimer do
  
  describe "::new" do
  
    context "when creating a new CallbackTimer with no 'duration'" do
      it "should raise ArgumentError" do
        callback = proc {}
        expect{ CallbackTimer.new(callback: callback) }.to raise_error(ArgumentError)
      end
    end
    
    context "when creating a new CallbackTimer with a negative 'duration'" do
      it "should raise ArgumentError" do
        callback = proc {}
        duration = -1
        expect{ CallbackTimer.new(callback: callback, duration: duration) }.to raise_error(ArgumentError)
      end
    end
    
    context "when creating a new CallbackTimer with no 'callback'" do
      it "should raise ArgumentError" do
        duration = 1
        expect{ CallbackTimer.new(duration: duration) }.to raise_error(ArgumentError)
      end
    end
    
    context "when creating a new CallbackTimer with a 'duration' of 1" do
      it "should call the callback in 1 second" do
        $test = nil
        target_time = Time.now + 1
        callback = proc { $test = Time.now }
        CallbackTimer.new(callback: callback, duration: 1)
        sleep 2
        expect($test).to be_between(target_time - 0.2, target_time + 0.2)
      end
    end
    
    context "when creating three new CallbackTimers with different 'duration's" do
      it "should all call the callback at correct times" do
        $test = []
        start_time = Time.now
        durations = [1, 0.5, 2]
        target_times = durations.map { |duration| start_time + duration }
        callbacks = 3.times.map { |index| proc { $test[index] = Time.now } }
        3.times { |index| CallbackTimer.new(callback: callbacks[index], duration: durations[index]) }
        sleep 2.2
        3.times { |index| expect($test[index]).to be_between(target_times[index] - 0.2, target_times[index] + 0.2) }
      end
    end
    
    context "when creating a lot of new CallbackTimers with different 'duration's" do
      it "should all call the callback at correct times" do
        $test = []
        start_time = Time.now
        random = Random.new(1234)
        durations = 100.times.map { random.rand(0.0..10.0) }
        target_times = durations.map { |duration| start_time + duration }
        callbacks = 100.times.map { |index| proc { $test[index] = Time.now } }
        100.times { |index| CallbackTimer.new(callback: callbacks[index], duration: durations[index]) }
        sleep 10.2
        100.times { |index| expect($test[index]).to be_between(target_times[index] - 0.2, target_times[index] + 0.2) }
      end
    end
    
  end
  
  describe "#cancel" do
  
    context "when calling #cancel on a pending CallbackTimer" do
      it "should not call callback" do
        $called = false
        callback = proc { $called = true }
        timer = CallbackTimer.new(callback: callback, duration: 2)
        sleep 1
        timer.cancel
        sleep 2
        expect($called).to eql false
      end
    end
    
    context "when calling #cancel on completed CallbackTimer" do
      it "should do nothing" do
        callback = proc { }
        timer = CallbackTimer.new(callback: callback, duration: 1)
        sleep 2
        expect{ timer.cancel }.not_to raise_error
      end
    end
  
  end
  
end
