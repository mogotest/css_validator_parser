require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CSS Validator Parser" do

  before(:each) do
    @parser = CssValidatorParser.new
  end

  describe "single stylesheet results" do
    it "should return validation errors" do
      @parser.parse(single_stylesheet_results)
      @parser.errors.should_not be_empty

      puts @parser.errors
    end
  end

  private

  def single_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/single_stylesheet_with_errors.xml')).read
  end

end
