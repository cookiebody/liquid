require 'test_helper'

module SecurityFilter
  def add_one(input)
    "#{input} + 1"
  end
end

class SecurityTest < Test::Unit::TestCase
  include Liquid

  def test_no_instance_eval
    text = %( {{ '1+1' | instance_eval }} )
    expected = %| 1+1 |

    assert_equal expected, Template.parse(text).render!(@assigns)
  end

  def test_no_existing_instance_eval
    text = %( {{ '1+1' | __instance_eval__ }} )
    expected = %| 1+1 |

    assert_equal expected, Template.parse(text).render!(@assigns)
  end


  def test_no_instance_eval_after_mixing_in_new_filter
    text = %( {{ '1+1' | instance_eval }} )
    expected = %| 1+1 |

    assert_equal expected, Template.parse(text).render!(@assigns)
  end


  def test_no_instance_eval_later_in_chain
    text = %( {{ '1+1' | add_one | instance_eval }} )
    expected = %| 1+1 + 1 |

    assert_equal expected, Template.parse(text).render!(@assigns, :filters => SecurityFilter)
  end

  def test_does_not_add_filters_to_symbol_table
    current_symbols = Symbol.all_symbols

    test = %( {{ "some_string" | a_bad_filter }} )

    template = Template.parse(test)
    assert_equal [], (Symbol.all_symbols - current_symbols)

    template.render!
    assert_equal [], (Symbol.all_symbols - current_symbols)
  end

  def test_does_not_add_drop_methods_to_symbol_table
    current_symbols = Symbol.all_symbols

    assigns = { 'drop' => Drop.new }
    assert_equal "", Template.parse("{{ drop.custom_method_1 }}", assigns).render!
    assert_equal "", Template.parse("{{ drop.custom_method_2 }}", assigns).render!
    assert_equal "", Template.parse("{{ drop.custom_method_3 }}", assigns).render!

    assert_equal [], (Symbol.all_symbols - current_symbols)
  end
end # SecurityTest
