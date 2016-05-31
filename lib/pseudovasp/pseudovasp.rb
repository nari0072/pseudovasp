# -*- coding: utf-8 -*-
include Math
require 'pp'
require_relative 'eam'
require_relative 'lj'
require_relative 'poscar'

# Boundary modelでpseudoVASPとVASPを切り替えるために設けたadaptorのつもり．
# target.displayがtextでの返し．targetはclassとしての返し．
# trueVASPの時には，targetに必要な情報を取り込む関数を組み込むつもり．
def vasp_calc(file_name, opts={output: :show_energy, potential: :eam})
  tmp = File.readlines('./INCAR') rescue []
  tmp.each{|line|
    tmp = line.split(/\s+/)
    opts[tmp[0].to_sym]=tmp[1].to_sym
  }
  target=PseudoVASP.new(file_name, opts)
  return target.display,target
end

# class PseudoVASP, LJ間の格子の周期的境界条件を満たした距離計算のための
# 受け渡しに今は使っている．
# もっとましなやり方無いんかいな！！！
$lattice=[[0.0,0.0,0.0],[0.0,0.0,0.0],[0.0,0.0,0.0]]
#== pseudoVASP:VASPに似せた経験的ポテンシャルによるエネルギー計算
#
#Authors::   西谷 滋人
#Version::   1.1 2014-12-20 bob
#Copyright:: Copyright (C) Shigeto R. Nishitani, 2014. All rights reserved.
#License::   Ruby ライセンスに準拠
#
#== 詳細
#* VASPに似せて，POSCARの入力を受け取り，
#* LJあるいはEAMのエネルギー計算を実行し，OUTCAR形式で出力する．
#== 目的
#* VASPを用いた粒子シミュレーションの開発段階において，
#- 実行を加速するため，
#* もしくはtrue VASPでは実行に時間がかかりすぎる系のだいたいの値を求めるために活用．

class PseudoVASP < Poscar
  attr_reader :atom_list, :options

#lattice, nlを作る．
#format :: :show_force, :show_energy
  def initialize(poscar_name, options={output: :show_force, potential: :eam})
    super(poscar_name)
    3.times{|i| 
      3.times{|j|
        $lattice[i][j]=@lat_vec[i][j]*@whole_scale
      }
    }
    @options=options
    mk_lattice
    mk_nl
  end

  def mk_lattice
    @atom_list=[]
    @pos_size.times{|i| 
      pos1=[0.0,0.0,0.0]
      3.times {|j| 
        3.times {|k| 
          pos1[k]+=@pos[i][j].to_f*$lattice[j][k]
        }
      }
      case @options[:potential]
      when :eam then
        @atom_list << EAMAtom.new(pos1,i,@elements[i]) 
      when :lj then
        @atom_list << LJAtom.new(pos1,i,@elements[i]) 
      else
        ;
      end
    }
  end

  def mk_nl
    nmax=@atom_list.length-1
    @atom_list.each_with_index{|ai,i|
      for j in i+1..nmax do
        aj=@atom_list[j]
        if distance(ai.pos,aj.pos) < ai.cut_off then
          ai.nl << aj
          aj.nl << ai
        end
      end
    }
  end

  def total_energy
    @atom_list.inject(0.0) { |sum, ai| sum + ai.energy }
  end

  def display
    text=""
    text << sprintf("FREE ENERGIE OF THE ION-ELECTRON (eV)\n")
    text << sprintf("-----------------------------------------------------------------\n")
    text << sprintf("free energy TOTEN =   %10.7f eV\n\n",total_energy())
    text << sprintf("POSITION                                       TOTAL-FORCE (eV/Angst)\n")
    text << sprintf("-----------------------------------------------------------------\n")
    text << show_pos_force()
    return text
  end

  def show_pos_force
    show_list=[0,7,9,11,13,15,16,19,20,23,24,25,26]
    text=""
    @atom_list.each_with_index {|ai,ii| 
      pos,f=ai.pos,ai.force
      case @options[:output]
      when :show_force then
        3.times {|i| text << sprintf("%10.6f",pos[i]/($lattice[i][i])) }
        3.times {|i| text << sprintf("%10.6f",f[i]) }
        text << sprintf("%4d",ii) #not VASP but convenience to see
        text << sprintf("\n")
      when :show_energy then
        3.times {|i| text << sprintf("%10.6f",pos[i]/($lattice[i][i])) }
        3.times {|i| text << sprintf("%14.6f",f[i]) }
        text << sprintf("%10.6f",ai.energy) 
        text << sprintf("%4d",ii) #not VASP but convenience to see
        text << sprintf("\n")
      when :select_energy then
        next if !show_list.include?(ii)
          text << sprintf("||%4d||",ii) #not VASP but convenience to see
          3.times {|i| text << sprintf("%14.6f||",f[i]) }
          text << sprintf("%10.6f",ai.energy) 
          text << sprintf("\n")
      else
        ;
      end
    }
    return text
  end

#return W=1/3*sum(r_ij*f_ij)
# atom.posはA単位．forceもeV/A^3とかにすべきだが．．．
  def virial
    virial=0.0
    @atom_list.each{|atom|
      3.times{|i| 
        virial += atom.pos[i]*atom.force[i]
      }
    }
    return virial/3.0
  end

  def a0
    x,y,z=@lat_vec[0][0],@lat_vec[1][1],@lat_vec[2][2]
    scale = @whole_scale
#    volume = scale**3*x*y*z
    a0 = scale*x
    return a0
  end

  def display_at(iatom)
    p iatom
    p @atom_list[iatom].show_nl
  end
end

=begin 
原子class
エネルギーと力の計算はeamあるいはljへ出している．
今はincludeで切り替えている．
=end
class Atom 
#  include EAM
#  include LJ
  attr_accessor :pos, :nl, :cut_off, :number, :element
  
  def initialize(pos,number,element)
    @nl=[]
#    @cut_off = CUT_OFF
    @pos,@number=pos,number
    @element = element
  end
  def energy; atom_energy;  end
  def force; atom_force; end
  def show_nl; @nl.inject([]){|res, aj| res << aj.number };  end
end


def distance(a,b)
  r=0.0
  3.times{|i|
    x1=a[i]-b[i]
    x=x1-(x1/($lattice[i][i])).round*$lattice[i][i]
    r+=x*x
  }
  return sqrt(r)
end

def f_distance(a,b)
  t=[]
  3.times{|i|
    x=a[i]-b[i]
    x=x-(x/($lattice[i][i])).round*$lattice[i][i]
    t << x
  }
  return t
end

class EAMAtom < Atom
  include EAM
  
  def initialize(pos,number,element)
    super(pos,number,element)
    @cut_off = CUT_OFF
  end
end

class LJAtom < Atom
  include LJ
  
  def initialize(pos,number,element)
    super(pos,number,element)
    @cut_off = CUT_OFF
  end
end

if __FILE__ == $0 then
  poscar_name = ARGV[0] || 'POSCAR'
  lattice=PseudoVASP.new(poscar_name, output: :show_force, potential: :eam)
  file=File.open("tmp.res",'w')
  file.print lattice.display+"\n"
  file.close
end





