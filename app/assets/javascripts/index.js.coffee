$ ->
	if $('#main-index').length != 0
		$('.group-name').click(
			() ->
				group = $(this).parent()
				id = group.attr("id")
				
				console.log "clicked group: #{id}"
				
				if group.children(".group-blueprints").children().length != 0
					console.log "minimizing group: #{id}"
					group.children(".group-blueprints").fadeOut(
						"slow"
						() ->
							group.children(".group-blueprints").empty()
					)
				else
					console.log "looking up blueprints within group: #{id}"
					evedata_url = "http://evedata.herokuapp.com/blueprints?group_id=#{id}"
					$.getJSON(
						evedata_url
						(data) ->
							console.log "recieved data from evedata...\ncreating HTML..."
							for blueprint in data
								group.children(".group-blueprints").append("<div class='blueprint'><a href='blueprints/#{blueprint['id']}'><img src='#{blueprint['images']['small']}' /></a>&nbsp;<a href='blueprints/#{blueprint['id']}'>#{blueprint['name']}</a></div>").fadeIn("slow")
					)
		)
