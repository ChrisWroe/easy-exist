require 'spec_helper'
require 'nokogiri'

describe "Easy Exist" do

	let(:db) 						{ EasyExist::DB.new("http://localhost:8088", { username: "test-user", password: "password" }) }
	let(:db_no_credentials) 		{ EasyExist::DB.new("http://localhost:8088") }
	let(:db_invalid_credentials) 	{ EasyExist::DB.new("http://localhost:8088", { username: "test-user", password: "wrongpassword" }) }
	let(:doc)						{ { uri: "/test-collection/test.xml", body: "<message language='en'><body>Hello World</body><sender>Alice</sender><recipient>Bob</recipient></message>" } }

	after(:each) { try_delete(doc[:uri]) }

	describe "#new" do
		context "when given collection name does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ EasyExist::DB.new("http:://localhost:8088", { collection: "my-collection" }) }
					.to raise_error(ArgumentError)
			end
		end
	end

	describe "#put" do
		it "stores the given document at the given uri" do
			db.put(doc[:uri], doc[:body]);
			expect(db.exists?(doc[:uri])).to be true
		end
		context("when username and password is not present") do
			it "raises a 401 HTTPServerException" do
				expect{ db_no_credentials.put(doc[:uri], doc[:body]) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not store the document" do
				expect{ db_no_credentials.put(doc[:uri], doc[:body]) }.
					to raise_exception do |e|
						expect(db.exists?(doc[:uri])).to be false
					end
			end
		end
		context("when username and password is incorrect") do
			it "raises a 401 HTTPServerException" do
				expect{ db_invalid_credentials.put(doc[:uri], doc[:body]) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not store the document" do
				expect{ db_invalid_credentials.put(doc[:uri], doc[:body]) }.
					to raise_exception do |e|
						expect(db.exists?(doc[:uri])).to be false
					end
			end
		end
		context "when given uri does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ db.put("uri/without/preceding/slash", doc[:body]) }.
					to raise_error(ArgumentError)
			end
		end
	end

	describe "#delete" do
		before(:each) { db.put(doc[:uri], doc[:body]) }
		it "removes the document at the given uri from the store" do
			db.delete(doc[:uri])
			expect(db.exists?(doc[:uri])).to be false
		end
		context("when username and password is not present") do
			it "raises a 401 HTTPServerException" do
				expect{ db_no_credentials.delete(doc[:uri]) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not delete the document" do
				expect{ db_no_credentials.delete(doc[:uri]) }.
					to raise_exception do |e|
						expect(db.exists?(doc[:uri])).to be true
					end
			end
		end
		context("when username and password is incorrect") do
			it "raises a 401 HTTPServerException" do
				expect{ db_invalid_credentials.delete(doc[:uri]) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not delete the document" do
				expect{ db_invalid_credentials.delete(doc[:uri]) }.
					to raise_exception do |e|
						expect(db.exists?(doc[:uri])).to be true
					end
			end
		end
		context "when given uri does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ db.delete("uri/without/preceding/slash") }.
					to raise_error(ArgumentError)
			end
		end
	end

	describe "#get" do
		before(:each) { db.put(doc[:uri], doc[:body]) }
		context "when document exists at given uri" do
			it "returns the document at the given uri" do
				expect(parse_xml(db.get(doc[:uri])).to_s).
					to eq parse_xml(doc[:body]).to_s
			end
		end
		context "when document does not exist at given uri" do
			it "raises a 404 HTTPServerException" do
				expect{ db.get("/test-collection/non-existant.xml") }.
					to raise_exception(Net::HTTPServerException, /404/)
			end
		end
		context("when username and password is incorrect") do
			it "raises a 401 HTTPServerException" do
				expect{ db_invalid_credentials.get(doc[:uri]) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
		end
		context "when given uri does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ db.get("uri/without/preceding/slash") }.
					to raise_error(ArgumentError)
			end
		end
	end

	describe "#exists?" do
		context "when given uri does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ db.exists?("uri/without/preceding/slash") }.
					to raise_error(ArgumentError)
			end
		end
	end

	describe "#query" do
		before(:each) { db.put(doc[:uri], doc[:body])}
		let(:query) { query = "collection('test-collection')//message/body" }
		it "returns the results of the query" do
			expect(db.query(query)).to include "<body>Hello World</body>"
		end
		context "when user specifies no wrap" do
			it "returns results without the wrapping exist:result element" do
				expect(db.query(query, { wrap: false  })).to eq "<body>Hello World</body>"
			end
			it "raises argument error if wrap is not a boolean" do
				expect{ db.query(query, { wrap: "false" }) }.
					to raise_error(ArgumentError, /:wrap must be a TrueClass or FalseClass/)
			end
		end
		context "when optional start value is out of range" do
			it "rasies a 400 HTTPServerException" do
				expect{ db.query(query, { start: 100 }) }.
					to raise_exception(Net::HTTPServerException, /400/)
			end
		end
		context("when username and password is incorrect") do
			it "raises a 401 HTTPServerException" do
				expect{ db_invalid_credentials.query(query) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
		end
	end

	describe "#store_query" do
		let(:query) { "let $var := 1\nreturn <var>{$var}</var>" }
		let(:query_uri) { "/my-collection/stored-queries/test.xql" }
		after(:each) { try_delete(query_uri) }

		it "should store the given query" do
			db.store_query(query_uri, query)
			expect(db.exists?(query_uri)).to be true
		end
		context "when given uri does not contain a preceding '/'" do
			it "raises an ArgumentError" do
				expect{ db.store_query("uri/without/preceding/slash.xql", query) }.
					to raise_error(ArgumentError)
			end
		end
		context("when username and password is not present") do
			it "raises a 401 HTTPServerException" do
				expect{ db_no_credentials.store_query(query_uri, query) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not store the query" do
				expect{ db_no_credentials.store_query(query_uri, query) }.
					to raise_exception do |e|
						expect(db.exists?(query_uri)).to be false
					end
			end
		end
		context("when username and password is incorrect") do
			it "raises a 401 HTTPServerException" do
				expect{ db_invalid_credentials.store_query(query_uri, query) }.
					to raise_exception(Net::HTTPServerException, /401/)
			end
			it "does not store the query" do
				expect{ db_invalid_credentials.store_query(query_uri, query) }.
					to raise_exception do |e|
						expect(db.exists?(query_uri)).to be false
					end
			end
		end
	end

	describe "#execute_stored_query" do
		let(:query) { "let $var := 1\nreturn <var>{$var}</var>" }
		let(:query_uri) { "/my-collection/stored-queries/test.xql" }
		after(:each) { try_delete(query_uri) }
		it "returns the result of running the stored query" do
			db.store_query(query_uri, query)
			expect(db.execute_stored_query(query_uri)).to eq "<var>1</var>"
		end
	end

end

def try_delete(uri)
	begin
		db.delete(uri)
	rescue Net::HTTPServerException => e
	end
end

def parse_xml(xml)
	Nokogiri::XML.parse(xml) do |config|
		config.noblanks
	end
end
