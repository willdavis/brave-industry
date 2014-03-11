$ ->
	if $("#price-check_results").length != 0
		query_evecentral()
	

query_evecentral = () ->
	total_price = 0
	region_id = $('#region-id').text()
	solar_id = $('#solar-id').text()
	
	if solar_id != ""
	  evecentral_url = "http://api.eve-central.com/api/marketstat?usesystem=#{solar_id}"
	else
	  evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=#{region_id}"
	
	$('.item').each(
    () ->
    	type_id = $(this).find('.item-id').text()
    	evecentral_url += "&typeid=#{type_id}"
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
    			
    			$(".item-#{id}").each(
    				(data) ->
    					obj = $($(".item-#{id}")[data])
    					qty = obj.find(".item-qty").text()
    					price = min_sell * qty
    					
    					obj.find(".item-price").text(price.toFixed(2))
    					total_price += price
    			)
    	)    	
    	$("#total-price").text(total_price.toFixed(2))
    	console.log "Reticulating splines..."
  )
