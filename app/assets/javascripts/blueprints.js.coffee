$ ->
	if $('.blueprints-show').length != 0
		setup_ME_slider_bar()
		
		lookup_production_costs()
		lookup_invention_costs()
		
		we_must_go_deeper()
	
	$('.blueprint-toggle').bind(
		"click"
		() ->
			panel = $(this).parent().parent()
			group_id = panel.attr("id")
			group_blueprints = panel.children("##{group_id}-collapse").children(".panel-body")
			
			console.log "clicked ID:#{group_id}"
			
			if group_blueprints.children(".blueprint").length != 0
				console.log "Blueprints already loaded from evedata.  Displaying cached content"
			else
				console.log "No blueprints present.  Loading from evedata..."
				evedata_url = "http://evedata.herokuapp.com/blueprints?group_id=#{group_id}&limit=100"
				$.getJSON(
					evedata_url
					(data) ->
						console.log "recieved data from evedata...\ncreating HTML..."
						for blueprint in data
							panel.children("##{group_id}-collapse").children(".panel-body").append("<table class='blueprint'><tr><td width='32' height='32' class='blueprint-image'><img src='#{blueprint['images']['small']}' /></td><td class='blueprint-name'><a href='#{blueprint['id']}'>#{blueprint['name']}</a></td></table>")
				)
	)
	
	$('.nav-history-title').bind(
		"click"
		() ->
			$('#min_sell_history_chart').empty()
			$('#trade_volume_history_chart').empty()
			
			#lookup market history
			market_history_data = []
			item_trade_volume = []
			
			product_id = $('.item-sell-price').attr("id")
			evecentral_market_history = "http://api.eve-central.com/api/history/for/type/#{product_id}/region/10000002/bid/0"
			
			$.getJSON(
				evecentral_market_history
				(data) ->
					temp = []
					for obj in data["values"]
						time = new Date(obj["at"])
						market_history_data.push([time, obj["min"]]) if obj["min"] != 0
						item_trade_volume.push([time, obj["volume"]]) if obj["volume"] != 0
					
					$.jqplot(
						'min_sell_history_chart'
						[market_history_data]
						title:"Minimum Sell Price"
						series:[
							showMarker:false
						]
						cursor:
							show: true
							zoom: true
							showTooltip: false
						highlighter:
							show: true
						axes:
						  xaxis:
						    renderer: $.jqplot.DateAxisRenderer
						    tickOptions:
						      formatString:'%b&nbsp;%#d'
						  yaxis:
						    label:'Isk per Unit'
						    labelRenderer: $.jqplot.CanvasAxisLabelRenderer
					)
					
					$.jqplot(
						'trade_volume_history_chart'
						[item_trade_volume]
						title:"Trade Volume"
						series:[
							showMarker:false
						]
						cursor:
							show: true
							zoom: true
							showTooltip: false
						highlighter:
							show: true
						axes:
						  xaxis:
						    renderer: $.jqplot.DateAxisRenderer
						    tickOptions:
						      formatString:'%b&nbsp;%#d'
						  yaxis:
						    label:'Units Sold'
						    labelRenderer: $.jqplot.CanvasAxisLabelRenderer
					)
			)
	)

#Configure the material effeciency slider bar	
setup_ME_slider_bar = () ->
	me_level = $('#ME').val()
	$('#ME-slider-value').text(me_level)
	$("#ME-slider").slider(
		min: -10
		max: 30
		value: me_level
		slide:
			(event,ui) ->
				$('#ME-slider-value').text(ui.value)
		change:
			(event,ui) ->
				$('#ME').val(ui.value)
	)
	
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
	evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=10000002"
	
	$('#invention-materials').find(".invention-material").each(
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
    			total_production_cost += total_price
    			$("##{id}-total-price").text(total_price.toFixed(2))
    	)
    	
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
	evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=10000002&typeid=#{product_id}"
	
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
