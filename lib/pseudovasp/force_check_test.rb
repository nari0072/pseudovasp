require 'test/unit'
require_relative './force_check.rb'

class Force_check_TC < Test::Unit::TestCase
  attr_accessor :force_check

  #class化したForceCheckをここd一度だけ初期化．
  def setup
    @force_check = ForceCheck.new
  end

  #0番原子(7)の結果だけをチェック
  def test_0
    actual=@force_check.controller(0)
    expected ='||   7||    0.01207||    0.01234||    0.00000'
    assert expected, actual
  end

  #すべての原子の結果をチェック
  def test_all
    actual=@force_check.controller(-1)
    expected ="||   7||    0.01207||    0.01234||    0.00000\n||   9||    0.01207||   -0.01234||    0.00000\n||  11||    0.01115||   -0.01094||    0.00000\n||  13||    0.01115||    0.01094||    0.00000\n||  15||    0.01207||    0.00000||    0.01234\n||  16||    0.01207||    0.00000||   -0.01234\n||  19||    0.01115||    0.00000||   -0.01094\n||  20||    0.01115||    0.00000||    0.01094\n||  23||   -0.00001||   -0.00012||   -0.00012\n||  24||   -0.00001||   -0.00012||    0.00012\n||  25||   -0.00001||    0.00012||   -0.00012\n||  26||   -0.00001||    0.00012||    0.00012\n"
    assert expected, actual
  end
end

