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
The data is mainly stored in three places, `course.xml` stores information about the whole course, `itemxxxxx.xml` stores dat for each item, and the `media` folder stores files used in the `itemxxxxx.xml`.

`course.xml` which stores the course category and hierarchy as following: 
    <course xmlns="http://www.supermemo.net/2006/smux">
      <guid>b258b4b0-aff6-416a-b36f-d82dc16a0a3c</guid>
      <title>Fake Course</title>
      
      <element id="1" type="pres" name="Category1">
        <element id="2" type="exercise" name="1" />
        <element id="3" type="exercise" name="What's the relationship between..." />
      </element>

      <element id="4" type="pres" name="Category2">
        <element id="5" type="pres" name="sub-category1">
          <element id="6" type="exercise" name="1" />
        </element>

        <element id="7" type="pres" name="sub-category2">
          <element id="9" type="pres" name="category-level-3">
            <element id="8" type="exercise" name="1" />
          </element>
        </element>
      </element>

    </course>


`itemxxxxx.xml` stores the item question and answer. In Supermemo UX it contains four types:
  * Simple Question and Answer
  * True or False
  * Multiple choices
  * Pick the right choice
  * Cloze

Each item will be converted to the anki format [import files](http://ankisrs.net/docs/FileImport.html)

`media` file contains the media files refered in items.

### The output skeleton is

    {course_title}_anki/
      - sub_category1
        - simple_qa.txt
        - cloze.txt
        - multi_choice.txt
        - truth.txt
      - sub_category2
    {course_title}_media/
    {course_title}_processed_item.txt


### Course information processing
Firstly, I will retrive the course information from the `course.xml` and convert it to the following format:

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

The destination directory hierachy will be generated from this hash.


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

#### Escape newline character
As Anki process the import file line by line, new line character should be converted to HTML `<br>` tags.

### Media Files Processing
Files within original media folder are prepended with a namespace
<!-- <gfx item-id="117" file="e" scale-base="720" /> -->
`xxxxxa.jpg` will be converted to `course_title_xxxxx1.jpg`
*course_title* is transformed from the `<title>` field of the `course.xml` file and is converted to underscore.
