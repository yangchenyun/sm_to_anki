require 'nokogiri'

module SmToAnki

  class Item
    class ItemError < StandardError; end
    attr_reader :id, :abs_url, :type, :question, :answer

    def initialize(item_id, dir)
      @id = item_id
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
      return "true"
    end
  end
end
