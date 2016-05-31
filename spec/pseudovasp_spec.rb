require 'spec_helper'
require 'systemu'

describe Pseudovasp do
  it 'has a version number.' do
    expect(Pseudovasp::VERSION).not_to be nil
  end

  it 'should return Al_eam_perfect.res from Al_POSCAR.' do
    poscar_name = './spec/Al_POSCAR'
    @lattice=PseudoVASP.new(poscar_name)
    file=File.open("./spec/tmp.res",'w')
    file.print @lattice.display+"\n"
    file.close
    command = %q( diff ./spec/tmp.res ./spec/Al_eam_perfect.res )
    status, stdout, stderr = systemu command
    expect(stdout).to eq("")
  end

  it 'should return Al_lj_force.res from Al_POSCAR_force.' do
    poscar_name = './spec/Al_POSCAR_force'
    @lattice=PseudoVASP.new(poscar_name,
                            opts={output: :show_force, potential: :lj})
    file=File.open("./spec/tmp.res",'w')
    file.print @lattice.display+"\n"
    file.close
    command = %q( diff ./spec/tmp.res ./spec/Al_lj_force.res )
    status, stdout, stderr = systemu command
    expect(stdout).to eq("")
  end

end
