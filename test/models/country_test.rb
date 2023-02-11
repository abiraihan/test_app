require "test_helper"

class CountryTest < ActiveSupport::TestCase
  test "the truth" do
    @country = Country.new(name: 'Khulna')
    assert @country.valid?
  end

  test "geom should be present" do
    @country = Country.new(name: " ")
    assert_not @country.valid?
  end
end
