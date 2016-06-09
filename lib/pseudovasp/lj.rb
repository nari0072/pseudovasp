require 'yaml'
module LJ
  module_function

  def atom_energy()
    ene=0.0
    @nl.each do |aj|
      r=distance(@pos,aj.pos)
      ene += @@potential.energy(r)
    end
    return ene
  end

  def atom_force()
    f=[0.0,0.0,0.0]
    @nl.each do |aj|
      x,y,z=f_distance(@pos,aj.pos)
      r=sqrt(x**2+y**2+z**2)
      dedr = @@potential.dedr(r)
      f[0] += -x/r*dedr
      f[1] += -y/r*dedr
      f[2] += -z/r*dedr
    end
    return f
  end

  def select(file='POTCAR')
    src = YAML.load_file(file)
    @@potential=case src[:type]
              when 'lj0'
                LJ0.new(src)
              when 'lj_jindo'
                LJ_Jindo.new(src)
              end
  end
end

class LJ0
  def initialize(src)
    @@a,@@b,@@p,@@q=src[:a],src[:b],src[:p],src[:q]
  end
  def energy(r)
    ene=(-@@a*(1/r**@@p)+@@b*(1/r**@@q))
  end
  def dedr(r)
    (@@p*@@a/r**(@@p+1.0))-(@@q*@@b/r**(@@q+1.0))
  end
end

class LJ_Jindo
  def initialize(src)
    @@d0,@@m,@@n,@@r0=src[:d0],src[:m],src[:n],src[:r0]
  end
  def energy(r)
    ene=@@d0*((r/@@r0)**(-@@n)*@@m-(r/@@r0)**(-@@m)*@@n)/(@@m-@@n)
    ene*8.617385e-05
  end
  def dedr(r)
    @@d0*@@m*@@n*((r/@@r0)**(-@@m)-(r/@@r0)**(-@@n))/(r*(@@m-@@n))
  end
end
