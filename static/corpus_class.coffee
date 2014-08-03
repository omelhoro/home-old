$=jQuery
$ ->
	class TextMatrix
		constructor: ([@header,@values])->
			@max=d3.max (d3.max(v[1]) for v in @values)
			@origin= (v for v in @values)
			@sortk=0
			@sortedBy=@curSubset=null
			@logged=@log()
			@shares=@sharesCalc()

		sort: ->
			@values.sort (a,b) =>
				a[1][@sortk]<b[1][@sortk]
			@sortedBy=@sortk

		serve_n: (st,n) ->
			@curSubset= @values.slice(st,n)
			@maxf("ver")
			@curSubset

		log: ->
			postpro = (num) ->
				if num != -Infinity then num else 0 

			([valar[0],(postpro(Math.log(v)) for v in valar[1])] for valar in @origin)

			#@logged=( [ar[0],(Math.log(v) for v in ar.slice(1))] for ar in @origin)

		sharesCalc: ->
			
			percent= (ar) ->
				(a/totals[i] for a,i in ar)

			totals= {}
			for nm,i in @header
				totals[i]= d3.sum (v[1][i] for v in @origin)

			@shares= ( [v[0],percent(v[1])] for v in @origin)

		withShares: (modus) ->
			switch modus
				when "totals"
					@values= @origin
					#@max= @maxf("ver")
				when "shared"
					@values= @shares
					#@max= @maxf("ver")
				when "logged"
					@values= @logged
					#@max= @maxf("ver")
			if @fnsubset? #filter only if there is filter fn
				@filterY(@fnsubset)
			#@max= @maxf("ver")

		filterY: (f) ->
			v= (itm for itm in @values when f(itm[0]))
			if v.length!=0
				if v.length < @values.length #notice if its was actually filtered
					@fnsubset=f
				else
					@fnsubset=null
				@values=v

		maxf: (dim='ver')->
			if dim=='hor'
				sum= d3.sum (v[1][@sortk] for v in @curSubset)
				@max= @maxf()/sum
			else
				@max = d3.max (d3.max(v[1]) for v in @curSubset)

	class Handlers
		constructor: (@tmv,@tm) ->
			@sortk=@quaview=null
			@menu= $(".viz")
			@tab= $ "<table class='table vizfilter' >"
			@menu.append(@tab)
			@tinp=null
			@_tableFormat()
			@_addSortVisibs()
			@_addShares()
			@_bashSelect()
			@_yFilter()

		_yFilter: ->
			$(".submfiltery").click (e) =>
				f= filterFunc($(".yregex").val())
				startI= parseInt $(".startrange").val()
				end= parseInt $(".endrange").val()
				@tm.filterY(f)
				@tmv.start= startI
				@tmv.end= end
				@tmv.render()




		_addSortVisibs: ->
			$("input[name='sorting']").click (e) =>
				val= $(e.target).val()
				nval= parseInt(val)
				if nval != @sortk #double click doesnt lead to rendering same result
					@sortk= nval
					@tm.sortk= nval
					@tmv.render()

			$("input[name='visib']").click (e) =>
				val= $(e.target).val()
				isvis= $(e.target).prop("checked")
				opval= if isvis then 1 else 0

				nval= parseInt(val)
				@tmv.activate(opval,500,nval)


		_bashSelect: ->
			@tinp= $ ".catregex"
			$(".submcatregex").click =>
				f= filterFunc(@tinp.val())
				@filterVis(f)

		filterVis: (f) ->

			$("input[name='visib']").each (i,e) =>
				$e= $(e)
				t= $e.data("pointer")
				if f(t)
					console.log t
					$e.prop("checked",true)
					@tmv.activate(1,500,i)
				else
					$e.prop("checked",false)
					@tmv.activate(0,500,i)

		_tableFormat: ->
			trHead= $ "<tr></tr>"
			trHead.append "<th></th>"
			for nm,i in @tm.header
				td= $ "<th>#{nm}</th>"
				td.css("color", @tmv.colorScale(i))
				trHead.append(td)
			@tab.append(trHead)

			trSort= $ "<tr><td>Sorting</td></tr>"
			renderButtons= (nm,i,type='radio',name='sorting') =>
				inp= $ "<td><input type=#{type} name=#{name} data-pointer=#{nm} value=#{i} checked=false ></td>"

			(trSort.append(renderButtons(h,i)) for h,i in @tm.header)
			@tab.append(trSort)

			trVis= $ "<tr><td>Visibility</td></tr>"
			(trVis.append(renderButtons(h,i,'checkbox',"visib")) for h,i in @tm.header)
			@tab.append(trVis)

		_addShares: ->
			$("input[name='quaview']").click (e) =>
				val= $(e.target).val()
				if val != @quaview
					@tm.withShares val
					@tmv.render(@sortk)



	filterFunc= (ftext)->
		#tma= null

		startswith= (t) ->
			ssub= t.slice(0,tma.length)
			ssub==tma

		endswith = (t) ->
			offset= t.length-tma.length
			ssub= t.slice(offset)
			ssub==tma

		has = (t) ->
			try
				t.match(tma).index
				true
			catch
				false 

		[f,tma]= switch [ftext[0]=="*",ftext[ftext.length-1]=="*"].join()
			when "true,true" then [has,ftext.slice(1,ftext.length-1)]
			when "false,true" then [startswith,ftext.slice(0,ftext.length-1)]
			when "true,false" then [endswith,ftext.slice(1)]
			when "false,false" then [has,ftext]
		if ftext then f else ( (d) -> true )



	class TextMatrixViz

		constructor: (@tm,@HE,@WI,@MA,@how_many)->
			@update=false
			[@svg,@body,@axes]=@_makeSvgBodyAxes()
			@x_scale=@y_scale=null 
			@colorScale=d3.scale.category10()
			@subs=null
			@active=[]
			@start=0
			@end=60

		_makeSvgBodyAxes: ->
			svg= d3.select(".corpus_viz")
				.append("svg")
					.attr {
						height:@HE
						width:@WI
					}
			body= d3.select("svg")
					.append("g")
						.attr {
							class: "body"
							transform: "translate(#{@MA},#{@MA})"
						}
			axes= d3.select("svg")
					.append("g")
						.attr("class","axes")
			[svg,body,axes]

		_makeAxes: ->
			@_makeScales()
			y_axis= d3.svg.axis()
				.scale(@y_scale)
				.tickFormat( (d,i) => @tm.values[i+@start][0])
				.orient("left")

			x_axis= d3.svg.axis()
				.scale(@x_scale)
				.orient("top")

			@_makeAxis x_axis, "x", @MA , @MA 
			@_makeAxis y_axis, "y", @MA, @MA
			@update=true
			[x_axis,y_axis]

		_makeAxis: (axis,dim,trans0,trans1)->
			if @update
				comp_ax= @svg.select(".#{dim}axis").call(axis)
			else
				comp_ax= @axes.append("g")
					.attr {
						class: "#{dim}axis",
						transform: "translate(#{trans0},#{trans1})"
						}
					.call(axis)

			d3.selectAll(".#{dim}.grid-line").remove() #remove old ones, so no stacking when updating
			d3.selectAll("g.#{dim}axis g.tick")
                .append("line")
                    .classed("#{dim} grid-line",true)
                    .attr {
                        x1: if dim=="y" then -10  else 0
                        y1: if dim=="x" then -10  else 0
                        x2: if dim=="y" then @WI-@MA  else 0
                        y2: if dim=="x" then @HE-@MA  else 0
                    }
			if dim=="y"
				fontSize= @y_scale.rangeBand()
				comp_ax.selectAll("text").attr("font-size",fontSize)

		_makeScales: ->
			@y_scale= d3.scale.ordinal()
				.domain(d3.range(@end- @start))
				.rangeRoundBands([0,@HE-@MA], 0)
			@x_scale= d3.scale.linear()
				.domain([0, @tm.max])
				.range([0, @WI-@MA])
			[@x_scale,@y_scale]

		_makeCircles: ->
			console.log @start,@end
			
			for nm,i in @tm.header
				nmSubs= (v[1][i] for v in @subs )
				active= if nm in @active then 1 else 0
				dpoints= @body.selectAll(".circle#{i}")
				
				dpoints.data(nmSubs)
					.exit()
					.remove()

				dpoints.data(nmSubs)
					.enter()
					.append("circle")
					.attr {
						class: "circle#{i}"
						opacity: 0
						r:4
						fill: @colorScale(i)
						dt: (d,i) -> d
					}

				@body.selectAll(".circle#{i}")
					.data(nmSubs)
					.attr {
						cy: (d,i) => @y_scale(i)
						cx: (d,i) => @x_scale(d)
					}
		_makeLines: ->
            _line= d3.svg.line()
                .x (d,i) => @x_scale(d)
                .y (d,i) => @y_scale(i)

            ldata= ((v[1][i] for v in @subs ) for i in [0...@tm.header.length])
            @body.selectAll("path.line")
                .data(ldata)
                .exit()
                .remove()

            @body.selectAll("path.line")
                .data(ldata)
                .enter()
                .append("path")
                .attr {
                    class: (d,i) ->  "line a#{i}"
                }

            @body.selectAll("path.line")
                    .data(ldata)
                    .transition()
                    .style "stroke", (d,i) => @colorScale(i)
                    .attr {
                        "d": (d) -> _line(d)
                       }

		render: () ->
			console.log "render"
			@tm.sort()
			@subs= @tm.serve_n(@start,@end)
			@_makeAxes()
			@_makeCircles()
			@_makeLines()

		activate: (num=1,time=500,pool=@tm.header) ->

			opa= (sel) =>
				@body.selectAll(sel)
				.transition().duration(time)
				.attr {
				opacity: num
				}

			if typeof pool=="number"
				spool= [@tm.header[pool]]
				pool= @tm.header
			else
				spool= @tm.header
			for nm,i in pool
				if nm in spool
					#opa(".circle#{i}")
					opa("path.a#{i}")

	load_csv = ->

		reformat = (data) ->
			header= (k for k,v of data[0] when k!="index")
			values= []
			for obj in data
				values.push [obj.index,(parseFloat(v) for k,v of obj when k!="index")]
			[header,values]

		d3.csv corpus_src , (data) ->
			tm= new TextMatrix(reformat(data))
			view= new TextMatrixViz(tm,600,600,80,50)
			viewMenu= new Handlers(view,tm)
			view.render()

	load_csv()
