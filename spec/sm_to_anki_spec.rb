require 'minitest/spec'
require 'minitest/autorun'
require 'sm_to_anki'
require 'FileUtils'
describe SmToAnki::CourseProcessor do

    before do
      @working_dir = File.expand_path("#{File.dirname(__FILE__)}/../fixtures")
      @course_processor = SmToAnki::CourseProcessor.new("#@working_dir")
    end

    it "process_dir should be set to current working directory" do
      @course_processor.process_dir.must_equal @working_dir
    end

    it "the course.xml should be opened and parsed by nokogiri" do
      @course_processor.course_doc.must_be_instance_of Nokogiri::XML::Document
    end
    
    ## fetch course.xml data into course_info instance variable
    it "should store the fetched data in course_info hash" do
      @course_processor.course_info.must_be_instance_of Hash
    end

    it "should fetch the course title right" do
      @course_processor.course_info.has_key?("title").must_equal true
      @course_processor.course_info['title'].must_equal "fake_course"
    end

    it "should remember the items processed before" do
      @course_processor.processed_items.must_equal ["00010", "00012", "00013"]
    end

    it "element[type=pres] will store the [:name] as hash keys " do
      @course_processor.course_info['content'].has_key?('Category1').must_equal true
      @course_processor.course_info['content'].has_key?('Category2').must_equal true
      @course_processor.course_info['content']['Category2'].has_key?('sub-category1').must_equal true
    end

    it "element[type=pres] hierarchy will be preserved" do
      @course_processor.course_info['content'].has_key?('sub-category1').must_equal false
      @course_processor.course_info['content']['Category2'].has_key?('sub-category1').must_equal true
      @course_processor.course_info['content']['Category2']['sub-category2'].has_key?("category-level-3").must_equal true
    end
    
    it "exercises will be stored in an array and grouped by its parent" do
      @course_processor.course_info['content']['Category1'].must_be_instance_of Array
      @course_processor.course_info['content']['Category1'].length.must_equal 2
    end

    it "should fetch the id from element[type=exercise] and keep 5 digitals" do
      @course_processor.course_info['content']['Category1'].must_equal ['00002', '00003']
    end

    ## process_course and items
    it "should create an folders with corrrect hierarchy for each sub_category" do
      @course_processor.process_course(@course_processor.course_info, @working_dir)
      assert File.directory?("#{@working_dir}/fake_course_anki")
      assert File.directory?("#{@working_dir}/fake_course_anki/Category1")
      assert File.directory?("#{@working_dir}/fake_course_anki/Category2/sub-category1")
      assert File.directory?("#{@working_dir}/fake_course_anki/Category2/sub-category2/category-level-3")
    end

    it "should only process validate items" do
      mock = MiniTest::Mock.new
      item_to_be_processed = [2,3,6,8]
      item_not_to_be_processed = [1,4,5,7,9]
      item_to_be_processed.each do |item|
        mock.expect(:process_item, true, ["%05d" % item, @working_dir, String])
      end
    end

    it "should create/use file according to their types" do
      assert Dir.entries("#{@working_dir}/fake_course_anki/Category1").include?('simple_qa.txt'), "simple_qa.txt is not created"
      assert Dir.entries("#{@working_dir}/fake_course_anki/Category2/sub-category1").include?('truth.txt'), "truth.txt is not created at Category2/sub-category1"
      assert Dir.entries("#{@working_dir}/fake_course_anki/Category2/sub-category2/category-level-3").include? 'cloze.txt'
    end

    it "should not override existing record" do
      assert_equal File.open("#{@working_dir}/fake_course_anki/Category1/simple_qa.txt").readlines.size, 2
    end
    
    # process each items
    
    # clear temporary files
   it "should clear leftovers" do
     FileUtils.rm_rf("#{@working_dir}/fake_course_anki/")
   end
end
