require 'spec_helper'

describe Blueprint do
	before(:all) do
		#Uncomment to test performance improvements from instance variables
		#Make sure to comment out the @blueprint variable in the :before block
		@blueprint = FactoryGirl.create(:blueprint)
	end

  before(:each) do
    #@blueprint = FactoryGirl.create(:blueprint)
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
  	end
  	
  	it "contain a modifier for Production Efficiency"
  end
  
  context "waste" do
  	it "has a base value" do
  		@blueprint.waste["base"].should_not be_nil
  		@blueprint.waste["base"].should be_a(Float)
  		@blueprint.waste["base"].should eq(0.1)
  	end
  	
  	it "has a current value" do
  		@blueprint.waste["current"].should_not be_nil
  		@blueprint.waste["current"].should be_a(Float)
  		@blueprint.waste["current"].should eq(0.1)
  		
  		#Current waste is modified by material efficiency
  		@blueprint.material_efficiency = -4
  		@blueprint.waste["current"].should eq(0.5)
  		
  		@blueprint.material_efficiency = 4
  		@blueprint.waste["current"].should eq(0.02)
  	end
  end
  
  context "details" do
  	it "has a name" do
  		@blueprint.name.should_not be_nil
  		@blueprint.name.should be_a(String)
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
  		
  		it "do not have a blueprint id" do
  			@blueprint.raw_materials.each{ |item| item["material"]["blueprint_id"].should be_nil }
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
  		
  		it "have a base quantity" do
  			@blueprint.raw_materials.first["quantity"].should be_a(Integer)
  		end
  		
  		it "have a total quantity" do
  			item = @blueprint.raw_materials.first
  			total = item["quantity"] + item["wasted_quantity"] - item["recycled_quantity"]
  			item["total_quantity"].should be_a(Integer)
  			item["total_quantity"].should eq total
  		end
  		
  		it "have a wasted quantity" do
  			item = @blueprint.raw_materials.first
  			item["wasted_quantity"].should be_a(Integer)
  			item["wasted_quantity"].should eq (item["quantity"] * @blueprint.waste["current"]).round
  		end
  		
  		it "have a recycled quantity" do
  			@blueprint.raw_materials.first["recycled_quantity"].should be_a(Integer)
  		end
  		
  		it "does not include components"
  	end
  	
  	context "components" do
  		it "are optional" do
				@blueprint.components.should be_a(Array)
				@blueprint.components.each{ |item| item.should be_a(Hash) } if @blueprint.has_components?
				@blueprint.components.should be_empty if !@blueprint.has_components?
  		end
  		
  		it "have a blueprint id" do
  			@blueprint.components.each{ |item| item["material"]["blueprint_id"].should_not be_nil }
  			@blueprint.components.each{ |item| item["material"]["blueprint_id"].should be_a(Integer) }
  		end
  		
  		it "have an id" do
  			@blueprint.components.each{ |item| item["material"]["id"].should_not be_nil }
  			@blueprint.components.each{ |item| item["material"]["id"].should be_a(Integer) }
  		end
  		
  		it "have a name" do
  			@blueprint.components.each{ |item| item["material"]["name"].should be_a(String) }
  		end
  		
  		it "have a quantity" do
  			@blueprint.components.each{ |item| item["quantity"].should be_a(Integer) }
  		end
  		
  		it "have a wasted quantity" do
  			@blueprint.components.each{ |item| item["wasted_quantity"].should be_a(Integer) }
  			@blueprint.components.each{ |item| item["wasted_quantity"].should eq 0 }
  		end
  		
  		it "have a consumed percentage" do
  			@blueprint.components.each{ |item| item["damage_per_job"].should be_a(Float) }
  		end
  		
  		it "have a small image" do
  			@blueprint.components.each{ |item| item["images"]["small"].should be_a(String) }
  		end
  		
  		it "have a thumbnail image" do
  			@blueprint.components.each{ |item| item["images"]["thumb"].should be_a(String) }
  		end
  	end
  end
  
  context "invention" do
  	it "is hard!"
  	it "returns list of required datacores" do
  		if !@blueprint.invention["datacores"].empty?
				@blueprint.invention["datacores"].should be_a(Array)
				@blueprint.invention["datacores"].first.should be_a(Hash)
			end
  	end
  	
  	it "returns the required data interface" do
  		if @blueprint.invention["data_interface"]
  			@blueprint.invention["data_interface"].should be_a(Hash)
  		end
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
