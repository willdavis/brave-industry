# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :market do
    location "region"
    region_id 10000002
    type_id 622  #stabber
  end
end
