require 'yaml'
class LJ0
  def initialize(src)
    p src[:type]
    p src[:element]
    @a,@b,@p,@q=src[:a],src[:b],src[:p],src[:q]
  end
  def energy(r)
    ene=(-@a*(1/r**@p)+@b*(1/r**@q))
    ene*12
  end
  def dedr(r)
    (@p*@a/r**(@p+1.0))-(@q*@b/r**(@q+1.0))
  end
end
class LJ_Jindo
  def initialize(src)
    p src[:type]
    p src[:element]
    @d0,@m,@n,@r0=src[:d0],src[:m],src[:n],src[:r0]
  end
  def energy(r)
    ene=@d0*((r/@r0)**(-@n)*@m-(r/@r0)**(-@m)*@n)/(@m-@n)
    12*ene*8.617385e-05
  end
  def dedr(r)
    @d0*@m*@n*((r/@r0)**(-@m)-(r/@r0)**(-@n))/(r*(@m-@n))
  end
end
p src = YAML.load_file(ARGV[0])
r=0.0
potential=case src[:type]
when 'lj0'
  p r= 2.857701314197838
  LJ0.new(src)
when 'lj_jindo'
  p r=2.5487e-8*1.0
  LJ_Jindo.new(src)
end

p potential.energy(r)
p potential.dedr(r)
