require 'pathname'
require 'test/unit'

$LOAD_PATH.unshift Pathname.new(__dir__).join('./')

require 'src/engine'

class UnitTest < Test::Unit::TestCase
end

class TitleTest < UnitTest
  def test_attending
    engine = Engine.new
    engine.handle_message("ATTENDING")
    response = engine.next_response
    assert_equal "ATTEND;KlausDavid", response
  end

  def test_dices_in_descending_order
    engine = Engine.new
    engine.handle_message("DICES;21")
    response = engine.next_response
    assert_equal "DICES;21;KlausDavid", response
  end

  def test_see_or_roll
    engine = Engine.new
    engine.handle_message("NEW DICES;21")
    engine.handle_message("SEE OR ROLL")
    response = engine.next_response
    assert_equal "SEE;KlausDavid", response
  end

  def test_see_or_roll_1
    engine = Engine.new
    engine.handle_message("NEW DICES;11")
    engine.handle_message("SEE OR ROLL")
    response = engine.next_response
    assert_equal "SEE;KlausDavid", response
  end

  def test_see_or_roll_if_only_index_plus_one
    engine = Engine.new
    engine.handle_message("NEW DICES;51")
    engine.handle_message("NEW DICES;52")
    engine.handle_message("SEE OR ROLL")
    response = engine.next_response
    assert_equal "SEE;KlausDavid", response
  end

  def test_see_or_roll_2
    engine = Engine.new
    engine.handle_message("NEW DICES;65")
    engine.handle_message("SEE OR ROLL")
    response = engine.next_response
    assert_equal "ROLL;KlausDavid", response
  end

  def test_new_dices_with_need_for_lie
    engine = Engine.new
    engine.handle_message("NEW DICES;45")
    engine.handle_message("DICES;32")
    response = engine.next_response
    assert_equal "DICES;51;KlausDavid", response
  end

  def test_new_dices_with_need_for_maexchen
    engine = Engine.new
    engine.handle_message("NEW DICES;66")
    engine.handle_message("DICES;32")
    response = engine.next_response
    assert_equal "DICES;21;KlausDavid", response
  end

  def test_new_dices_with_no_need_for_lie
    engine = Engine.new
    engine.handle_message("NEW DICES;45")
    engine.handle_message("DICES;46")
    response = engine.next_response
    assert_equal "DICES;46;KlausDavid", response
  end

  def test_reset_dices_after_rounde_ended
    engine = Engine.new
    engine.handle_message("NEW DICES;45")
    engine.handle_message("ROUND ENDED")
    engine.handle_message("DICES;32")
    response = engine.next_response
    assert_equal "DICES;32;KlausDavid", response
  end

end
