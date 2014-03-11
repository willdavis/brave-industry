$ ->
	if $('#market-details-panel').length != 0
    window.solar_system_ids = {}
    $('#solar_name').typeahead(
      source: (query, process) ->
        $.get(
          'http://evedata.herokuapp.com/solar_systems'
          { limit: 5, name: query }
          (data) ->
            names = []
            $.each(data, (key, val) ->
              names.push(data[key].name)
              solar_system_ids[data[key].name] = data[key].id
            )
            process(names)
        )
      updater: (item) ->
        $('#solar_id').val(solar_system_ids[item])
        return item
        
      minLength: 3
    )

    $('#solar_name').change(
      () ->
        $('#solar_id').val("") if $(this).val() == ""
    )
