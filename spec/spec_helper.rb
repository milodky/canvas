require 'canvas'

def random_string(length = 10)
  (1..length).map{('a'..'z').to_a.sample}.join
end

def random_number(max = 1000000)
  rand(max)
end

def valid_person_hash(opt = {})
  {
      :id          => random_number,
      :first_name  => random_string,
      :middle_name => random_string,
      :last_name   => random_string,
      :phones      => [
          {:number => random_string, :type => random_string},
          {:number => random_string, :type => random_string},
      ],
      :locations   => [
          {
              :address => random_string, :city => random_string, :state => random_number, :zip => random_string,
              :country => random_string, :coordinate => {:latitude => random_number, :longitude => random_number}
          }
      ],
      :emails      => [random_string, random_string]
  }.with_indifferent_access.merge(opt)
end