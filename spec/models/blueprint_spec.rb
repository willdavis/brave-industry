require 'spec_helper'

describe Blueprint do
  before(:all) do
    @blueprint = FactoryGirl.create(:blueprint)
  end
  
  context "initialize params" do
  	it "contain an id" do
  		@blueprint.id.should_not be_nil
  		@blueprint.id.should be_a(Integer)
  	end
  	
  	it "contain an invented flag" do
  		@blueprint.invented.should_not be_nil
  		@blueprint.invented.should be_a(Integer)
  	end
  	
  	it "contain a modifier for Material Efficiency" do
  		@blueprint.material_efficiency.should be_a(Integer)
  		@blueprint.material_efficiency = nil
  		@blueprint.material_efficiency.should be_nil
  	end
  	
  	it "contain a modifier for Production Efficiency"
  end
  
  context "details" do
  	it "has a name" do
  		@blueprint.name.should_not be_nil
  		@blueprint.name.should be_a(String)
  	end
  	
  	it "has a waste factor" do
  		@blueprint.base_waste.should_not be_nil
  		@blueprint.base_waste.should be_a(Integer)
  	end
  	
  	it "has a production time" do
  		@blueprint.production_time.should_not be_nil
  		@blueprint.production_time.should be_a(Integer)
  	end
  	
  	it "has a tech level" do
  		@blueprint.tech_level.should_not be_nil
  		@blueprint.tech_level.should be_a(Integer)
  	end
  end
  
  context "group" do
  	it "has an id" do
  		@blueprint.group["id"].should_not be_nil
  		@blueprint.group["id"].should be_a(Integer)
  	end
  	
  	it "has a name" do
  		@blueprint.group["name"].should_not be_nil
  		@blueprint.group["name"].should be_a(String)
  	end
  end
  
  context "images" do
  	it "has a small URL" do
  		@blueprint.images["small"].should_not be_nil
  		@blueprint.images["small"].should be_a(String)
  	end
  	
  	it "has a thumbnail URL" do
  		@blueprint.images["thumb"].should_not be_nil
  		@blueprint.images["thumb"].should be_a(String)
  	end
  end
  
  context "product" do
  	it "has an id" do
  		@blueprint.product["id"].should_not be_nil
  		@blueprint.product["id"].should be_a(Integer)
  	end
  	
  	it "has a batch size" do
  		@blueprint.product["batch_size"].should_not be_nil
  		@blueprint.product["batch_size"].should be_a(Integer)
  	end
  end
  
  context "manufacturing" do
  	context "raw materials" do
  		it "are present" do
  			@blueprint.raw_materials.should_not be_nil
				@blueprint.raw_materials.should be_a(Array)
				@blueprint.raw_materials.first.should be_a(Hash)
  		end
  		
  		it "have a type id" do
  			@blueprint.raw_materials.first["material"]["id"].should be_a(Integer)
  		end
  		
  		it "have a name" do
  			@blueprint.raw_materials.first["material"]["name"].should be_a(String)
  		end
  		
  		it "have a small image" do
  			@blueprint.raw_materials.first["images"]["small"].should be_a(String)
  		end
  		
  		it "have a thumbnail image" do
  			@blueprint.raw_materials.first["images"]["thumb"].should be_a(String)
  		end
  		
  		it "have a quantity" do
  			@blueprint.raw_materials.first["quantity"].should be_a(Integer)
  		end
  		
  		it "are 100% consumed"
  		it "have a wasted quantity"
  		it "does not include components"
  	end
  	
  	context "components" do
  		it "are present" do
  			@blueprint.components.should_not be_nil
				@blueprint.components.should be_a(Array)
				@blueprint.components.first.should be_a(Hash)
  		end
  		
  		it "have an id"
  		it "have a name"
  		it "have a quantity"
  		it "have a wasted quantity"
  		it "have a consumed percentage"
  		
  		it "have a small image"
  		it "have a thumbnail image"
  	end
  end
  
  context "invention" do
  	it "is hard!"
  	it "returns list of required datacores" do
  		@blueprint.invention["datacores"].should_not be_nil
  		@blueprint.invention["datacores"].should be_a(Array)
  		@blueprint.invention["datacores"].first.should be_a(Hash)
  	end
  	
  	it "returns the required data interface" do
  		@blueprint.invention["data_interface"].should_not be_nil
  		@blueprint.invention["data_interface"].should be_a(Hash)
  	end
  	
  	it "returns list of viable data decryptors"
  	it "returns list of viable modules"
  end
  
  context "skills" do
  	it "returns a list of all required skills" do
  		@blueprint.skills.should_not be_nil
  		@blueprint.skills.should be_a(Hash)
  	end
  	
  	it "can be filtered to only return required skills for manufacturing" do
  		@blueprint.skills["manufacturing"].should_not be_nil
  		@blueprint.skills["manufacturing"].should be_a(Array)
  		@blueprint.skills["manufacturing"].first.should be_a(Hash)
  	end
  	it "can be filtered to only return required skills for research"
  	it "can be filtered to only return required skills for invention"
  end
end
