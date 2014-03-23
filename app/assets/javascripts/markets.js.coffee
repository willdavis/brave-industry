$ ->
	if $('.markets-show').length != 0
    # setup market history
    min_sell_history = []
    max_sell_history = []

    # setup market volume & count
    market_volume = []
    market_order_count = []

    # get info from the HTML page
    product_id = $('.item-sell-price').attr("id")
    region_id = $('#region-id').text()
    item_id = $('#item-id').text()

    market_url = "http://public-crest.eveonline.com/market/#{region_id}/types/#{item_id}/history/"
    console.log market_url

    $.when(
      get_market_data(market_url, min_sell_history, max_sell_history, market_volume, market_order_count)
    ).done(
      (results) ->
        console.log results
        price_history_range = []
        
        for item in results.items
          price_history_range.push([item["date"], item["lowPrice"], item["highPrice"]])
        
        $('#price_history_chart').empty()
        $('#volume_history_chart').empty()
        
        $('#price_history_chart').highcharts(
          chart:
            zoomType: 'x'
          title:
            text: 'Price History'
          xAxis:
            type: 'datetime'
            title:
              text: null
          yAxis:
            title:
              text: null
          tooltip:
            crosshairs: true
            shared: true
            valueSuffix: ' ISK'
          series: [
            {
              type: 'arearange'
              name: 'Sell Prices'
              data: price_history_range
            }
          ]
        )
    )
    
  $('#region_id').change(
    () ->
      region_id = $(this).find("option:selected").val()
      type_id = $('#type_name').val()
      $('#update-region').prop("href", "/markets/#{region_id}/types/#{type_id}")
  )
  
  $('#type_name').change(
    () ->
      region_id = $('#region_id').find("option:selected").val()
      type_name = $('#type_name').val()
      $('#update-region').prop("href", "/markets/#{region_id}/types/#{type_name}")
  )
    
get_market_data = (url, min_price_array, max_price_array, volume_array, order_array) ->
  # lookup eve central data
  $.getJSON(
	  url
	  (data) ->
      for item in data.items
        time = new Date(item["date"])
        #min_price_array.push([time, item["lowPrice"]])
        max_price_array.push([time, item["highPrice"]])
        volume_array.push([time, item["volume"]])
        order_array.push([time, item["orderCount"]])
  )
