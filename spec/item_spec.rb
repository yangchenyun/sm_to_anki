require 'minitest/spec'
require 'minitest/autorun'
require 'sm_to_anki'

describe SmToAnki::Item do
  before do
    @working_dir = File.expand_path("#{File.dirname(__FILE__)}/../fixtures")
  end

  it "should create an SmToAnki::Item instance from Supermemo SmToAnki::Item xml files" do
    item = SmToAnki::Item.new("simple_qa", "#{@working_dir}/item_types/")
    item.id.must_equal 'simple_qa'
    item.abs_url.must_equal File.join("#{@working_dir}/item_types/", "itemsimple_qa.xml")
    item.question.must_equal "What's the difference between child selector and descendant selector?"
    item.answer.must_equal "The descendant selector matches all elements that are descendants of the parent element, including elements that are not direct descendants."
  end

  it "should raise an error for other xml files" do
    assert_raises SmToAnki::Item::ItemError do
      SmToAnki::Item.new("not_supermemo", "#{@working_dir}/item_types/")
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
          SmToAnki::Item.new(file_name.to_s, "#{@working_dir}/item_types/")
            .type.must_equal type
       end
  end
end
