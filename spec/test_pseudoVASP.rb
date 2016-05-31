require 'systemu'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pseudovasp'

poscar_name = 'Al_POSCAR'
# @lattice=PseudoVASP.new(poscar_name)
@lattice=PseudoVASP.new(poscar_name,
                        opts={output: :show_force, 
                          potential: :lj})
#file=File.open("tmp.res",'w')
#file.print @lattice.display+"\n"
#file.close
print @lattice.display+"\n"
