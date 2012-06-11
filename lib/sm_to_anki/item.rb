# encoding: utf-8
require 'nokogiri'
require 'htmlentities'

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
      image_uri()
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
      id_field = "#{@course}_#{@id}"
      explanation_field = @answer ? decode_unicode(@answer.inner_html) : ""

      case self.type
      when 'simple_qa'
        question_field = decode_unicode(@question.inner_html)
        return [id_field, question_field, explanation_field].join('|')
      when 'radio'
        options = []
        answer_field = ""
        @question.css('radio option').each do |option|
          answer_field = decode_unicode(option.inner_html) if option[:correct] == "true"
          options.push decode_unicode(option.inner_html)
        end
        question_field = decode_unicode(@question.inner_html).gsub(/<radio(.+)radio>/, options.join('/'))
        return [id_field, question_field, answer_field, explanation_field].join('|')
      when 'checkbox'
        options = []
        answers = []
        @question.css('checkbox option').each do |option|
          answers.push decode_unicode(option.inner_html) if option[:correct] == "true"
          options.push decode_unicode(option.inner_html)
        end
        answer_field = answers.join('/')
        question_field = decode_unicode(@question.inner_html).gsub(/<checkbox(.+)checkbox>/, options.join('/'))
        return [id_field, question_field, answer_field, explanation_field].join('|')

      when 'cloze'
        question_field = decode_unicode(@question.inner_html)
        @question.css('spellpad').length.times do |count|
          question_field.sub!(/<spellpad correct="(.+?)"(.+?)spellpad>/, "{{c#{count+1}::\\1}}")
        end
        return [id_field, question_field, explanation_field].join('|')

      when 'truth'
        options = {}
        options['true'] = @question.at_css('true-false')['true']
        options['false'] = @question.at_css('true-false')['false']
        answer_field = options[@question.at_css('true-false')['correct']]
        question_field = decode_unicode(@question.inner_html).gsub(/<true-false(.+)true-false>/, options.values.join('/'))
        return [id_field, question_field, answer_field, explanation_field].join('|')

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
        file_name = img_node['item-id'] || @id
        file_name = "%05d" % file_name.to_i unless file_name.to_i == 0
        file_label = img_node['file']
        img_node.replace("<img src='#{@course}_#{file_name}#{file_label}.jpg'></img>")
      end
    end

    def decode_unicode(string)
      coder = HTMLEntities.new
      string = coder.decode(string)
      string = coder.decode(string)
      string.gsub!("\\n", '<br></br>')
      string
    end
  end
end
