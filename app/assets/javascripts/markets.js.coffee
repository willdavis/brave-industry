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
        $('#price_history_chart').empty()
        $('#volume_history_chart').empty()
        
        $.jqplot(
          'price_history_chart'
          [min_sell_history, max_sell_history]
          title:"Price History"
          series:[
            {
              label: "Low Price"
              showMarker:false
            }
            {
              label: "High Price"
              showMarker:false
            }
          ]
          legend:
            show: true
            location: 'e'
            placement: 'outside'
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
                formatString:'%v'
            yaxis:
              label:'Isk per Unit'
              labelRenderer: $.jqplot.CanvasAxisLabelRenderer
        )

        $.jqplot(
          'volume_history_chart'
          [market_volume, market_order_count]
          title: "Trade Volume"
          seriesDefaults:
            renderer: $.jqplot.BarRenderer
            rendererOptions:
              barMargin: 10
              barWidth: 10
          series:[
            {label: 'Volume'}
            {label: 'Orders'}
          ]
          legend:
            show: true
            location: 'e'
            placement: 'outside'
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
                formatString:'%v'
            yaxis:
              label:'Units'
              labelRenderer: $.jqplot.CanvasAxisLabelRenderer
        )
    )
    
get_market_data = (url, min_price_array, max_price_array, volume_array, order_array) ->
  # lookup eve central data
  $.getJSON(
	  url
	  (data) ->
      for item in data.items
        time = new Date(item["date"])
        min_price_array.push([time, item["lowPrice"]])
        max_price_array.push([time, item["highPrice"]])
        volume_array.push([time, item["volume"]])
        order_array.push([time, item["orderCount"]])
  )
