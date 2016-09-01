require 'httparty'
require 'nokogiri'
require_relative "./easy-exist/refinements"
require_relative "./easy-exist/query_request"
require_relative "./easy-exist/db"

# The EasyExist module
module EasyExist

	# Defines the eXist-db xml namespace
	EXIST_NAMESPACE = "http://exist.sourceforge.net/NS/exist"
	EXIST_SX_NAMESPACE = "http://exist-db.org/xquery/types/serialized"
end
