require 'spec_helper'

describe Region do
  before(:all) do
	  #Uncomment to test performance improvements from instance variables
	  #Make sure to comment out the :before block
	  @region = FactoryGirl.create(:region)
  end

=begin
  before(:each) do
    @region = FactoryGirl.create(:region)
  end
=end

  context "initialize params" do
	  it "has an id" do
		  @region.id.should_not be_nil
		  @region.id.should be_a(Integer)
	  end
	end
end

