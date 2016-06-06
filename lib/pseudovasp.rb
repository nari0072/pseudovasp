# -*- coding: utf-8 -*-
require "pseudovasp/poscar"
require "pseudovasp/version"
require "pseudovasp/pseudovasp"
require "pseudovasp/force_check"
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
        opt.on('--force [SITE]','check force on SITE or all sites(SITE<0)') {|v|
          force_check(v,@argv)
        }
      end
      command_parser.banner = "Usage: pvasp [options] DIRECTORY"
      command_parser.parse!(@argv)
      target_path = @argv[0]==nil ? './' : @argv[0]
      bare_run(File.join(target_path,'POSCAR'))
      exit
    end

    def bare_run(file)
      @lattice=PseudoVASP.new(file)
      print @lattice.display+"\n"
    end

    def calc_system(file='POSCAR',type)
      opts={output: :show_force, potential: type}
      @lattice=PseudoVASP.new(file,opts)
      print @lattice.display+"\n"
    end

    def force_check(v,argv)
      site=  v.to_i < 0 ? -1 : v.to_i
      target_path = @argv[0]==nil ? './' : @argv[0]
      force_check = ForceCheck.new(target_path)
      print force_check.controller(site)
      exit
    end
  end

end
