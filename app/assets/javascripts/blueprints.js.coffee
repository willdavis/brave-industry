$ ->
	if $('#blueprints-show').length != 0
		##Show
		total_item_price = 0
		product_id = $('.item-sell-price').attr("id")
		evecentral_url = "http://api.eve-central.com/api/marketstat?regionlimit=10000002"
		
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
    
    $.get(
      evecentral_url
      (data) ->
      	$(data).find("type").each(
      		() ->
      			console.log this
      			id = $(this).attr("id")
      			min_sell = $(this).find("sell").find("min").text()
      			
      			$("#raw-#{id}").children('.raw-material-unit-price').text(min_sell)
      			$("#extra-#{id}").children('.extra-material-unit-price').text(min_sell)
      			
      			raw_quantity = $("#raw-#{id}").children('.raw-material-quantity').text()
      			extra_quantity = $("#extra-#{id}").children('.extra-material-quantity').text()
      			
      			total_price_for_raw_material = min_sell * raw_quantity
      			total_price_for_extra_material = min_sell * extra_quantity
      			
      			total_item_price += total_price_for_raw_material
      			total_item_price += total_price_for_extra_material
      			
      			$("#raw-#{id}").children('.raw-material-total-price').text(total_price_for_raw_material)
      			$("#extra-#{id}").children('.extra-material-total-price').text(total_price_for_extra_material)
      	)
      	
      	$('.item-total-cost').text(total_item_price)
    )
    
    $.get(
      "http://api.eve-central.com/api/marketstat?regionlimit=10000002&typeid=#{product_id}"
      (data) ->
      	$(data).find("type").each(
      		() ->
      			console.log this
      			id = $(this).attr("id")
      			min_sell = $(this).find("sell").find("min").text()
      			
      			$(".item-sell-price").text(min_sell)
      	)
    )
