app = require './index'

app.get '/edit', (page, model, params, next) ->
	page.render 'edit'

app.get '/edit/:id', (page, model, params, next) ->
	item = model.at "ads.#{params.id}"
	item.subscribe (err) ->
		return next(err) if err
		return next() if !item.get()
		model.ref '_page.item', item
		page.render 'edit'


class EditForm
	
	done: ->
		model = @model

		if !model.get('item.id')
			model.root.add 'ads', model.get('item')
			# Wait for all model changes to go through before going to the next page, mainly because
			# in non-single-page-app mode (basically IE < 10) we want changes to save to the server before leaving the page
			model.whenNothingPending ->
				app.history.push '/edit'
				return
		else
			app.history.push '/'
		return


	cancel: ->
		app.history.back();

	delete: ->
		# Update model without emitting events so that the page doesn't update
		@model.silent().del 'item'

		# Wait for all model changes to go through before going back, mainly because
		# in non-single-page-app mode (basically IE < 10) we want changes to save to the server before leaving the page
		@model.whenNothingPending ->
			app.history.push '/'
			return

app.component 'edit:form', EditForm