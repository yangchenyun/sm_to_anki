# encoding: utf-8

require 'minitest/spec'
require 'minitest/autorun'
require 'sm_to_anki'
require 'nokogiri'

describe SmToAnki::Item do
  before do
    @working_dir = File.expand_path("#{File.dirname(__FILE__)}/../fixtures")
  end

  it "should create an SmToAnki::Item instance from Supermemo SmToAnki::Item xml files" do
    item = SmToAnki::Item.new("simple_qa", "#{@working_dir}/item_types/", 'fake_course')
    item.id.must_equal 'simple_qa'
    item.abs_url.must_equal File.join("#{@working_dir}/item_types/", "itemsimple_qa.xml")
    item.course.must_equal 'fake_course'
    item.question.text.must_equal "What's the difference between child selector and descendant selector?"
    item.answer.text.must_equal "The descendant selector matches all elements that are descendants of the parent element, including elements that are not direct descendants."
  end

  it "should raise an error for other xml files" do
    assert_raises SmToAnki::Item::ItemError do
      SmToAnki::Item.new("not_supermemo", "#{@working_dir}/item_types/", 'fake_course')
    end
  end

  it "should detect the right item type" do
      { simple_qa: 'simple_qa',
        single_cloze: 'cloze',
        multi_cloze: 'cloze',
        checkbox: 'checkbox',
        truth: 'truth',
        radio: 'radio'}
      .each do |file_name, type|
          SmToAnki::Item.new(file_name.to_s, "#{@working_dir}/item_types/", 'fake_course')
            .type.must_equal type
       end
  end

  it "should generate the first field as {course_title}_id" do

  end

  it "should parse simple to three fields" do
      item = SmToAnki::Item.new("simple_qa", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 3
      assert assert result[0].include?('simple_qa')
      assert assert result[1].include?("What's the difference")
      assert assert result[2].include?("direct descendants.")
  end

  it "should parse radio to four fields, parse the <radio> tag correctly" do
      item = SmToAnki::Item.new("radio", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 4
      assert result[0].include?('radio') # id
      assert result[1].include?("using percentages") # question
      assert result[1].include?("top left/top right/bottom left/bottom right") # question / choice
      assert result[2].include?("top left") #right answer
      assert result[3].include?("test answer") # explanation
  end

  it "should parse checkbox to four fields, parse the <checkbox> tag correctly" do
      item = SmToAnki::Item.new("checkbox", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 4
      assert result[0].include?('checkbox') # id
      assert result[1].include?("div * em") # question
      assert result[1].include?("“Universal” in the h1 element/") # question / choice
      assert result[1].include?("“immediate” in the forth em element") # question / choice
      assert result[2].include?("“/emphasize” in the p element") # answer
      assert result[3].include?("the universal selector doesn't match") # explanation
  end

  it "should parse truth to four fields, parse the <true-false> tag correctly" do
      item = SmToAnki::Item.new("truth", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 4
      assert result[0].include?('truth') # id
      assert result[1].include?("Doctype sniffing") # question
      assert result[1].include?("True/False") # question / choice
      assert result[2].include?("False") # answer use the String in false field
      assert result[3].include?("XML MIME") # explanation
  end

  it "should parse single cloze correctly with the <spellpad> tag" do
      item = SmToAnki::Item.new("single_cloze", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 3
      assert result[0].include?('single_cloze') # id
      assert result[1].include?("How to selector") # question
      assert result[1].include?("{{c1::h2+p}})") # the cloze
      assert result[2].include?("An adjacent selector") 
  end

  it "should parse multiple cloze correctly with the <spellpad> tag" do
      item = SmToAnki::Item.new("multi_cloze", "#{@working_dir}/item_types/", 'fake_course')
      result = item.process.split('|')
      result.length.must_equal 4
      assert result[0].include?('multi_cloze') # id
      assert result[1].include?("Pseudo-class") # question
      assert result[1].include?("{{c1:::link}}") # cloze 1
      assert result[1].include?("{{c2:::visited}}") # cloze 2
      assert result[2].include?("") # answer use the String in false field
  end

  it "should keep html tags" do
      item = SmToAnki::Item.new("html_tag", "#{@working_dir}/field_processing/", 'fake_course')
      result = item.process.split('|')
      assert result[2].include?("<span>bold</span><br></br>"), "Failed, the passed in is #{result[2]}"
  end

  it "should parse the <gfx> tags to <img> tag" do
      item = SmToAnki::Item.new("img", "#{@working_dir}/field_processing/", 'fake_course')
      result = item.process.split('|')
      assert result[1].include?('<img src="fake_course_imgd.jpg"></img>'), "Failsed, the passed in is #{result[1]}"
      assert result[1].include?('<img src="fake_course_00117e.jpg"></img>'), "Failed, the passed in is #{result[1]}"
  end

  it "should decode utf-8 encoding string" do
      item = SmToAnki::Item.new("utf8", "#{@working_dir}/field_processing/", 'fake_course')
      result = item.process.split('|')
      assert result[2].include?("/t'ɔːrtəs/"), "Failed, the real passed in is #{result[2]}"
  end

end
