# 【概要】
VASPに似せて系のエネルギーを計算するソフト．
# 【Directory構造】
- [eam](eam)
- [pseudovasp](pseudovasp)
- [平衡モンテカルロ法の実装，nvt, npt, Frenkelなどを含む．](MonteCarloSimulations)
- [粒界構築maker, viewer, adjuster](BoundaryModel)
- [POSCARを読み込むlibrary](poscar)
- [pseudoVASPの本体．eam, ljをmoduleとして読み込んでいる](pseudo_vasp)
- [力の解析解と数値解の一致検証](force_check)
  - [ ](EAM_force),[ ](LJ_force),

# 【変更履歴と改修メモ】
- [pVASP_EAM-LJSelector](pVASP_EAM-LJSelector)
