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

    it "should only only contain one URI" do
      @parser.keys.size.should == 1
    end

    it "should return validation errors" do
      @parser[@uri][:errors].size.should == 24 # That URI should have 24 errors.

      error = @parser[@uri][:errors].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"
    end

    it 'should return validation errors by line number' do
      @parser[@uri][36][:errors].size.should == 1 # There should be one error for line 36.

      error = @parser[@uri][36][:errors].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"
    end

    it "should return validation warnings" do
      @parser[@uri][:warnings].size.should == 4

      warning = @parser[@uri][:warnings].first
      warning[:line].should == '241'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts .user_info .comments .comment and .photo hr'
    end

    it 'should return validation warnings by line number' do
      @parser[@uri][241][:warnings].size.should == 4 # There should be four warnings for line 241.

      warning = @parser[@uri][241][:warnings].first
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

    it "should only contain two URIs" do
      @parser.keys.size.should == 2
    end

    it "should return validation errors" do
      @parser[@uris.first][:errors].size.should == 24
      @parser[@uris.last][:errors].size.should == 1

      error = @parser[@uris.first][:errors].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"

      error = @parser[@uris.last][:errors].first
      error[:line].should == '60'
      error[:type].should == 'parse-error'
      error[:context].should == '* html #facebox_overlay'
      error[:subtype].should == 'unrecognized'
      error[:skipped_string].should == "document.body.scrollHeight > document.body.offsetHeight ? document.body.scrollHeight : document.body.offsetHeight + 'px')"
      error[:message].should =~ /Value Error :  height \(http:\/\/www.w3.org\/TR\/CSS21\/visudet.html#propdef-height\)\s*Parse Error/
    end

    it 'should return validation errors by line number' do
      @parser[@uris.first][36][:errors].size.should == 1 # There should be one error for line 36 in the first URI.
      @parser[@uris.last][60][:errors].size.should == 1 # There should be one error for line 60 in the last URI.

      error = @parser[@uris.first][36][:errors].first
      error[:line].should == '36'
      error[:type].should == 'parse-error'
      error[:context].should == '#customer_left.customized, #customer_right.customized'
      error[:subtype].should == 'exp'
      error[:skipped_string].should == '5px'
      error[:message].should == "Property -moz-border-radius doesn't exist :"

      error = @parser[@uris.last][60][:errors].first
      error[:line].should == '60'
      error[:type].should == 'parse-error'
      error[:context].should == '* html #facebox_overlay'
      error[:subtype].should == 'unrecognized'
      error[:skipped_string].should == "document.body.scrollHeight > document.body.offsetHeight ? document.body.scrollHeight : document.body.offsetHeight + 'px')"
      error[:message].should =~ /Value Error :  height \(http:\/\/www.w3.org\/TR\/CSS21\/visudet.html#propdef-height\)\s*Parse Error/
    end

    it "should return validation warnings" do
      @parser[@uris.first][:warnings].size.should == 4
      @parser[@uris.last][:warnings].size.should == 0

      warning = @parser[@uris.first][:warnings].first
      warning[:line].should == '236'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts .user_info .comments .comment and .user_info hr'
    end

    it 'should return validation warnings by line number' do
      @parser[@uris.first][236][:warnings].size.should == 4 # There should be four warnings for line 236 in the first URI.

      warning = @parser[@uris.first
      ][236][:warnings].first
      warning[:line].should == '236'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts .user_info .comments .comment and .user_info hr'
    end
  end

  describe "embedded styles results" do
    before(:each) do
      @parser.parse(embedded_styles_with_warnings)
      @uri = "http://zerosum.org/"
    end

    it "should only contain one URI" do
      @parser.keys.size.should == 1
    end

    it "should have no validation errors" do
      @parser[@uri][:errors].size.should == 0
    end

    it "should return validation warnings" do
      @parser[@uri][:warnings].size.should == 9 # That URI should have nine warnings.

      warning = @parser[@uri][:warnings].first
      warning[:line].should == '31'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts a:hover and .axiom'
    end

    it 'should return validation warnings by line number' do
      @parser[@uri][31][:warnings].size.should == 1 # There should be one warning for line 31.

      warning = @parser[@uri][31][:warnings].first
      warning[:line].should == '31'
      warning[:level].should == '1'
      warning[:message].should == 'Same colors for color and background-color in two contexts a:hover and .axiom'
    end
  end

  private

  def single_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/single_stylesheet_with_errors.xml')).read
  end

  def multiple_stylesheet_results
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/multiple_stylesheets_with_errors.xml')).read
  end

  def embedded_styles_with_warnings
    File.open(File.expand_path(File.dirname(__FILE__) + '/fixtures/embedded_styles_with_warnings.xml')).read
  end

end
