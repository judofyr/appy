require 'pathname'

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

  def initialize(root: nil, &blk)
    if root.nil?
      caller_location = caller_locations(1, 1).first
      app_path = File.expand_path(caller_location.path)
      root = File.dirname(app_path)
    end

    @root = Pathname(root)
    @commands = []

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

  def cmd(name, &blk)
    name = name.to_s
    blk = Helpers.no_recurse(blk, name: name)
    @commands << Command.new(name)
    define_singleton_method(name, &blk)
  end

  def cli!(argv = ARGV)
    if argv.empty?
      @commands.each do |cmd|
        puts "- #{cmd.name}"
      end

      return
    end

    cmd_name = argv[0]
    cmd = @commands.detect { |cmd| cmd.name == cmd_name }
    if !cmd
      puts "no such command: #{cmd_name}"
      exit 1
    end

    send(cmd.name)
  end

  private

  def setup_load_path
    $LOAD_PATH << (@root + 'lib').to_s
  end
end

