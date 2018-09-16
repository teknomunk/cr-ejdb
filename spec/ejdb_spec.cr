require "./spec_helper"

`rm test.ejdb*`

describe EJDB do
  # TODO: Write tests

  it "creates a database" do
  	db = EJDB.open("test.ejdb", EJDB::DEFAULT_OPEN_MODE | EJDB::JBOTRUNC )
	db.close

	File.exists?("test.ejdb").should eq(true)
  end
  it "stores objects" do
  	db = EJDB.open("test.ejdb", EJDB::DEFAULT_OPEN_MODE | EJDB::JBOTRUNC )
	person1 = {
		"_id"=>"",
		"name"=>"somebody somefamily",
		"age"=>21,
		"address"=> [ "1234 Nowhere Drive", "Citysville, ST" ]
	}
	person2 = {
		"_id"=>"",
		"name"=>"john smith",
		"age"=>21,
		"address"=> [ "1237 Nowhere Drive", "Citysville, ST" ]
	}
	db.save("testing", person1, person2 )

	results = db.find("testing", {"name"=>"somebody somefamily"} )
	results.size.should eq(1)
	results[0].should eq(person1)

	results = db.find("testing", {"name"=>"john smith"} )
	results.size.should eq(1)
	results[0].should eq(person2)

	results = db.find( "testing", {"age" => 21} )
	results.size.should eq(2)

	results = db.find( "testing", {"age" => 21}, {} of String => String )
	results.size.should eq(2)

	results = db.find( "testing", {"age" => 21}, {"$max" => 1 } )
	results.size.should eq(1)

	db.close
  end
end
