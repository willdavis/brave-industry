$ ->
	if $('#blueprints-show').length != 0
		query_evecentral()
	
	$('.nav-history-title').click(
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

query_evecentral = () ->
	total_production_cost = 0
	item_sell_price = 0
	units_produced = $('.item-units-produced').text()
	product_id = $('.item-sell-price').attr("id")
	evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=10000002&typeid=#{product_id}"
	
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
	    			
	    			$("#raw-#{id}").children('.raw-material-total-price').text(total_price_for_raw_material.toFixed(2))
	    			$("#extra-#{id}").children('.extra-material-total-price').text(total_price_for_extra_material.toFixed(2))
    	)
    	
    	profit_margin = (item_sell_price * units_produced) - total_production_cost
    	
    	$('.item-total-cost').text(total_production_cost.toFixed(2))
    	$('.item-profit-margin').text(profit_margin.toFixed(2))
    	
    	if profit_margin >= 0
    		$('.item-profit-margin').css("color", "green")
    	else
    		$('.item-profit-margin').css("color", "red")
  )
