require "sm_to_anki/version"
require 'nokogiri'

# The input is 
# Memo_course
# - course.xml
# - itemxxxxx.xml
# - media
#   -- xxxxx.jpg

# The output is
# processed_items/
# - itemxxxxx.xml
# anki_imports/
# - sub_category1
#   - simple_qa.txt
#   - blank.txt
#   - multi_choice.txt
#   - truth.txt
# - sub_category2
# {course_name}.txt
# {course_name}.media/

module SmToAnki
  module ItemProcessor
    
    def simple_qa(question, answer)
      # process the item.xml as simple Question and Answer
      # write to output text
      # {{Question}}, {{Answer}}, {{Explanation}}, [{{Image_URL}}], {{}}
      return {}
    end
    
    def cloze(question, answer)
      # process the item.xml as blank filling questions
      # write to output text
      # 
      return {}
    end
    
    def truth(question, answer)
      # process item.xml as a truthy question
      return {}
    end

    def checkbox(question, answer)
      return {}
    end

    def radio(question, answer)
      return {}
    end
  end
  
  class CourseProcessor
    include SmToAnki::ItemProcessor
    attr_reader :process_dir, :course_doc, :course_info
    # Read the course.xml file
    # Your code goes here...
    def initialize(psw)
      @process_dir = psw
      @course_info = Hash.new
    end

    # read course.xml, retrieve an courses' information
    # Return an array of nested courses
    #
    #     course.xml will be converted to:
    #      {
    #        "title"=>"Fake Course", 
    #        "Category1"=>["00002", "00003"], 
    #        "Category2"=>{
    #          "sub-category1"=>["00006"], 
    #          "sub-category2"=>{
    #            "category-level-3"=>["00008"]
    #          }
    #        }
    #      }
    #
    def fetch_course_info
      File.open("#{@process_dir}/course.xml") do |course|
        @course_doc = Nokogiri.XML(course)
      end

      return unless @course_doc

      @course_info['title'] = @course_doc.at('title').text()
      @course_info.merge!(fetch_node(@course_doc.at('course')))
    end

    def build_anki_dir
      # build subdirectory according from fetched course information
    end

    def detect_exercise_type(item_url)
      # call the processing function accordingly
      # Store different types in different text files
      item = Nokogiri.XML(File.open(item_url))
      answer = item.at_css('item > answer').inner_html if item.at_css('item answer')
      question = item.at_css('item > question').inner_html if item.at_css('item question')
      return nil unless question
      case question
        when /checkbox/ then checkbox(question, answer)
        when /spellpad/ then cloze(question, answer)
        when /radio/ then radio(question, answer)
        when /true-false/ then truth(question, answer)
        else simple_qa(question, answer)
      end
    end

    def post_process
      # move processed itemxxxx.xml to processed_items
    end

    private
    def fetch_node(node)
      # Depends whether its children contains exercise nodes
      case node.at_css('> element')[:type]
      when 'pres'
        nested_pres = Hash.new
        node.css('> element').each do |pres|
          nested_pres.merge!(fetch_node(pres))
        end
        return node.node_name == 'course' ? nested_pres : { node[:name] => nested_pres }

      # fetch the exercise ids within this pres node
      when 'exercise'
        exercise_ids = []
        node.css('> element').each do |exercise|
          exercise_ids.push('%05d' % exercise[:id].to_i)
        end
        return { node[:name] => exercise_ids }
      end
    end

  end



  module ProcessorHelper
    def image_uri
      # translate image uri
      # prepend an namespace to current url
    end

    def decode_unicode
      # to decode utf-8 such as &245;
    end
  end


end
