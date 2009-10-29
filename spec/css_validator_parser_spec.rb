require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CSS Validator Parser" do

  before(:each) do
    @parser = CssValidatorParser.new
  end

  describe "single stylesheet results" do

    before(:each) do
      @parser.parse(single_stylesheet_results)
      @uri = "http://localhost:3000/stylesheets/master.css?1256692632"
    end

    it "should return validation errors" do
      @parser.errors.should_not be_empty

      error = @parser.errors[@uri].first
      error[:line].should_not be_empty
      error[:type].should_not be_empty
      error[:context].should_not be_empty
      error[:subtype].should_not be_empty
      error[:skipped_string].should_not be_empty
      error[:message].should_not be_empty
    end

    it "should return validation warnings" do
      @parser.warnings.should_not be_empty

      warning = @parser.warnings[@uri].first
      warning[:line].should_not be_empty
      warning[:level].should_not be_empty
      warning[:message].should_not be_empty
    end
  end

  private

  def single_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/single_stylesheet_with_errors.xml')).read
  end

end
