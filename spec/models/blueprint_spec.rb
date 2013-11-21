require 'spec_helper'

describe Blueprint do
  before(:each) do
    @blueprint = FactoryGirl.create(:blueprint)
  end
  
  context "attributes" do
  	it "has an id" do
  		@blueprint.id.should_not be_nil
  	end
  	
  	it "has an invented flag" do
  		@blueprint.invented.should_not be_nil
  	end
  end
end
