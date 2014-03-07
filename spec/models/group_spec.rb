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
      @group.members.each do |member|
        expect(member).to be_a(Blueprint)
      end
    end
  end
  
  context "members" do
    it "must have the groups id" do
      @group.members.each do |member|
        expect(member.group["id"].to_i).to be == @group.id
      end
    end
  end
end
