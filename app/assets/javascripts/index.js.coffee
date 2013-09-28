$ ->
	if $('#main-index').length != 0
		$('.blueprint-toggle').click(
			() ->
				obj = $(this)
				icon = obj.children(".glyphicon")
				group = obj.parent().parent().parent()
				id = group.attr("id")
				
				console.log "clicked: #{obj.text()} ID:#{id}"
				
				evedata_url = "http://evedata.herokuapp.com/blueprints?group_id=#{id}&limit=100"
				$.getJSON(
					evedata_url
					(data) ->
						console.log "recieved data from evedata...\ncreating HTML..."
						group.children("##{id}-collapse").children(".panel-body").empty()
						for blueprint in data
							group.children("##{id}-collapse").children(".panel-body").append("<div class='blueprint'><a href='blueprints/#{blueprint['id']}'><img src='#{blueprint['images']['small']}' /></a>&nbsp;<a href='blueprints/#{blueprint['id']}'>#{blueprint['name']}</a></div>")
				)
		)
