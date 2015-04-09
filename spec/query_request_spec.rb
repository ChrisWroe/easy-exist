require 'spec_helper'
require 'nokogiri'

describe "EasyExist::QueryRequest" do

	let(:text) { "collection('test-collection')//message" }

	context "when user does not provide options" do
		it "builds an eXist-db request around the given text" do
			req = EasyExist::QueryRequest.new(text)
			expected_body = <<-END;
				<query xmlns="http://exist.sourceforge.net/NS/exist">
					<text>collection('test-collection')//message</text>
				</query>
				END
			expect(parse_xml(req.body).to_xml).to eq parse_xml(expected_body).to_xml
		end
	end

	describe "options" do
		context "when user specifies range options" do
			it "sets the specified values" do
				opts = { start: 2, max: 10 }
				doc = parse_xml(EasyExist::QueryRequest.new(text, opts).body)
				expect(doc.xpath('/xmlns:query/@start').text).to eq "2"
				expect(doc.xpath('/xmlns:query/@max').text).to eq "10"
			end
		end

		context "when user specifies wrap options" do
			it "converts true value to yes" do
				opts = { wrap: true }
				doc = parse_xml(EasyExist::QueryRequest.new(text, opts).body)
				expect(doc.xpath('/xmlns:query/@wrap').text).to eq "yes"
			end
			it "converts false value to no" do
				opts = { wrap: false }
				doc = parse_xml(EasyExist::QueryRequest.new(text, opts).body)
				expect(doc.xpath('/xmlns:query/@wrap').text).to eq "no"
			end
		end
	end

end

def parse_xml(xml, remove_namespaces = false)
	Nokogiri::XML.parse(xml) do |config|
		config.noblanks
	end
end