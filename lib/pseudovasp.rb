# -*- coding: utf-8 -*-
require "pseudovasp/lj"
require "pseudovasp/eam"
require "pseudovasp/atom"
require "pseudovasp/poscar"
require "pseudovasp/version"
require "pseudovasp/pseudovasp"
require "pseudovasp/force_check"
require "pseudovasp/momentmethod.rb"
require 'optparse'
require 'pp'

module PVasp
  # Your code goes here...

  class Command
    attr_accessor :opts
    def self.run(argv=[])
      new(argv).execute
    end

    def initialize(argv=[])
      @argv = argv
      @opts = {output: :show_force, potential: :lj,
               calculation: :energy, site: 100}
    end

    def execute
      command_parser = OptionParser.new do |opt|
        opt.on('-v', '--version','show program Version.') {
          opt.version = PseudoVASP::VERSION
          puts opt.ver
        }
        opt.on('--potential TYPE',[:eam,:lj],
               'potential selection, TYPEs=eam or lj.') {|type|
          @opts[:potential]= type
        }
        opt.on('--potcar FILE','potcar name.') {|file|
          @opts[:potential]= :lj
          @opts[:potcar_name]= file
        }
        opt.on('--force [SITE]','check force on SITE or all sites(SITE>=100)') {|v|
          @opts[:calculation]= :force_check
          @opts[:site]= v if v!=nil
        }
        opt.on('--moment','calculate free energy by Moment method') {|v|
          @opts[:calculation]= :moment_method
        }
      end
      command_parser.banner = "Usage: pvasp [options] DIRECTORY"
      command_parser.parse!(@argv)
      target_path = @argv[0]==nil ? './' : @argv[0]
      bare_run(target_path)
      exit
    end

    def bare_run(target_dir)
      FileUtils.cd(target_dir){
        case @opts[:potential]
        when :lj then
          potcar = @opts[:potcar_name]
          potcar = 'POTCAR' if potcar == nil
          LJ.select(potcar)
        else
          ;
        end

        case @opts[:calculation]
        when :energy then
          @lattice=PseudoVASP.new('POSCAR',@opts)
          print @lattice.display+"\n"
        when :force_check then
          v=@opts[:site]
          site=  v.to_i > 99 ? -1 : v.to_i
          force_check = ForceCheck.new(target_dir,@opts)
          print force_check.controller(site)
        when :moment_method then
          MomentMethod.new(target_dir)
        else
          ;
        end
      }
    end
  end
end
