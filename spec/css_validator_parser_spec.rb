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
      @parser.errors.size.should == 1 # There should only be one URI.
      @parser.errors[@uri].size.should == 24 # That URI should have 24 errors.

      error = @parser.errors[@uri].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"
    end

    it "should return validation warnings" do
      @parser.warnings.size.should == 1 # There should only be one URI.
      @parser.warnings[@uri].size.should == 4 # That URI should have 4 warnings.

      warning = @parser.warnings[@uri].first
      warning[:line].should == '241'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts .user_info .comments .comment and .photo hr'
    end
  end

  describe "multiple stylesheet results" do
    before(:each) do
      @parser.parse(multiple_stylesheet_results)
      @uris = ["http://staging.snap2twitter.com/stylesheets/master.css?1256667744", "http://staging.snap2twitter.com/stylesheets/facebox.css?1256667744"]
    end

    it "should return validation errors" do
      @parser.errors.size.should == 2 # There should only be two URIs.
      @parser.errors[@uris.first].size.should == 24
      @parser.errors[@uris.last].size.should == 1

      error = @parser.errors[@uris.first].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"

      error = @parser.errors[@uris.last].first
      error[:line].should == '60'
      error[:type].should == 'parse-error'
      error[:context].should == '* html #facebox_overlay'
      error[:subtype].should == 'unrecognized'
      error[:skipped_string].should == "document.body.scrollHeight > document.body.offsetHeight ? document.body.scrollHeight : document.body.offsetHeight + 'px')"
      error[:message].should =~ /Value Error :  height \(http:\/\/www.w3.org\/TR\/CSS21\/visudet.html#propdef-height\)\s*Parse Error/
    end

    it "should return validation warnings" do
      @parser.warnings.size.should == 1 # There should only be one URI.
      @parser.warnings[@uris.first].size.should == 4

      warning = @parser.warnings[@uris.first].first
      warning[:line].should == '236'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts .user_info .comments .comment and .user_info hr'
    end
  end

  private

  def single_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/single_stylesheet_with_errors.xml')).read
  end

  def multiple_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/multiple_stylesheets_with_errors.xml')).read
  end

end
