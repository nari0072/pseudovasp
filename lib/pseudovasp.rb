# -*- coding: utf-8 -*-
require "pseudovasp/poscar"
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
      command_parser = OptionParser.new do |opt|
        opt.on('-v', '--version','show program Version.') {
          opt.version = PseudoVASP::VERSION
          puts opt.ver
        }
        opt.on('--potential TYPE',[:eam,:lj],
               'potential selection, TYPEs=eam or lj.') {|type| 
          calc_system(@argv[0],type)
        }
      end
      command_parser.banner = "Usage: pvasp [options] FILE"
      command_parser.parse!(@argv)
      bare_run('POSCAR') if @argv[0]!=nil
    end

    def bare_run(file)
      @lattice=PseudoVASP.new(file)
      print @lattice.display+"\n"
    end

    def calc_system(file='POSCAR',type)
      @lattice=PseudoVASP.new(file,
                              opts={output: :show_force, potential: type})
      print @lattice.display+"\n"
    end
  end

end
