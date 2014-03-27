$ ->
	if $('.markets-show').length != 0
    region_id = $('#region_id').find("option:selected").val()
    system_id = $('#system_id').text()
    item_id = $('#type_id').text()

    market_history_url = "http://public-crest.eveonline.com/market/#{region_id}/types/#{item_id}/history/"
    console.log "EVE Market History (CREST API): #{market_history_url}"

    if $("#location_region").is(':checked')
      current_orders_url = "http://api.eve-central.com/api/quicklook?regionlimit=#{region_id}&typeid=#{item_id}"
      console.log "EveCentral quicklook: #{current_orders_url}"
      
      current_market_url = "http://api.eve-central.com/api/marketstat?regionlimit=#{region_id}&typeid=#{item_id}"
      console.log "EveCentral marketstat: #{current_market_url}"
    else
      current_orders_url = "http://api.eve-central.com/api/quicklook?usesystem=#{system_id}&typeid=#{item_id}"
      console.log "EveCentral quicklook: #{current_orders_url}"
      
      current_market_url = "http://api.eve-central.com/api/marketstat?usesystem=#{system_id}&typeid=#{item_id}"
      console.log "EveCentral marketstat: #{current_market_url}"

    $.when(
      $.getJSON(market_history_url)
      $.get(current_orders_url)
      $.get(current_market_url)
    ).done(
      (market_history, current_orders, current_market) ->
        
        orders = {}
        orders["sell"] = 0
        orders["buy"] = 0
        order_data = []
        
        sell_order_total = 0
        buy_order_total = 0
        
        sell_order_quantity = []
        buy_order_quantity = []
        
        $(current_orders).find("sell_orders").find("order").each(
          () ->
            sell_order_total++
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
            buy_order_total++
            station = $(this).find("station_name").text()
            volume = parseInt($(this).find("vol_remain").text())            
            
            buy_order_quantity.push([station, volume])
            
            if !orders["buy"]
              orders["buy"] = volume
            else
              orders["buy"] += volume
        )
        
        price_range_history = []
        sell_volume_history = []
        order_count_history = []
        
        if typeof document.ontouchstart == "undefined"
          subtitle_text = 'Click and drag in the plot area to zoom in'
        else
          subtitle_text = 'Pinch the chart to zoom in'
        
        if $("#location_region").is(':checked')
          for item in market_history[0].items
            year = item["date"].match(/^\d+/g)
            month = parseInt(item["date"].match(/\b\d{2}(?=-)/g))-1
            day = item["date"].match(/\b\d{2}(?=T)/g)
          
            timestamp = Date.UTC(year, month, day)
            price_range_history.push([timestamp, item["lowPrice"], item["highPrice"]])
            sell_volume_history.push([timestamp, item["volume"]])
            order_count_history.push([timestamp, item["orderCount"]])
        
        sell_highPrice = $(current_market).find('sell').find('max').text().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        sell_lowPrice = $(current_market).find('sell').find('min').text().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        sell_total = sell_order_total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        sell_quantity = orders["sell"].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        
        $('#sell-orders-highPrice').text("#{sell_highPrice} ISK")
        $('#sell-orders-lowPrice').text("#{sell_lowPrice} ISK")
        $('#sell-orders-total').text(sell_total)
        $('#sell-orders-quantity').text(sell_quantity)
        
        buy_highPrice = $(current_market).find('buy').find('max').text().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        buy_lowPrice = $(current_market).find('buy').find('min').text().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        buy_total = buy_order_total.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        buy_quantity = orders["buy"].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
        
        $('#buy-orders-highPrice').text("#{buy_highPrice} ISK")
        $('#buy-orders-lowPrice').text("#{buy_lowPrice} ISK")
        $('#buy-orders-total').text(buy_total)
        $('#buy-orders-quantity').text(buy_quantity)
          
        $('#current_orders').highcharts(
          chart:
            type: 'pie'
          title:
            text: 'Buy & Sell Orders'
          subtitle:
            text: 'Click on the slices to view orders by space station'
          series:[
            {
              name: "Orders"
              data:[
                {
                  name: "Sell Orders"
                  y: sell_order_total
                  drilldown: "sell"
                }
                {
                  name: "Buy Orders"
                  y: buy_order_total
                  drilldown: "buy"
                }
              ]
            }
          ]
          drilldown:
            series:[
              {
                name: "Sell Order"
                id: "sell"
                data: sell_order_quantity
                tooltip:
                  valueSuffix: " units"
              }
              {
                name: "Buy Order"
                id: "buy"
                data: buy_order_quantity
                tooltip:
                  valueSuffix: " units"
              }
            ]
        )
        
        # only render history graphs if the search is by region
        if $("#location_region").is(':checked')
          $('#price_history_chart').highcharts(
            'StockChart'
            rangeSelector:
              inputEnabled: $('#price_history_chart').width() > 480
              selected: 2
            chart:
              zoomType: 'x'
            title:
              text: 'Transaction Prices'
            subtitle:
              text: subtitle_text
            legend:
              enabled: false
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
                name: 'Price Range'
                data: price_range_history
              }
            ]
          )
          
          $('#volume_history_chart').highcharts(
            'StockChart'
            rangeSelector:
              inputEnabled: $('#volume_history_chart').width() > 480
              selected: 2
            chart:
              zoomType: 'x'
            title:
              text: 'Transaction Volume'
            subtitle:
              text: subtitle_text
            legend:
              enabled: true
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
              }
              {
                type: 'column'
                name: 'Transactions'
                data: order_count_history
              }
            ]
          )
    )
    
  $('input[type="radio"]').click(
    () ->
      region_id = $('#region_id').find("option:selected").val()
      system_name = $('#system_name').val()
      type_name = $('#type_name').val()
      
      region_url = "/markets/region/#{region_id}/types/#{type_name}"
      system_url = "/markets/system/#{system_name}/types/#{type_name}"
      
      if $("#location_region").is(':checked')
        $('#update-market').prop("href", region_url)
      else
        $('#update-market').prop("href", system_url)
  )
    
  $('#region_id').change(
    () ->
      region_id = $(this).find("option:selected").val()
      type_name = $('#type_name').val()
      system_name = $('#system_name').val()
      url = "/markets/region/#{region_id}/types/#{type_name}"
      $('#region_url').text(url)
      
      if $("#location_region").is(':checked')
        $('#update-market').prop("href", url)
  )
  
  $('#type_name').change(
    () ->
      region_id = $('#region_id').find("option:selected").val()
      system_name = $('#system_name').val()
      type_name = $('#type_name').val()
      
      region_url = "/markets/region/#{region_id}/types/#{type_name}"
      system_url = "/markets/system/#{system_name}/types/#{type_name}"
      
      if $("#location_region").is(':checked')
        $('#update-market').prop("href", region_url)
      else
        $('#update-market').prop("href", system_url)
  )
  
  $('#system_name').change(
    () ->
      system_name = $('#system_name').val()
      type_name = $('#type_name').val()
      url = "/markets/system/#{system_name}/types/#{type_name}"
      
      if $("#location_system").is(':checked')
        $('#update-market').prop("href", url)
  )
