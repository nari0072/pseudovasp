class Atom 
  attr_accessor :pos, :nl, :cut_off, :number, :element
  CUT_OFF=4.0*0.8

  def initialize(pos,number,element)
    @nl=[]
    @pos,@number=pos,number
    @element = element
    @cut_off = CUT_OFF
  end
  def energy; atom_energy;  end
  def force; atom_force; end
  def show_nl; @nl.inject([]){|res, aj| res << aj.number };  end

end

class EAMAtom < Atom
  include EAM
end

class LJAtom < Atom
  include LJ
end

