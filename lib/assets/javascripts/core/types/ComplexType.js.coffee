@namespace "core.types", ->

    class @ComplexType
    
        constructor: (@tyName, @tyDef, @propertyFactory) ->
            @kind = "complex"
            
        deserializePermissions: (data, target) ->
            target.permissions ?= {}
            for permission_name, has_permission of data
                if target.permissions[permission_name]?
                    target.permissions[permission_name](has_permission) 
                else
                    target.permissions[permission_name] = @propertyFactory.createProperty( has_permission )
        
        serialize: (obj, env, includeSpec, nested) ->
        
            data = {}
            tyDef = @tyDef
            includeSpec ?= {}
            
            serializeField = (propName, propDef) ->
                propTyName = propDef.class_name
                propTy = env.getType propTyName
                propKind = propTy.kind # TODO: don't need this var
                include = propDef.serialize? || includeSpec[propName]? || ( propDef.primary_key && nested )
                
                if include
                    prop = obj[propName]
                    propVal = prop() unless not prop
                    
                    if propDef.association
                        propName = "#{propName}_attributes"
                    
                    data[propName] = propTy.serialize propVal, env, includeSpec[propName], true
            
            for propName, propTyName of tyDef.attributes
                serializeField propName, propTyName
            
            data
            
        initialize: (target, env, includeSpec) ->
        
            tyDef = @tyDef
            includeSpec ?= {}
        
            initializeField = (propName, propDef) ->
                propTyName = propDef.class_name
                propTy = env.getType propTyName
                propKind = propTy.kind # TODO: don't need this var
                if includeSpec[propName]?
                    if propKind == "list"
                        target[propName]([])
                    else if propDef.association
                        propVal = env.create(propTyName, {})
                        target[propName](propVal)
                
            for propName, propTyName of tyDef.attributes
                initializeField propName, propTyName 
                
            target
            
        deserialize: (data, env, target) ->
        
            target = target ?= env.create(@tyName)
            tyDef = @tyDef
            self = @
            
            if !data?
                return target
            
            deserializeField = (propName, propDef) ->
                propTyName = propDef.class_name
                propTy = env.getType propTyName
                propKind = propTy.kind # TODO: don't need this var
                propVal = propTy.deserialize data[propName], env
                if target[propName]?
                    target[propName]( propVal )
                else
                    if propKind == "list"
                        prop = self.propertyFactory.createArrayProperty propVal
                    else
                        prop = self.propertyFactory.createProperty propVal
                
                    target[propName] = prop
            
            for propName, propTyName of tyDef.attributes
                deserializeField propName, propTyName 
            
            @deserializePermissions(data.permissions || { read: false, write: false }, target)
            
            target