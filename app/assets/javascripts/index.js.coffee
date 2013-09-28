$ ->
	if $('#main-index').length != 0
		$('.blueprint-toggle').click(
			() ->
				panel_title = $(this)
				group_panel = panel_title.parent().parent().parent().parent().parent().parent().parent()
				group_id = group_panel.attr("id")
				group_blueprints = group_panel.children("##{group_id}-collapse").children(".panel-body")
				
				console.log "clicked ID:#{group_id}"
				
				if group_blueprints.children(".blueprint").length != 0
					console.log "Blueprints already loaded from evedata.  Displaying cached content"
				else
					console.log "No blueprints present.  Loading from evedata..."
					evedata_url = "http://evedata.herokuapp.com/blueprints?group_id=#{group_id}&limit=100"
					$.getJSON(
						evedata_url
						(data) ->
							console.log "recieved data from evedata...\ncreating HTML..."
							for blueprint in data
								group_panel.children("##{group_id}-collapse").children(".panel-body").append("<table class='blueprint'><tr><td width='32' height='32'><a href='blueprints/#{blueprint['id']}'><img src='#{blueprint['images']['small']}' /></a></td><td><a href='blueprints/#{blueprint['id']}'>#{blueprint['name']}</a></td></table>")
					)
		)
