
$ = jQuery
window.cocoa = window.cocoa || {}       # cocoa interface in script
window.cocoa_ = window.cocoa_ || {}     # ojective-c objects in script
window.onerror = (msg) -> cocoa_.error msg

$.extend window.cocoa,
    _type_: (source) ->
        if source
            switch typeof(source)
                when 'boolean' then return 'bool'
                when 'string' then return 'string'
                when 'number' then return 'number'
                when 'object'
                    return 'array' if source.constructor == Array
                    return 'date' if source.constructor == Date
                    return 'dictionary'
        'null'

    _keys_: (source) ->
        Object.keys(source)

    _json_parse_: (json) ->
        @_replace_date_ JSON.parse(json)

    _replace_date_: (obj) ->
        if (obj)
            if typeof(obj) is 'string'
                if obj.match /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z$/
                    return new Date(obj)

            else if typeof(obj) is 'object'
                if obj.constructor == Array
                    # array
                    return (@_replace_date_(x) for x in obj)
                else
                    # object
                    for key in Object.keys(obj)
                        obj[key] = @_replace_date_ obj[key]
        obj

    # objective-c methods mapping
    print: (msg) -> cocoa_.print msg
    error: (msg) -> cocoa_.error msg
    handler: (tag, msg) -> @_json_parse_ cocoa_.handler(tag, msg)
