module LJ
  A0=1.587401051*0.7071067812/2.857701314;
  E0=-1*4.0/12.0;

  A=18.19007708
  B=89.22765864
  CUT_OFF=4.0*0.8
  module_function

  def atom_energy()#LJP
    ene=0.0
    nl.each do |aj|
      r=distance(@pos,aj.pos)
      ene += -A*(1/r**3)+B*(1/r**5)
    end
    return ene
  end

  def atom_force()
    f=[0.0,0.0,0.0]
    nl.each do |aj|
      x,y,z=f_distance(@pos,aj.pos)
      r=sqrt(x**2+y**2+z**2)
      dedr=((3.0*A/r**4)-(5.0*B/r**6))
      f[0] += -x/r*dedr
      f[1] += -y/r*dedr
      f[2] += -z/r*dedr
    end
    return f
  end
end

