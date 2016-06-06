# -*- coding: utf-8 -*-
require 'systemu'
require 'pseudoVASP'

# pseudoVASPでforceの解析解と数値解が一致しているかを確かめるclass.
# LJでは一致を確認．
# ruby force_check.rb 0などで起動．
# ruby force_check_test.rbで0番原子，およびすべての原子をcheck.
class ForceCheck
  attr_accessor :dir_path

  def initialize(dir_path)
    @dir_path = dir_path
  end
  # i_atomに対する微小移動に対するエネルギー変化をspec_moveで取得し，
  # mapleにcenter_calc.mwでfittingさせ，
  # tmp1.txtから取得している．
  def all_calc(i_atom)
    i_atom_result=[]
    [0,1,2].each {|j_col|
      print energy_data=spec_move(i_atom,j_col)
      open("tmp.txt",'w'){|f| f.print energy_data }
      command="/Library/Frameworks/Maple.framework/Versions/Current/bin/maple #{dir_path}/center_calc.mw"
      status,stdout,stderr=systemu command 
      status,stdout,stderr=systemu "cat tmp1.txt"
      p i_atom_result << stdout.to_f
    }
    return i_atom_result
  end

  #i_atomのj方向の移動とそのenergy計算
  #devをenergy_dataにそのまま使っているのは，fittingを原点近傍で行うため．
  #dev1=1.0+dev0はPOSCARの入力値がマイナス値を取れないため．1.0並行移動．
  def spec_move(i_atom,j_col)
    energy_data =""
    n_loop=4
    (n_loop+1).times{|ii|
      orig_poscar = File.join(@dir_path,"POSCAR_orig")
      target_poscar = File.join(@dir_path,'POSCAR')
      tmp = File.readlines(orig_poscar)
      target_line=i_atom+7
      p row=tmp[target_line].split(/\s+/)
      dev=(ii-n_loop/2.0)*0.001
      dev0=(ii-n_loop/2.0)*0.001+row[j_col+1].to_f
      (dev0 < 0.0)? dev1 = 1.0+dev0 : dev1 =dev0
      row[j_col+1]=sprintf("%-11.8f",dev1.to_f)
      print text=sprintf("%15.10f %15.10f %15.10f\n",row[1].to_f,row[2].to_f,row[3].to_f)
      tmp[target_line]=text
      open(target_poscar,'w'){|f|
        tmp.each{|ele| f.print ele }
      }

      # systemからpseudoVASPを呼び出す代わりにobjectとしてnewして呼び出すためのidiom
#    text,target=vasp_calc(poscar_name)
#      energy=text.match(/([+-]?\d+\.\d+) eV/)[1].to_f
      opts={output: :show_energy, potential: :lj}
      lattice=PseudoVASP.new(target_poscar, opts)
      open("tmp.res",'w'){|f| f.print lattice.display+"\n"}
      status, stdout, stderr = systemu "grep TOTEN tmp.res"
      energy_data << sprintf("%15.10f %15.10f\n",dev.to_f,stdout.split(/ /)[6].to_f)
#      energy_data << sprintf("%15.10f %15.10f\n",dev.to_f,energy)
    }
    return energy_data
  end

  #計算をすべての原子にわたるか，特定の原子で行うかのcontroller 
  #ii<0ならすべての原子，それ以外はtarget_listの特定原子のforce_check
  def controller(ii)
#    p ii
    all_result =[]
    result=""
    target_list=[7,9,11,13,15,16,19,20,23,24,25,26]
    if ii<0 then
      target_list.each{|i_atom|
        all_result << all_calc(i_atom)
      }
      all_result.each_with_index{|ele,i|
        result << sprintf("||%4d|| %10.5f|| %10.5f|| %10.5f\n",target_list[i],ele[0],ele[1],ele[2])
      }
    else
      i_atom=target_list[ii]
      all_result << all_calc(i_atom)
      ele = all_result[0]
      result << sprintf("||%4d|| %10.5f|| %10.5f|| %10.5f\n",target_list[ii],ele[0],ele[1],ele[2])
    end
    return result
  end

end

if __FILE__ == $0 then
  force_check = ForceCheck.new
  p force_check.controller(ARGV[0].to_f)
end
