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
		# @return [EasyExist::QueryRequest] an instance of an EasyExist::QueryRequest.
		def initialize(text, opts = {})
			@body = Nokogiri::XML::Builder.new do |xml|
				xml.query({ xmlns: EXIST_NAMESPACE }.merge(parse_opts(opts))) {
					xml.text_ text
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
				opts
			end
	end

end