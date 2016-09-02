module EasyExist



	# Representation of an eXist-db query request.
	# Responsible for encapsulating the XQuery text ready to POST to server.
	class QueryRequest

		using EasyExist::RefinedTrue
		using EasyExist::RefinedFalse
		using EasyExist::RefinedObject

		# Initializes an EasyExist::QueryRequest.
		# Takes the given XQuery text and builds an Nokogiri::XML object around it.
		#
		# @param text [String] the XQuery text
		# @param opts [Hash] options for the query request.
		# @option opts :start [Integer] Index of first item to be returned.
		# @option opts :max [Integer] The maximum number of items to be returned.
		# @option opts :wrap [Boolean] Wrap results in exist:result element.
		# @option opts :variables [Hash] external variables to pass into the XQuery. Keys are variable names, values can be single strings or numbers, or an array of strings and numbers. Exist-db also supports passing arbitary XML as a variable but that isnt supported yet.
		# @return [EasyExist::QueryRequest] an instance of an EasyExist::QueryRequest.
		def initialize(text, opts = {})
			@body = Nokogiri::XML::Builder.new do |xml|
				variables = opts[:variables]
				xml.query({ xmlns: EXIST_NAMESPACE }.merge(parse_opts(opts))) {
					xml.text_ text
					if variables
						add_variables(xml,variables)
					end
				}
			end
		end

		# Returns the request body as xml
		#
		# @return [String] the request body
		def body
			@body.to_xml
		end

		private
			def parse_opts(opts)
				if(opts.key?(:wrap)) then
					raise(ArgumentError, ":wrap must be a TrueClass or FalseClass") unless opts[:wrap].is_a_boolean?
					opts[:wrap] = opts[:wrap].to_yes_no
				end
				if opts.key?(:variables)
					opts.delete(:variables)
				end
				opts
			end

			def add_variables(xml,variables) # add variable support modelled after https://github.com/wolfgangmm/existdb-node/blob/master/lib/query.js
				xml.variables do
					variables.each do |name,values|
						xml.variable({'xmlns:sx'=> EXIST_SX_NAMESPACE}) do |var|
							var.qname do
								var.localname name
							end
							var['sx'].sequence do
								if !values.is_a? Array
									values = [values]
								end
								values.each do |value|
									var['sx'].value(value,{:type=> value_type(value)})
								end
							end
						end
					end
				end
			end

			def value_type(value)
				type="xs:string"
				if value.is_a? Integer
					type="xs:integer"
				elsif value.is_a? Float
					type="xs:double"
				end
				type
			end
	end

end
