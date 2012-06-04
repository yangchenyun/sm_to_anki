module SmToAnki
  module ItemProcessor
    private
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

  module ProcessorHelper
    def image_uri
      # translate resource to <img> tags
      # prepend an namespace to current url
    end

    def decode_unicode
      # to decode utf-8 such as &245;
    end
  end
end
