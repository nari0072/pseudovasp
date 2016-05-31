require 'spec_helper'

describe PseudoVASP do
  it 'has a version number.' do
    expect(PseudoVASP::VERSION).not_to be nil
  end

  it 'should return Al_eam_perfect.res from Al_POSCAR.' do
    poscar_name = './spec/Al_POSCAR'
    @lattice=PseudoVASP.new(poscar_name)
    result= @lattice.display+"\n"
    expeced = File.read('./spec/Al_eam_perfect.res')
    expect(result).to eq(expeced)
  end

  it 'should return Al_lj_force.res from Al_POSCAR_force.' do
    poscar_name = './spec/Al_POSCAR_force'
    @lattice=PseudoVASP.new(poscar_name,
                            opts={output: :show_force, potential: :lj})
    result= @lattice.display+"\n"
    expeced = File.read('./spec/Al_lj_force.res')
    expect(result).to eq(expeced)
  end

end
