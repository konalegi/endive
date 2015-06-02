require 'test_helper'


class Cat
  include Endive::Support::Callbacks
  define_callback :before_action
  define_callback :after_action

  before_action :say_meow
  after_action :go_to_sleep


  def say_meow
    p 'Meow'
  end

  def go_to_sleep
    p "#{self} go to sleep"
  end

  def play
    run_callback :before_action
    p 'play'
    run_callback :after_action
  end

end

class Garfield < Cat

  before_action :run, only: [:play_with_run]

  def play_with_run
    run_callback :before_action, action: :play_with_run
    p 'play with run'
    run_callback :after_action
  end

  def run
    p "I'm run!"
  end

end


class CallbacksTest < Minitest::Test
#   garfield = Garfield.new
#   garfield.play
#   garfield.play_with_run
end
