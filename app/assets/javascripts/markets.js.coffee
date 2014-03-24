$ ->
	if $('.markets-show').length != 0
    region_id = $('#region-id').text()
    item_id = $('#item-id').text()

    market_history_url = "http://public-crest.eveonline.com/market/#{region_id}/types/#{item_id}/history/"
    console.log "EVE Market History (CREST API): #{market_history_url}"
    
    current_orders_url = "http://api.eve-central.com/api/quicklook?regionlimit=#{region_id}&typeid=#{item_id}"
    console.log "EveCentral quicklook: #{current_orders_url}"

    $.when(
      $.getJSON(market_history_url)
      $.get(current_orders_url)
    ).done(
      (market_history, current_orders) ->
        
        orders = {}
        order_data = []
        
        sell_order_quantity = []
        buy_order_quantity = []
        
        $(current_orders).find("sell_orders").find("order").each(
          () ->
            station = $(this).find("station_name").text()
            volume = parseInt($(this).find("vol_remain").text())
            
            sell_order_quantity.push([station, volume])
            
            if !orders["sell"]
              orders["sell"] = volume
            else
              orders["sell"] += volume
        )
        
        $(current_orders).find("buy_orders").find("order").each(
          () ->
            station = $(this).find("station_name").text()
            volume = parseInt($(this).find("vol_remain").text())            
            
            buy_order_quantity.push([station, volume])
            
            if !orders["buy"]
              orders["buy"] = volume
            else
              orders["buy"] += volume
        )
        
        console.log "Current sell orders: #{orders['sell']}\nCurrent buy orders: #{orders['buy']}"
        
        price_range_history = []
        sell_volume_history = []
        order_count_history = []
        
        if typeof document.ontouchstart == "undefined"
          subtitle_text = 'Click and drag in the plot area to zoom in'
        else
          subtitle_text = 'Pinch the chart to zoom in'
        
        for item in market_history[0].items
          price_range_history.push([item["date"], item["lowPrice"], item["highPrice"]])
          sell_volume_history.push([item["date"], item["volume"]])
          order_count_history.push([item["date"], item["orderCount"]])
          
          
        $('#current_orders').highcharts(
          chart:
            type: 'pie'
          title:
            text: 'Current Buy & Sell Quantity'
          subtitle:
            text: 'Click the slices to view a breakdown by space stations'
          series:[
            {
              name: 'Quantity'
              data:[
                {
                  name: "Sell Orders"
                  y: orders["sell"]
                  drilldown: "sell"
                }
                {
                  name: "Buy Orders"
                  y: orders["buy"]
                  drilldown: "buy"
                }
              ]
              tooltip:
                valueSuffix: ' units'
            }
          ]
          drilldown:
            series:[
              {
                name: "Sell Orders"
                id: "sell"
                data: sell_order_quantity
                tooltip:
                  valueSuffix: " units"
              }
              {
                name: "Buy Orders"
                id: "buy"
                data: buy_order_quantity
                tooltip:
                  valueSuffix: " units"
              }
            ]
        )
        
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
              data: price_range_history
            }
          ]
        )
        
        $('#volume_history_chart').highcharts(
          chart:
            zoomType: 'x'
          title:
            text: 'Trade Volume History'
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
          series: [
            {
              type: 'column'
              name: 'Units Sold'
              data: sell_volume_history
              tooltip:
                valueSuffix: ' Units'
            }
            {
              type: 'column'
              name: 'Sell Orders'
              data: order_count_history
              tooltip:
                valueSuffix: ' Orders'
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
