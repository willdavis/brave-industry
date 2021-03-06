$ ->
	if $('.blueprints-show').length != 0
		lookup_production_costs()
		we_must_go_deeper()
		
		if $('#invention').length != 0
		  lookup_invention_costs()

	
#Materials may be components with their own blueprints.
#Look up component blueprints
we_must_go_deeper = () ->
	$(".view-blueprint").each(
		() ->
			panel = $(this)
			id = panel.attr("id").match(/\d+/)
			blueprint_url = "http://evedata.herokuapp.com/blueprints?product_id=#{id}"
			
			$.getJSON(
				blueprint_url
				(data) ->
					panel.append("<a href='/blueprints/#{data[0]['id']}'>View #{data[0]['name']}</a>")
			)
	)

lookup_invention_costs = () ->
	total_production_cost = 0
	region_id = $('#region_id').val()
	system_id = $('#system_id').text()
	
	if $("#location_system").is(':checked') and system_id != ""
	  evecentral_url = "http://api.eve-central.com/api/marketstat?usesystem=#{system_id}"
	else
	  evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=#{region_id}"
	
	$('#invention-materials-datacores').find(".invention-material").each(
    () ->
    	if $(this).attr("id")
		    id = $(this).attr("id").match(/\d+/)
		    evecentral_url += "&typeid=#{id}"
  )
  
  $('#invention-materials-interface').find(".invention-material").each(
    () ->
    	if $(this).attr("id")
		    id = $(this).attr("id").match(/\d+/)
		    evecentral_url += "&typeid=#{id}"
  )
  
  console.log evecentral_url
  
  #lookup current market data
  $.get(
    evecentral_url
    (data) ->
    	$(data).find("type").each(
    		() ->
    			console.log this
    			id = $(this).attr("id")
    			min_sell = $(this).find("sell").find("min").text()
    			
    			$("##{id}-unit-price").text(min_sell)
    				
    			if $("##{id}-damage").length
    				damage = $("##{id}-damage").text()
    			else
    				damage = 1
    			
    			quantity = $("##{id}-quantity").text()
    			total_price = min_sell * quantity * damage
    			$("##{id}-total-price").text(total_price.toFixed(2))
    			
    			#check if the price should be ignored
    			if !$("##{id}").hasClass("exclude-price")
    				total_production_cost += total_price
    	)
    	
    	#Temporary fix for Invention max run count
    	#will be dynamic eventually
    	total_production_cost = total_production_cost / 5
    	
    	console.log "Calculating invention costs..."
    	console.log "Reticulating splines..."
    	
    	$('.item-invention-cost').text(total_production_cost.toFixed(2))
    	if $('#invented').attr("checked") == "checked"
    		console.log "Applying invention costs..."
    		price = $('.item-profit-margin').text()
    		price -= total_production_cost
    		$('.item-profit-margin').text(price.toFixed(2))
    		update_profit_css(price)
  )

lookup_production_costs = () ->
	total_production_cost = 0
	item_sell_price = 0
	units_produced = $('.item-units-produced').text()
	product_id = $('.item-sell-price').attr("id")
	region_id = $('#region_id').val()
	system_id = $('#system_id').text()
	
	if $("#location_system").is(':checked') and system_id != ""
	  evecentral_url = "http://api.eve-central.com/api/marketstat?usesystem=#{system_id}&typeid=#{product_id}"
	else
	  evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=#{region_id}&typeid=#{product_id}"
	
	console.log "Looking up material IDs..."
	
	$('#raw-materials').find(".raw-material").each(
    () ->
    	if $(this).attr("id")
		    id = $(this).attr("id").match(/\d+/)
		    evecentral_url += "&typeid=#{id}"
  )
  
  $('#component-materials').find(".component").each(
    () ->
    	if $(this).attr("id")
		    id = $(this).attr("id").match(/\d+/)
		    new_url = "&typeid=#{id}"
		    evecentral_url += new_url if !evecentral_url.match(new_url)
		    
		    $("##{id}-build-toggle").bind(
		    	"click"
		    	() ->
		    		if $("##{id}").hasClass("build-component")
		    			$("##{id}").removeClass("build-component")
		    			update_hidden_component_list("remove",id)
		    			$(this).text("+")
		    		else
		    			$("##{id}").addClass("build-component")
		    			update_hidden_component_list("add",id)
		    			$(this).text("-")
		    )
  )
  
  console.log evecentral_url
  
  #lookup current market data
  $.get(
    evecentral_url
    (data) ->
    	$(data).find("type").each(
    		() ->
    			console.log this
    			id = $(this).attr("id")
    			min_sell = $(this).find("sell").find("min").text()
    			
    			if id == product_id
    				item_sell_price = min_sell
    				$(".item-sell-price").text(min_sell)
    			else
	    			$("##{id}-unit-price").text(min_sell)
	    			
	    			if $("##{id}-damage").length
	    				damage = $("##{id}-damage").text()
	    			else
	    				damage = 1
	    			
	    			quantity = $("##{id}-quantity").text()
	    			total_price = min_sell * quantity * damage
	    			total_production_cost += total_price
	    			$("##{id}-total-price").text(total_price.toFixed(2))
    	)
    	
    	console.log "Calculating production costs..."
    	console.log "Reticulating splines..."
    	
    	profit_margin = (item_sell_price * units_produced) - total_production_cost
    	
    	$('.item-total-cost').text(total_production_cost.toFixed(2))
    	$('.item-profit-margin').text(profit_margin.toFixed(2))
    	
    	update_profit_css(profit_margin)
  )

update_profit_css = (profit) ->
	if profit >= 0
		$('.item-profit-margin').css("color", "green")
	else
		$('.item-profit-margin').css("color", "red")
