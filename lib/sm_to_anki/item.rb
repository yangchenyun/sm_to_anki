# encoding: utf-8

require 'nokogiri'

module SmToAnki

  class Item
    class ItemError < StandardError; end
    attr_reader :id, :abs_url, :type, :question, :answer

    def initialize(item_id, dir, course)
      @id = item_id
      @course = course
      @abs_url = File.join(dir, "item#{item_id}.xml")
      @node = Nokogiri.XML(File.read(@abs_url))
      @answer = @node.at_css('item > answer').inner_html if @node.at_css('item answer')
      @question = @node.at_css('item > question').inner_html if @node.at_css('item question')
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
      case @question
        when /checkbox/ then 'checkbox'
        when /spellpad/ then 'cloze'
        when /radio/ then 'radio'
        when /true-false/ then 'truth'
        else 'simple_qa'
      end
    end

    def process
      return '1|b|c'
      case self.type
      when 'simple_qa'

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
    end

    def decode_unicode
      # to decode utf-8 such as &245;
    end
  end
end
