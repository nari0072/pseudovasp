# 概要
VASPに似せて系のエネルギーをeam, ljポテンシャルで計算する．

# install
githubからdaddygongon/pseudovaspをdown load. あるいは
>gem install pseudovasp
かな．．．

# usage
```
require 'pseudovasp'

opts={output: :show_force, potential: :eam}
@lattice=PseudoVASP.new(poscar_name,opts)
print @lattice.display+"\n"
```
or，command line on terminal,
```
Usage: pvasp [options] FILE
    -v, --version                    show program Version.
        --potential TYPE             potential selection, TYPEs=eam or lj.
```
If FILE is omitted, use './POSCAR'.

# 構造
- [ポテンシャルeam,ljのパラメータ他](file.atom.html)
- pseudovasp -> class PseudoVASPに記述
- [平衡モンテカルロ法の実装，nvt, npt, Frenkelなどを含む．](MonteCarloSimulations)
- [力の解析解と数値解の一致検証](force_check)
  - [ ](EAM_force),[ ](LJ_force),
