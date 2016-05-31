# -*- coding: utf-8 -*-
require "pseudovasp/version"
require "pseudovasp/pseudovasp"
require 'optparse'
require 'pp'

module PVasp
  # Your code goes here...

  class Command
    def self.run(argv=[])
      print "pvasp says 'Hello world'.\n"
      new(argv).execute
    end

    def initialize(argv=[])
      @argv = argv
    end

    def execute
      @argv << '--help' if @argv.size==0
      command_parser = OptionParser.new do |opt|
        opt.on('-v', '--version','show program Version.') { |v|
          opt.version = PseudoVASP::VERSION
          puts opt.ver
        }
      end
      command_parser.banner = "Usage: pvasp [options] FILE"
      command_parser.parse!(@argv)
      bare_run(@argv[0]) if @argv[0]!=nil
    end

    def bare_run(file='POSCAR')
      @lattice=PseudoVASP.new(file)
      print @lattice.display+"\n"
    end
  end

end
