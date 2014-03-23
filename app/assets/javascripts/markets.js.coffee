$ ->
	if $('.markets-show').length != 0
    # get info from the HTML page
    product_id = $('.item-sell-price').attr("id")
    region_id = $('#region-id').text()
    item_id = $('#item-id').text()

    market_url = "http://public-crest.eveonline.com/market/#{region_id}/types/#{item_id}/history/"
    console.log market_url

    $.when(
      $.getJSON(market_url)
    ).done(
      (results) ->
        console.log results
        price_range = []
        
        if typeof document.ontouchstart == "undefined"
          subtitle_text = 'Click and drag in the plot area to zoom in'
        else
          subtitle_text = 'Pinch the chart to zoom in'
        
        for item in results.items
          price_range.push([item["date"], item["lowPrice"], item["highPrice"]])
        
        $('#price_history_chart').empty()
        $('#volume_history_chart').empty()
        
        $('#price_history_chart').highcharts(
          chart:
            zoomType: 'x'
          title:
            text: 'Price History'
          subtitle:
            text: subtitle_text
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
              data: price_range
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
