[![Gem Version](https://badge.fury.io/rb/easy-exist.svg)](http://badge.fury.io/rb/easy-exist)

# Easy-Exist

An easy to use gem to interact with eXist-db via its REST API.


## Code Example

```
require 'easy-exist'

# connect
db = EasyExist::DB.new("http://localhost:8080", {
	username: "user", password: "easy"
})

# add a document
body =  "<message><body>Hello World</body></message>"
db.put("/my-collection/my-document", body)

# get document body
doc = db.get("/my-collection/my-document")

# query for all message bodies
bodies = db.query("collection('my-collection')/message/body");

# delete the document
db.delete("/my-collection/my-document")
```

## Installation

Simply add easy-exist to your Gemfile

```
source 'https://rubygems.org'
gem 'easy-exist'
```

Then install via bundler

`bundle install`

## Running Tests

RSpec is used for tests.
The tests run against a local exist-db instance under a "test-user" account. If you want to run the tests yourself, ensure that this test-user account has been created. You can update the connection properties in `spec/db_spec.rb`

```
let(:db) { 
    EasyExist::DB.new("http://localhost:8088", { 
        username: "test-user", 
        password: "password" 
    }) 
}
```

## API Reference

See the [Docs][easy-exist-docs]

## Contributing
1. Fork the project.
2. Create your branch
3. Commit your changes with tests
4. Create a Pull Request

[easy-exist-docs]:	http://casst01.github.io/easy-exist/docs
