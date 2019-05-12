require 'pathname'
require 'cri'

class Appy
  module Helpers
    module_function

    def no_recurse(blk, name: "block")
      is_running = false
      proc { |*args|
        if is_running
          raise "#{name} recursively called itself"
        end

        is_running = true
        begin
          instance_exec(*args, &blk)
        ensure
          is_running = false
        end
      }
    end
  end

  Command = Struct.new(:name)

  attr_reader :root, :config

  def initialize(root: nil, name: nil, &blk)
    if root.nil?
      caller_location = caller_locations(1, 1).first
      app_path = File.expand_path(caller_location.path)
      root = File.dirname(app_path)
    end

    @root = Pathname(root)
    @name = name || @root.basename.to_s

    setup_load_path
    instance_eval(&blk) if blk
  end

  def has(name, &blk)
    is_defined = false
    value = nil
    blk = Helpers.no_recurse(blk, name: name)
    define_singleton_method(name) do
      if !is_defined
        value = instance_eval(&blk)
        is_defined = true
      end
      value
    end
  end

  def cmd(&blk)
    cri_command.define_command(&blk)
    nil
  end

  def cri_command
    @cri_command ||= Cri::Command.define do |c|
      c.name @name
      c.summary "application commands"

      c.flag :h, :help, 'show help for this command' do |value, cmd|
        puts cmd.help
        exit 0
      end

      c.run do |opts, args, cmd|
        puts cmd.help
        exit 0
      end
    end
  end

  def cli!(argv = ARGV)
    cri_command.run(argv)
  end

  private

  def setup_load_path
    $LOAD_PATH << (@root + 'lib').to_s
  end
end

