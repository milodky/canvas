# Canvas

Similar to Virtus, but more light-weight, using yaml to define a class

## Installation

Add this line to your application's Gemfile:

    gem 'canvas'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install canvas

## Usage

The yaml file will look like:
````
class_name: Person

schema:
  id:          Integer
  first_name:  String
  middle_name: String
  last_name:   String
  phones:      Array[Phone]
  emails:      Array[String]
  locations:   Array[Location]
nested_classes:
  Location:
    address:   String
    city:      String
    state:     Integer
    zip:       String
    country:   String
    latitude:  Integer
    longitude: Integer
  Phone:
    number:    String
    type:      String
````
To initialize the class, simply run:
````
2.1.2 :001 > require 'canvas'
 => true
2.1.2 :002 > Canvas.initialize!('person.yml')
 => Canvas::Person
2.1.2 :003 > person = Canvas::Person.new :first_name => 'john',
                                         :last_name => 'smith',
                                         :phones => [{:number => '123'}],
                                         :locations => [{:city => 'los angeles', :state => 6}],
                                         :emails => ['abc@gmail.com']
 => #<Canvas::Person:0x007fc393ae9940 @id=nil, @first_name="john", @middle_name=nil, @last_name="smith", @phones=[#<Canvas::Person::Phone:0x007fc393ae8608 @number="123", @type=nil>], @emails=["abc@gmail.com"], @locations=[#<Canvas::Person::Location:0x007fc393ae3608 @address=nil, @city="los angeles", @state=6, @zip=nil, @country=nil, @latitude=nil, @longitude=nil>]>
2.1.2 :004 > person.locations[0].city
 => "los angeles"
2.1.2 :005 > person.locations[0].zip
 => nil

````
You can also extend Canvas into one of your modules let's say DataEngine:

````
module DataEngine
  extend Canvas
  initialize! 'Person.yml'
end
````
Then you can do:
````
DataEngine::Person.new ...
````
## Contributing

1. Fork it ( https://github.com/[my-github-username]/canvas/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request for any issues
