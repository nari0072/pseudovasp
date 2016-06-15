require 'yaml'
include Math

class MomentMethod
  BOLTZ = 1.380658e-16
  PLANCK = 6.626e-27
  HBAR = PLANCK/(2.0*PI)
  AVOGADO = 6.023e23
  STRUCTURE = "jindofcc"

  def initialize(dir_path)
    p 'Hi, moment'
    select
    calc_moment
  end

  def check(*val)
    p val.join(", ")
  end

  def select(file='POTCAR')
    src = YAML.load_file(file)
    h=@@potential=case src[:type]
    #ここの微分式POTCARのほうにいれたい．メソッドそのままPOTCARに入れるのもありかも．．
    when 'lj_jindo'
      DiffLjJindo.new(src)
    else
      p "*********************missed potcar*******************"
      exit(0)
    end
  end

  def calc_moment
    p "start calc_moment"
    a0 = calc_a0(@@potential.m, @@potential.n, @@potential.r0)
    p "a0="
    check(a0)
    for i in 1..10
      temp = 100*(i-1)
      temp = 10 if i==1
      theta = BOLTZ*temp
      gap = Array.new(6){ Array.new(201) }
      aa1=[]
      aa1[0]=a0
      aa2=[]
      diff=[]
      comp_gap = 0
      for change in 1..5
        for same in 1..200
          gap[change][same] = (same-1)*(10**(-(9+change))).to_f
          aa1[change] = aa1[change-1] + gap[change][same]
          aa2[change] = aa1[change]*sqrt(2)
          a1 = aa1[change]
          a2 = aa2[change]
          k = calc_k(a1,a2)
          atom_mass = @@potential.atom_mass/AVOGADO
          omega = sqrt(k/atom_mass)
          x = HBAR*omega/(2.0*theta)
          gamma = calc_gamma(a1,a2,STRUCTURE)
          gt_k2 = gamma*theta/k**2
          u0 = calc_u0(a1,a2)
          psi0 = calc_psi0(x,theta)
          large_a = calc_large_a(x, gt_k2)
          y0 = calc_y0(k, gamma, theta, large_a)
          psi_nonli = calc_psi_nonli(k, x, gamma,theta) #nonlinear?thesis(1988)p516(19)

          #*************ここからまだ元のまま，，，これから作成．．
          total_gap = comp_gap + gap[change][same]
          diff[same] = y0 - total_gap
          break if diff_sign?(diff[same], diff[same-1]) if same > 1
          #end
        end

        aa1[change] = aa1[change] + gap[change][same-1] - gap[change][same] if same >1 #一応jy0 > 1つけとく
        aa2[change] = aa1[change]*sqrt(2)
        comp_gap = comp_gap + gap[change][same-1]
        a1_cal = a0+comp_gap
        a2_cal = sqrt(2)*a1_cal
      end
      a1_cal = a1_cal*1.0e8
      a2_cal = a2_cal*1.0e8
      #harmonic = u0+psai0#これ使ってない
      puts "T(K), a1, a2_cal(A), k, g="
      check(temp, a1_cal, a2_cal, k, gamma)
      puts "temp, u0, harmonic free, free="
      check(temp, u0, psi0, psi_nonli)
      #eVに単位変換
      u0_ev = u0*8.617385e-05
      psi0_ev = psi0*6.2415064e11
      psi_nonli_ev = psi_nonli*6.2415064e11
      psi = u0_ev + psi0_ev + psi_nonli_ev
      puts "u0_ev, psi0_ev, psi_nonli_ev, psi, large_a"
      check(u0_ev, psi0_ev, psi_nonli_ev, psi, large_a)
      puts"\n"
    end

  end

  def diff_sign?(n1, n2)
    return true if n1*n2 < 0
    return false
  end

  def calc_a0(m, n, r0)
    an=12.0 + 6.0/sqrt(2)**m
    am=12.0 + 6.0/sqrt(2)**n
    return exp( log(r0) + log(an/am)/(m-n) )
  end

  def calc_k(a1,a2)
    k = 2.0*@@potential.de2dr2(a1) + 4.0*@@potential.dedr(a1)/a1 + @@potential.de2dr2(a2) + 2.0*@@potential.dedr(a2)/a2;
    return k*BOLTZ
  end

  def calc_gamma(a1,a2,structure)
    case structure
    when "jindofcc"
      diff_u4_a1 = 2.0*@@potential.de4dr4(a1) + 12.0*@@potential.de3dr3(a1)/a1 - 42.0*@@potential.de2dr2(a1)/(a1*a1) + 42.0*@@potential.dedr(a1)/(a1*a1*a1)
      diff_u4_a2 = 2.0*@@potential.de4dr4(a2) + 12.0*@@potential.de2dr2(a2)/(a2*a2) - 12.0*@@potential.dedr(a2)/(a2*a2*a2)
      diff_x2y2_a1 = @@potential.de4dr4(a1) + 2.0*@@potential.de3dr3(a1)/a1 - 8.0*@@potential.de2dr2(a1)/(a1*a1) + 8.0*@@potential.dedr(a1)/(a1*a1*a1)
      diff_x2y2_a2 = 4.0*@@potential.de3dr3(a2)/a2 - 11.0*@@potential.de2dr2(a2)/(a2*a2) + 11.0*@@potential.dedr(a2)/(a2*a2*a2)
    when "sakakifcc"
      diff_u4_a1 = 2.0*@@potential.de4dr4(a1) + 12.0*@@potential.de3dr3(a1)/a1 - 6.0*@@potential.de2dr2(a1)/(a1*a1) + 6.0*@@potential.dedr(a1)/(a1*a1*a1)
      diff_u4_a2 = 2.0*@@potential.de4dr4(a2) + 12.0*@@potential.de2dr2(a2)/(a2*a2) - 12.0*@@potential.dedr(a2)/(a2*a2*a2)
      diff_x2y2_a1 = @@potential.de4dr4(a1) + 2.0*@@potential.de3dr3(a1)/a1 + 3.0*@@potential.de2dr2(a1)/(a1*a1) - 3.0*@@potential.dedr(a1)/(a1*a1*a1)
      diff_x2y2_a2 = 4.0*@@potential.de3dr3(a2)/a2 - 6.0*@@potential.de2dr2(a2)/(a2*a2) + 6.0*@@potential.dedr(a2)/(a2*a2*a2)
    end
    @gamma1 = (1.0/48)*(diff_u4_a1 + diff_u4_a2)*BOLTZ
    @gamma2 = (6.0/48)*(diff_x2y2_a1 + diff_x2y2_a2)*BOLTZ
    return gamma = 4.0*(@gamma1+@gamma2)#p516(18)
  end

  def calc_u0(a1,a2)
    #最近接１２，第２近接６はfccだから．．．POTCARにその情報を入れたほうがいいかも
    z1=12
    z2=6
    return u0 = 0.5*(z1*@@potential.energy(a1) + z2*@@potential.energy(a2))
  end

  def calc_psi0(x, theta)
    arg0 = 1.0 - exp(-2.0*x)
    return psai0 = 3.0*theta*(x+log(arg0))
  end

  def calc_large_a(x, gt_k2)
    xcothx = x/tanh(x)
    xcothx = x*(exp(x)+exp(-x))/(exp(x)-exp(-x))
    xcothx2 = xcothx**2
    xcothx3 = xcothx**3
    xcothx4 = xcothx**4
    xcothx5 = xcothx**5
    small_a1 = 1.0 + xcothx/2.0
    small_a2 = 13.0/3.0 + 47.0*xcothx/6.0 + 23.0*xcothx2/6.0 + xcothx3/2.0
    small_a3 = -(25.0/3.0 + 121.0*xcothx/6.0 + 50.0*xcothx2/3.0 + 16.0*xcothx3/3.0 + xcothx4/2.0)
    small_a4 = 43.0/3.0 + 93.0*xcothx/2.0 + 169.0*xcothx2/3.0 + 83.0*xcothx3/3.0 + 22.0*xcothx4/3.0 + xcothx5/2.0
    return large_a = small_a1 + small_a2*gt_k2**2 + small_a3*gt_k2**3 + small_a4*gt_k2**4
  end

  def calc_y0(k, gamma, theta, large_a)
    return sqrt( 2.0*gamma*theta**2*large_a/(3.0*k**3))
  end

  def calc_psi_nonli(k, x, gamma,theta)
    fac_gam = @gamma1*@gamma1 + 2.0*@gamma1*@gamma2
    @gamma1
    @gamma2
    xcothx = x/tanh(x)
    #xcothx = x*(exp(x)+exp(-x))/(exp(x)-exp(-x))
    xcothx2 = xcothx**2
    fac1 = 1.0 + xcothx/2.0
    fac2 = 1.0 + xcothx
    term1 = (theta/k)**2 * (@gamma2*xcothx2 - 2.0*@gamma1*fac1/3.0)
    term2 = (4.0*@gamma2**2 / 3.0)*xcothx*fac1-2.0*fac_gam*fac1*fac2
    term2 = (2.0*theta**3/k**4)*term2
    return 3.0*(term1+term2)
  end

