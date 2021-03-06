# -*- coding: utf-8 -*-
module EAM
  extend self
  # set for Al, E=-1.0 at r=4.04...
# for phi(r0)=-1.0, poq=3.0, r0=2.8577
A0,B0,P,POQ,Q=69.1378255, 12.47431958, 2.148157653, 2.893854749, 0.7423170267
# for phi(r0)=-3.39, Ev=0.8, p=3.0 at r0, r0=2.8577
  CUT_OFF=4.0*0.8

module_function

  def atom_energy()#LJP
    ene,rho=0.0,0.0
    nl.each do |aj|
      r=distance(@pos,aj.pos)
      ene += A0*exp(-P*r)
      h = B0*exp(-Q*r)
      rho += h*h
    end
    return ene-sqrt(rho)
  end

  def atom_force()
    atom_force_katagiri
#    atom_force_bob
  end

  def atom_force_bob()
    rho=0.0
    f,f_p=[0.0,0.0,0.0],[0.0,0.0,0.0]
    f_n_left,f_n_right=[0.0,0.0,0.0],[0.0,0.0,0.0]
    nl.each do |aj|
      xx=f_distance(@pos,aj.pos) 
      r=distance(@pos,aj.pos) 
      rho_j=0.0 #ここの計算がloopの中にあるのは正しいか？
      aj.nl.each{|ak|
#        next if (ak.pos==@pos) #こいつを除外する理由は何？
        r_k=distance(aj.pos,ak.pos)
        h_k=B0*exp(-Q*r_k)
        rho_j+=h_k*h_k
      }
      dfdrho_j=1/(2*sqrt(rho_j))
      dpdr=-A0*P*exp(-P*r) 
      h=B0*exp(-Q*r)
      rho+=h*h 
      dhdr=-2*Q*h*h #phi'(r)
      xx.each_with_index{|xi,i| 
        f_p[i]+=xi/r*dpdr
        f_n_left[i]+= -xi/r*dhdr
        f_n_right[i]+= xi/r*dhdr*dfdrho_j
      }
    end

    dfdrho_i=1/(2*sqrt(rho))
    3.times do |i|
      f_n_left[i]*=dfdrho_i
      f[i]=-(f_p[i]+f_n_left[i]+f_n_right[i])
    end
    return f
  end

  def atom_force_katagiri()
    rho=0.0
    f,f_p=[0.0,0.0,0.0],[0.0,0.0,0.0]
    f_n_left,f_n_right=[0.0,0.0,0.0],[0.0,0.0,0.0]
    nl.each do |aj|
      xx=f_distance(@pos,aj.pos) 
      r=distance(@pos,aj.pos) 
      f_rho_k=0.0 #f_n_right の計算 
      aj.nl.each{|ak|#原子 j の最近接原子
        next if (ak.pos==@pos)
        rho_k=0.0
        kr=distance(aj.pos,ak.pos)
        ktmp=exp(-Q*kr)
        rho_k=ktmp*ktmp
        f_rho_k+=1/(2*sqrt(rho_k))
      }
      dpdr=-A0*P*exp(-P*r)  #g_p の計算
      tmp=exp(-Q*r)
      rho+=tmp*tmp #g_n_left の計算
      phi=-2*B0*B0*Q*tmp*tmp #phi'(r)
      xx.each_with_index{|xi,i| 
        f_p[i]+=xi/r*dpdr
        f_n_left[i]+= -xi/r*phi
        f_n_right[i]+= xi/r*phi*f_rho_k
      }
    end

    f_rho=1/(2*sqrt(rho))
    3.times do |i|
      f_n_left[i]*=f_rho
      f[i]=-(f_p[i]+f_n_left[i]+f_n_right[i])
    end
    return f
  end

end    
