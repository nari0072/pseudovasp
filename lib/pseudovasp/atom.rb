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

  def select(type, file='POTCAR')
    if type==:eam then
      @@potentail=EAM.new 
    else
      p src = YAML.load_file(file)
      @@potential=case src[:type]
              when 'lj0'
                LJ0.new(src)
              when 'lj_jindo'
                LJ_Jindo.new(src)
              end
    end 
  end

end

class EAMAtom < Atom
  include EAM
  def initialize(pos,number,element)
    super(pos,number,element)
  end
end

class LJAtom < Atom
  include LJ
  def initialize(pos,number,element)
    super(pos,number,element)
  end
end

