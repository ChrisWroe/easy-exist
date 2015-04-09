module EasyExist

	# Responsible for communicating with the eXist-db server
	class DB

		# Initializes an EasyExist::DB.
		#
		# @param url [String] the url to the eXist-db server, include protocol.
		# @param opts [Hash] options to initialize the DB with.
		# @option opts :collection [String] The collection for which all GET, PUT and DELETE requests will be relative to.
		# @option opts :username [String] Username for Basic HTTP Authentication.
		# @option opts :password [String] Password for Basic HTTP Authentication.
		# @return [EasyExist::DB] an instance of an EasyExist::DB.
		def initialize(url, opts = {})
			validate_opts(opts)
			@default_opts = { base_uri: url + "/exist/rest/db#{opts[:collection] ||= ''}" }
			if(opts[:username] && opts[:password])
				@default_opts[:basic_auth] = { username: opts[:username], password: opts[:password] }
			end
		end

		# Retrieves the document at the specified document_uri from the store.
		#
		# @param document_uri [String] the uri of the document to retrieve.
		# relative to the collection specified on initialization otherwise '/db'.
		# @return [String] the contents of the document at 'document_uri'
		def get(document_uri)
			validate_uri(document_uri)
			res = HTTParty.get(document_uri, @default_opts)
			res.success? ? res.body	: handle_error(res)
		end

		# Puts the given document content at the specified document_uri
		#
		# @param document_uri [String] the uri of the document to store.
		# relative to the collection specified on initialization otherwise '/db'.
		# @return [HTTParty::Response] the response object
		def put(document_uri, document)
			validate_uri(document_uri)
			res = HTTParty.put(document_uri, @default_opts.merge({
				body: document,
				headers: { "Content-Type" => "application/xml"},
			}))
			res.success? ? res : handle_error(res)
		end

		# Deletes the document at the specified document_uri from the store
		#
		# @param document_uri [String] the uri of the document to delete.
		# relative to the collection specified on initialization otherwise '/db'.
		# @return [HTTParty::Response] the response object
		def delete(document_uri)
			validate_uri(document_uri)
			res = HTTParty.delete(document_uri, @default_opts)
			res.success? ? res : handle_error(res)
		end

		# Determines if the document at the specified document_uri exists in the store
		#
		# @param document_uri [String] the uri of the document to check.
		# relative to the collection specified on initialization otherwise '/db'.
		# @return [TrueClass | FalseClass] 
		def exists?(document_uri)
			validate_uri(document_uri)
			HTTParty.get(document_uri, @default_opts).success?
		end

		# Runs the given XQuery against the store and returns the results
		#
		# @param query [String] XQuery to run against the store
		# @param opts [Hash] options for the query request.
		# @option opts :start [Integer] Index of first item to be returned.
		# @option opts :max [Integer] The maximum number of items to be returned.
		# @return [String] the query results
		def query(query, opts = {})
			body = EasyExist::QueryRequest.new(query, opts).body
			res = HTTParty.post("", @default_opts.merge({
				body: body,
				headers: { 'Content-Type' => 'application/xml', 'Content-Length' => body.length.to_s }
			}))
			res.success? ? res.body : handle_error(res)
		end

		private
			# Raises an error based on a HTTParty::Response.
			# HTTParty:Response objects contain a reference to the Net::HTTResponse object.
			# Where a request is unsuccessful, the reference can be raised as an exception for clients to rescue
			# and decide on next steps.
			#
			# @param res [HTTParty::Response] the response
			def handle_error(res)
				res.response.value
			end

			# Raises an error if the given uri does not start with a '/'
			#
			# @param uri [String] the uri to validate
			def validate_uri(uri)
				raise ArgumentError, 'URI must contain preceding "/"' if uri[0] != '/';
			end

			# Raises an error if any of the given opts are invalid
			#
			# @param opts [Hash] options to validate.
			def validate_opts(opts)
				validate_uri(opts[:collection]) unless opts[:collection].nil? || opts[:collection].empty?
			end
	end
end