require 'minitest/spec'
require 'minitest/autorun'
require 'sm_to_anki'

describe SmToAnki::CourseProcessor do

    before do
      @working_dir = "#{File.dirname(__FILE__)}/../fixtures"
      @course_processor = SmToAnki::CourseProcessor.new("#@working_dir")
      @course_processor.fetch_course_info()
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
      @course_processor.course_info['title'] == "Fake Course"
    end

    it "element[type=pres] will store the [:name] as hash keys " do
      @course_processor.course_info.has_key?('Category1').must_equal true
      @course_processor.course_info.has_key?('Category2').must_equal true
      @course_processor.course_info['Category2'].has_key?('sub-category1').must_equal true
    end

    it "element[type=pres] hierarchy will be preserved" do
      @course_processor.course_info.has_key?('sub-category1').must_equal false
      @course_processor.course_info['Category2'].has_key?('sub-category1').must_equal true
      @course_processor.course_info['Category2']['sub-category2'].has_key?("category-level-3").must_equal true
    end
    
    it "exercises will be stored in an array and grouped by its parent" do
      @course_processor.course_info['Category1'].must_be_instance_of Array
      @course_processor.course_info['Category1'].length.must_equal 2
    end

    it "should fetch the id from element[type=exercise] and keep 5 digitals" do
      @course_processor.course_info['Category1'].must_equal ['00002', '00003']
    end

    ## detect_item_types
    it "should accept and only accept item xml files" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/no_item.xml").must_be_nil
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/simple_qa.xml").wont_be_nil
    end

    it "should detect truth questions by return 'truth'" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/truth.xml").must_equal 'truth'
    end

    it "should detect cloze questions by return 'cloze'" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/single_cloze.xml").must_equal 'cloze'
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/multi_cloze.xml").must_equal 'cloze'
    end

    it "should detect checkbox questions by return 'checkbox'" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/checkbox.xml").must_equal 'checkbox'
    end
    
    it "should detect radio questions by return 'radio'" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/radio.xml").must_equal 'radio'
    end

    it "should detect other type as 'simple_qa'" do
      @course_processor.detect_exercise_type("#{@working_dir}/item_types/simple_qa.xml").must_equal 'simple_qa'
    end
end
