require "sm_to_anki/version"
require "sm_to_anki/item_process"

require 'nokogiri'


module SmToAnki
  class CourseProcessor
    include SmToAnki::ItemProcessor

    # process_dir contains current working directory
    # course_doc is the hold an Nokogiri instance of course.xml
    # course_info holds an Ruby hash containing the course information
    # processed_items holds an array of ids of items processed before
    attr_reader :process_dir, :course_doc, :course_info, :processed_items
    
    def initialize(psw)
      @process_dir = psw
      @course_info = Hash.new
      @processed_items = File.open("#{@process_dir}/processed_items.txt").read.chomp!.split(',')
    end

    def fetch_course_info
      @course_doc = Nokogiri.XML(File.open("#{@process_dir}/course.xml"))
      if @course_doc
        @course_info['title'] = @course_doc.at('title').
                                  text.downcase.sub(/\s/, '_')

        @course_info.merge!(fetch_node(@course_doc.at('course')))
      end
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
end
