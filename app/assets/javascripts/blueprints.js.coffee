$ ->
	unless $('#blueprints-show').length == 0
		raw_type_ids = []
		extra_type_ids = []
		total_item_price = 0
		jita_sell_price = 0
		
		$('.raw-material').each(
      (index) ->
        id_attr = $($('.raw-material').get(index)).attr("id")
        id = id_attr.match(/\d+/)
        raw_type_ids.push(id)
    )
    
    raw_url ="http://api.eve-central.com/api/marketstat?regionlimit=10000002"
    raw_type_ids.forEach(
    	(elem) ->
    		raw_url += "&typeid=#{elem}"
    )
    
    console.log raw_url
    
    $.get(
      raw_url
      (data) ->
      	$(data).find("type").each(
      		() ->
      			console.log this
      			id = $(this).attr("id")
      			min_sell = $(this).find("sell").find("min").text()
      			
      			$("#raw-#{id}").children('.raw-material-unit-price').text(min_sell)
      			
      			quantity = $("#raw-#{id}").children('.raw-material-quantity').text()
      			total_price = min_sell * quantity
      			total_item_price += total_price
      			
      			$("#raw-#{id}").children('.raw-material-total-price').text(total_price)
      	)
    )
    
    $('.extra-material').each(
      (index) ->
        id_attr = $($('.extra-material').get(index)).attr("id")
        id = id_attr.match(/\d+/)
        extra_type_ids.push(id)
    )
    
    extra_url ="http://api.eve-central.com/api/marketstat?regionlimit=10000002"
    extra_type_ids.forEach(
    	(elem) ->
    		extra_url += "&typeid=#{elem}"
    )
    
    console.log extra_url
    
    $.get(
      extra_url
      (data) ->
      	$(data).find("type").each(
      		() ->
      			console.log this
      			id = $(this).attr("id")
      			min_sell = $(this).find("sell").find("min").text()
      			
      			$("#extra-#{id}").children('.extra-material-unit-price').text(min_sell)
      			
      			quantity = $("#extra-#{id}").children('.extra-material-quantity').text()
      			total_price = min_sell * quantity
      			total_item_price += total_price
      			
      			$("#extra-#{id}").children('.extra-material-total-price').text(total_price)
      	)
    )
    
    $('#total-cost').append(total_item_price)
    
    item_id = $('#jita-sell-price').children("span").attr("id")
    
    $.get(
      "http://api.eve-central.com/api/marketstat?regionlimit=10000002&typeid=#{item_id}"
      (data) ->
      	$(data).find("type").each(
      		() ->
      			console.log this
      			id = $(this).attr("id")
      			min_sell = $(this).find("sell").find("min").text()
      			$jita_sell_price = min_sell
      			
      			$("#jita-sell-price").children("span").append(min_sell)
      	)
    )
