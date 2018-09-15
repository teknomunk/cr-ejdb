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
	db.save("testing", person1 )

	results = db.find("testing", {"name"=>"somebody somefamily"} )
	puts person1.inspect
	puts results.inspect
	results.size.should eq(1)
	results[0].should eq(person1)
	db.close
  end
end
