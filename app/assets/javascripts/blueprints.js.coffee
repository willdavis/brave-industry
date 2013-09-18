$ ->
	if $('#blueprints-show').length != 0
		##Show
		total_production_cost = 0
		item_sell_price = 0
		units_produced = $('.item-units-produced').text()
		product_id = $('.item-sell-price').attr("id")
		evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=10000002&typeid=#{product_id}"
		evecentral_market_history = "http://api.eve-central.com/api/history/for/type/#{product_id}/region/10000002/bid/0"
		
		market_history_data = []
		
		$('.raw-material').each(
      (index) ->
        id_attr = $($('.raw-material').get(index)).attr("id")
        id = id_attr.match(/\d+/)
        evecentral_url += "&typeid=#{id}"
    )
    
    $('.extra-material').each(
      (index) ->
        id_attr = $($('.extra-material').get(index)).attr("id")
        id = id_attr.match(/\d+/)
        evecentral_url += "&typeid=#{id}"
    )
    
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
		    			$("#raw-#{id}").children('.raw-material-unit-price').text(min_sell)
		    			$("#extra-#{id}").children('.extra-material-unit-price').text(min_sell)
		    			
		    			raw_quantity = $("#raw-#{id}").children('.raw-material-quantity').text()
		    			extra_quantity = $("#extra-#{id}").children('.extra-material-quantity').text()
		    			
		    			total_price_for_raw_material = min_sell * raw_quantity
		    			total_price_for_extra_material = min_sell * extra_quantity
		    			
		    			total_production_cost += total_price_for_raw_material
		    			total_production_cost += total_price_for_extra_material
		    			
		    			$("#raw-#{id}").children('.raw-material-total-price').text(total_price_for_raw_material)
		    			$("#extra-#{id}").children('.extra-material-total-price').text(total_price_for_extra_material)
      	)
      	
      	profit_margin = (item_sell_price * units_produced) - total_production_cost
      	
      	$('.item-total-cost').text(total_production_cost)
      	$('.item-profit-margin').text(profit_margin)
      	
      	if profit_margin >= 0
      		$('.item-profit-margin').css("color", "green")
      	else
      		$('.item-profit-margin').css("color", "red")
    )
    
    #lookup market history
    $.getJSON(
      evecentral_market_history
      (data) ->
      	temp = []
      	for obj in data["values"]
      		console.log obj
      		market_history_data.push(obj["avg"]) if obj["avg"] != 0
      	
      	$.jqplot(
      		'chartdiv'
      		[market_history_data]
      		title:"Average Sell Prices"
      	)
    )
