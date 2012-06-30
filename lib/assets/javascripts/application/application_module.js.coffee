namespace "core", ->

    class @ApplicationModule extends core.Mixable    
        @include core.DependentMixin
        @include core.EventsMixin
        
        constructor: (@name) ->
        
        @dependency sandbox: "Sandbox", -> @
        @dependency env: "Environment"
        
        @dependency container: (container) ->
            container.child().register_instance "Sandbox", @sandbox
   
        @dependency renderer: "Renderer"
        @dependency router: "Router"
        
    #class @ModuleCatalog
    
    #    constructor: ->
    #        @modules = []
            
    #    registerModule: ( klass, name ) ->
    #        @modules.push { klass: klass, name: name }
            
        #resolve: (app, container) ->
        #    for { cls } in @modules
        #        app.registerModule( container.resolve( new cls( 