# SmToAnki

This gem help to convert Supermemo UX course into anki format txt files.

## Installation

Add this line to your application's Gemfile:

    gem 'sm_to_anki'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sm_to_anki

## How it works

### The original directory is
    memo_course
      - course.xml
      - itemxxxxx.xml
      - media
        -- xxxxx.jpg

`course.xml` which stores the course category and hierarchy. 

     {
       "title"=>"fake_course", 
       "content" => {
         "Category1"=>["00002", "00003"],  # simple_question
         "Category2"=>{
           "sub-category1"=>["00006"], # truth
           "sub-category2"=>{
             "category-level-3"=>["00008"] #cloze
           }
         }
       }
     }

`itemxxxxx.xml` stores the item question and answer. In Supermemo UX it contains four types:
  * Simple Question and Answer
  * True or False
  * Multiple choices
  * Pick the right choice
  * Cloze
`media` file contains the media files refered by

### The output skeleton is

    {course_title}_anki/
      - sub_category1
        - simple_qa.txt
        - cloze.txt
        - multi_choice.txt
        - truth.txt
      - sub_category2
    {course_title}.media/
    {course_title}_processed_item.txt

The hierachy between course items are preserved with file system hierarchy
Items are stored according to their types and are within the category they belong to

### Media Files Processing
Files within original media folder are prepended with a namespace
<!-- <gfx item-id="117" file="e" scale-base="720" /> -->
`xxxxxa.jpg` will be converted to `course_title_xxxxx1.jpg`
*course_title* is transformed from the `<title>` field of the `course.xml` file and is converted to underscore.

### Item Processing
The information of the item is processed as html string.
The first field of every item should be `{course_title}_id` to make this entry unique across anki
Processed items will be stored within the `processed_item.txt` separate with `,`

#### Cloze Question
**Detection:** The question contains a <spellpad> tag.
**Result:**:
The correct answer will be converted to `c1:answer` string within the question.
Id|Question|Explanation

#### Truth Question
**Detection:** The question contains a <true-false> tag.
**Result:**:
The Options will be retrived from the tag, and build a string and append to the trail of the question. true/false
The right answer will be put on an independent field
Id|Question|Answer|Explanation

#### Checkbox Question
**Detection:** The question contains a <checkbox> or <radio> tag.
**Result:**:
The Options will be retrived from the tag, and build a string and append to the trail of the question. true/false
The right answer will be put on an independent field
Id|Question|Answer|Explanation

#### Simple Question/Answer
**Detection:** Both the quesiton and string doesn't contain special tags.
**Result:**:
Id|Question|Answer

#### Decode utf-8 string
UTF-8 String will be decoded to utf-8 character.

#### Preserve HTML tags
HTML tags within the Question string will be preserved

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
