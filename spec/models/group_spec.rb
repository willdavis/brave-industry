require 'spec_helper'

describe Group do
	before(:all) do
		@group = FactoryGirl.create(:group)
	end
	
	context "initialize params" do
  	it "contain an id" do
  	  expect(@group.id).to_not be_nil
  	  expect(@group.id).to be_a(Integer)
  	end
  	
  	it "contains a name" do
  	  expect(@group.name).to_not be_nil
  	  expect(@group.name).to be_a(String)
  	end
  end
  
  context "select all members" do
    it "returns an Array of Blueprints" do
      expect(@group.members).to_not be_nil
      expect(@group.members).to be_a(Array)
      expect(@group.members).to_not be_empty
    end
  end
  
  context "members" do
    it "have the groups id" do
      expect(@group.members.first).to_not be_nil
      expect(@group.members.first).to_not be_a(Blueprint)
      expect(@group.members.first.group["id"]).to be == @group.id
    end
  end
end
