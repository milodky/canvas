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
  location:    Array[Location]
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
2.1.2 :001 > Canvas.initialize!('person.yml', __FILE__))
2.1.2 :002 > person = Canvas::Person.new :first_name => 'john', :last_name => 'smith', :phones => [{:number => '123'}]
 => #<Canvas::Person:0x007feba3a2ca10 @id=nil, @first_name="john", @middle_name=nil, @last_name="smith", @phones=[#<Canvas::Person::Phone:0x007feba21ffa50 @number="123", @type=nil>], @emails=[], @location=[]>
2.1.2 :003 > person.phones
 => [#<Canvas::Person::Phone:0x007feba21ffa50 @number="123", @type=nil>]
2.1.2 :004 > person.first_name
 => "john"

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
