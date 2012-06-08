require "sm_to_anki/version"
require "sm_to_anki/item_process"
require 'sm_to_anki/item'
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
      @process_dir = File.expand_path(psw)
      @course_info = Hash.new
      @processed_items = File.read("#{@process_dir}/processed_items.txt").chomp!.split(',')
      self.fetch_course_info()
    end

    def fetch_course_info
      @course_doc = Nokogiri.XML(File.read("#{@process_dir}/course.xml"))
      if @course_doc
        @course_info['title'] = @course_doc.at('title').
                                  text.downcase.sub(/\s/, '_')
        @course_info.merge!({"content" => fetch_node(@course_doc.at('course'))})
      end
    end

    def process_course(node, parent_dir)
      # mkdir&cd {course_title}_anki
      #
      # travel through the course_info['content'] branches(keys)
      # if the current node is an Hash
      #   build a directory use the name and cd into the directory
      #   travel the inner nodes
      # if the current node is an Array
      #   process the elements of the Array
      #   return
      #
      Dir.chdir("#{parent_dir}")
      if node.class == Hash && (node.has_key? 'content')
        # the root node
        anki_dir = "#{@course_info['title']}_anki"
        Dir.mkdir(anki_dir) unless File.directory?(anki_dir)
        process_course(node['content'], File.join(parent_dir, anki_dir))
      else
        node.each do |key, value|
          Dir.chdir("#{parent_dir}")
          if value.nil?
            # The enumerator is an Array
            process_item(key, @process_dir)
          else
            # The enumerator is an Hash
            sub_dir = key
            Dir.mkdir(sub_dir) unless File.directory?(sub_dir)
            process_course(value, File.join(parent_dir, sub_dir))
          end
        end
      end
    end

    # write to the processed_items
    # File.read("#{@process_dir}/processed_items.txt", "w") do |f|
      # f.write(@processed_item.join(','))
    # end

    def process_item(item_id, dir)
        return nil if processed?(item_id)
        item = SmToAnki::Item.new(item_id, dir)
        item.type
        @processed_items.push item_id
    end


    private

    def processed?(item_id)
      @processed_items.include? item_id
    end

    def post_process(item_id)
      # move processed itemxxxx.xml to processed_items
    end

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
