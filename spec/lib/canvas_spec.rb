require 'spec_helper'
Canvas.initialize!(File.expand_path('../yamls/person.yml', __FILE__))

describe 'initialization of a empty hash' do
  before(:all) do
    @person      = Canvas::Person.new {}
  end

  it 'should have a nil id' do
    expect(@person.id).to be_nil
  end

  it 'should have a nil first_name' do
    expect(@person.first_name).to be_nil
  end

  it 'should have a nil middle_name' do
    expect(@person.middle_name).to be_nil
  end

  it 'should have a nil last_name' do
    expect(@person.last_name).to be_nil
  end

  it 'should have an empty array of phones' do
    expect(@person.phones).to be_kind_of(Array)
    expect(@person.phones.size).to eql(0)

  end

  it 'should have an empty array of locations' do
    expect(@person.locations).to be_kind_of(Array)
    expect(@person.locations.size).to eql(0)
  end

  it 'should have an empty array of emails' do
    expect(@person.emails).to be_kind_of(Array)
    expect(@person.emails.size).to eql(0)
  end
end

describe 'initialization of a concrete hash' do
  before(:all) do
    @person_hash = valid_person_hash
    @person      = Canvas::Person.new @person_hash
  end

  context 'when instantiating' do
    it 'should have an id' do
      expect(@person.id).to eql(@person_hash[:id])
    end

    it 'should have a first_name' do
      expect(@person.first_name).to eql(@person_hash[:first_name])
    end

    it 'should have a middle_name' do
      expect(@person.middle_name).to eql(@person_hash[:middle_name])
    end

    it 'should have a last_name' do
      expect(@person.last_name).to eql(@person_hash[:last_name])
    end

    it 'should have an array of phones' do
      expect(@person.phones).to be_kind_of(Array)
      expect(@person.phones.size).to eql(2)
      @person.phones.each_with_index do |phone, i|
        expect(phone).to be_kind_of(Canvas::Person::Phone)
        expect(phone.number).to eql(@person_hash[:phones][i][:number])
        expect(phone.type).to eql(@person_hash[:phones][i][:type])
      end

    end

    it 'should have an array of locations' do
      expect(@person.locations).to be_kind_of(Array)
      expect(@person.locations.size).to eql(1)
      @person.locations.each_with_index do |location, i|
        expect(location).to be_kind_of(Canvas::Person::Location)
        expect(location.address).to eql(@person_hash[:locations][i][:address])
        expect(location.city).to eql(@person_hash[:locations][i][:city])
        expect(location.state).to eql(@person_hash[:locations][i][:state])
        expect(location.zip).to eql(@person_hash[:locations][i][:zip])
        expect(location.coordinate).to be_kind_of(Canvas::Person::Coordinate)
        expect(location.coordinate.longitude).to eql(@person_hash[:locations][i][:coordinate][:longitude])
        expect(location.coordinate.latitude).to eql(@person_hash[:locations][i][:coordinate][:latitude])
      end
    end

    it 'should have an array of emails' do
      expect(@person.emails).to be_kind_of(Array)
      expect(@person.emails.size).to eql(2)
      @person.emails.each_with_index do |email, i|
        expect(email).to eql(@person_hash[:emails][i])
      end
    end
  end

  context 'when getting an attribute using []' do
    it 'should have an id' do
      expect(@person[:id]).to eql(@person_hash[:id])
    end

    it 'should have a first_name' do
      expect(@person[:first_name]).to eql(@person_hash[:first_name])
    end

    it 'should have a middle_name' do
      expect(@person[:middle_name]).to eql(@person_hash[:middle_name])
    end

    it 'should have a last_name' do
      expect(@person[:last_name]).to eql(@person_hash[:last_name])
    end

    it 'should have an array of phones' do
      expect(@person[:phones]).to be_kind_of(Array)
      expect(@person[:phones].size).to eql(2)
      @person[:phones].each_with_index do |phone, i|
        expect(phone).to be_kind_of(Canvas::Person::Phone)
        expect(phone.number).to eql(@person_hash[:phones][i][:number])
        expect(phone.type).to eql(@person_hash[:phones][i][:type])
      end

    end

    it 'should have an array of locations' do
      expect(@person[:locations]).to be_kind_of(Array)
      expect(@person[:locations].size).to eql(1)
      @person[:locations].each_with_index do |location, i|
        expect(location).to be_kind_of(Canvas::Person::Location)
        expect(location.address).to eql(@person_hash[:locations][i][:address])
        expect(location.city).to eql(@person_hash[:locations][i][:city])
        expect(location.state).to eql(@person_hash[:locations][i][:state])
        expect(location.zip).to eql(@person_hash[:locations][i][:zip])
        expect(location.coordinate).to be_kind_of(Canvas::Person::Coordinate)
        expect(location.coordinate.longitude).to eql(@person_hash[:locations][i][:coordinate][:longitude])
        expect(location.coordinate.latitude).to eql(@person_hash[:locations][i][:coordinate][:latitude])
      end
    end

    it 'should have an array of emails' do
      expect(@person[:emails]).to be_kind_of(Array)
      expect(@person[:emails].size).to eql(2)
      @person[:emails].each_with_index do |email, i|
        expect(email).to eql(@person_hash[:emails][i])
      end
    end
  end

  context 'when testing setting an attribute' do
    it 'should have an id' do
      id = random_number
      @person.id = id
      expect(@person.id).to eql(id)
    end

    it 'should have a first_name' do
      name = random_string
      @person.first_name = name
      expect(@person.first_name).to eql(name)
    end

    it 'should have a middle_name' do
      name = random_string
      @person.middle_name = name
      expect(@person.middle_name).to eql(name)
    end

    it 'should have a last_name' do
      name = random_string
      @person.last_name = name
      expect(@person.last_name).to eql(name)
    end

    it 'should have an array of phones' do
      phones = [{:number => random_string, :type => random_string}, {:number => random_string, :type => random_string}]
      @person.phones = phones
      expect(@person.phones).to be_kind_of(Array)
      expect(@person.phones.size).to eql(2)
      expect(@person.phones).to eql(phones)

    end

    it 'should have an array of locations' do
      locations = [{:address => random_string, :city => random_string, :state => random_number, :zip => random_string,
                   :coordinate => {:latitude => random_number, :longitude => random_number}}]
      @person.locations = locations
      expect(@person.locations.size).to eql(1)
      expect(@person.locations).to be_kind_of(Array)
      expect(@person.locations).to eql(locations)
    end

    it 'should have an array of emails' do
      emails = [random_string, random_string]
      @person.emails = emails
      expect(@person.emails).to be_kind_of(Array)
      expect(@person.emails.size).to eql(2)
      expect(@person.emails).to eql(emails)
    end
  end

  context 'when testing setting an attribute using []=' do
    it 'should have an id' do
      id = random_number
      @person[:id] = id
      expect(@person[:id]).to eql(id)
    end

    it 'should have a first_name' do
      name = random_string
      @person[:first_name] = name
      expect(@person[:first_name]).to eql(name)
    end

    it 'should have a middle_name' do
      name = random_string
      @person[:middle_name] = name
      expect(@person[:middle_name]).to eql(name)
    end

    it 'should have a last_name' do
      name = random_string
      @person[:last_name] = name
      expect(@person[:last_name]).to eql(name)
    end

    it 'should have an array of phones' do
      phones = [{:number => random_string, :type => random_string}, {:number => random_string, :type => random_string}]
      @person[:phones] = phones
      expect(@person[:phones]).to be_kind_of(Array)
      expect(@person[:phones].size).to eql(2)
      expect(@person[:phones]).to eql(phones)

    end

    it 'should have an array of locations' do
      locations = [{:address => random_string, :city => random_string, :state => random_number, :zip => random_string,
                    :coordinate => {:latitude => random_number, :longitude => random_number}}]
      @person[:locations] = locations
      expect(@person[:locations].size).to eql(1)
      expect(@person[:locations]).to be_kind_of(Array)
      expect(@person[:locations]).to eql(locations)
    end

    it 'should have an array of emails' do
      emails = [random_string, random_string]
      @person[:emails] = emails
      expect(@person[:emails]).to be_kind_of(Array)
      expect(@person[:emails].size).to eql(2)
      expect(@person[:emails]).to eql(emails)
    end
  end
end

describe 'wrong type assignment' do
  it 'should raise an ArgumentError' do
    expect{Canvas::Person.new(:id => '123')}.to raise_error(ArgumentError)
  end
end