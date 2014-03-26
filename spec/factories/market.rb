# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :market do
    location "region"
    region_id 10000002  #The Forge
    system_id 30000142 #Jita
    type_id 622  #stabber
  end
end
