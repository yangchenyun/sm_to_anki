# encoding: utf-8

require 'nokogiri'

module SmToAnki

  class Item
    class ItemError < StandardError; end
    attr_reader :id, :abs_url, :type, :question, :answer, :course

    def initialize(item_id, dir, course)
      @id = item_id
      @course = course
      @abs_url = File.join(dir, "item#{item_id}.xml")
      @node = Nokogiri.XML(File.read(@abs_url))
      @question = @node.at_css('item > question') if @node.at_css('item > question')
      @answer = @node.at_css('item > answer') if @node.at_css('item > answer')
      @type = self.type
      raise ItemError,
        "item should be question - answer pairs" unless self.is_supermemo?
    end

    def is_supermemo?
       @node.collect_namespaces['xmlns'] == "http://www.supermemo.net/2006/smux"
    end

    def type
      # call the processing function accordingly
      # Store different types in different text files
      case @question.to_html
        when /checkbox/ then 'checkbox'
        when /spellpad/ then 'cloze'
        when /radio/ then 'radio'
        when /true-false/ then 'truth'
        else 'simple_qa'
      end
    end

    def process
      image_uri()
      case self.type
        when 'simple_qa'
          id_field = "#{@course}_#{@id}"
          question_field = @question
          answer_field = @answer
          return [id_field, question_field, answer_field].join('|')
        when 'radio'

        when 'checkbox'

        when 'cloze'

        when 'truth'

        else
          raise ItemError,
            "item couldn't be processed as the type is unknow"
      end
    end

    private

    def image_uri
      # translate resource to <img> tags
      # prepend an namespace to current url
      @question.css('gfx').each do |img_node|
        print @id
        file_name = img_node['item-id'] || @id
        file_label = img_node['file']
        img_node.replace("<img src='#{@course}_#{file_name}#{file_label}'/>")
      end
    end

    def decode_unicode
      # to decode utf-8 such as &245;
    end
  end
end