end

#lj.rbにclassLJ_jindoがあるけど，後の切り分けのために新たに作成.理想はPOTCARの中
class DiffLjJindo
  attr_reader :m, :n, :r0, :atom_mass
  def initialize(src)
    @@d0,@@m,@@n,@@r0=src[:d0],src[:m],src[:n],src[:r0_no_angstrom]
    @m, @n, @r0, @atom_mass=src[:m],src[:n], src[:r0_no_angstrom], src[:atom_mass_no_avogado]#計算のために参照できるようにしとく
  end

  def energy(r)
    ene=-@@d0*((r/@@r0)**(-@@n)*@@m-(r/@@r0)**(-@@m)*@@n)/(@@m-@@n)
  end

  def dedr(r)
    dedr=-@@d0*@@m*@@n / ((@@n-@@m)*r) * ((@@r0/r)**@@n - (@@r0/r)**@@m)
  end

  def de2dr2(r)
    de2dr2 = @@d0*@@m*@@n / ((@@n-@@m)*r**2) * ((@@n+1)*(@@r0/r)**@@n - (@@m+1)*(@@r0/r)**@@m)
  end

  def de3dr3(r)
    de3dr3 = @@d0*@@m*@@n / ((@@n-@@m)*r**3) * ((@@m+1)*(@@m+2)*(@@r0/r)**@@m - (@@n+1)*(@@n+2)*(@@r0/r)**@@n)
  end

  def de4dr4(r)
    de4dr4 = @@d0*@@m*@@n / ((@@n-@@m)*r**4) * ((@@n+1)*(@@n+2)*(@@n+3)*(@@r0/r)**@@n - (@@m+1)*(@@m+2)*(@@m+3)*(@@r0/r)**@@m)
  end
end
