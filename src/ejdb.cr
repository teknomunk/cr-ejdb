# TODO: Write documentation for `Ejdb`

require "json"

module EJDB
	VERSION = "0.1.0"


	module TokyoCabinet
		@[Link("ejdb")]
		lib Library
			struct TCLISTDATUM
				ptr : UInt8*
				size : Int32
			end
			struct TCLIST
				array : Pointer(TCLISTDATUM)
				anum : Int32
				start : Int32
				num : Int32
			end
			struct TCXSTR
				dummy : UInt8
			end
		end
	end
	class BSON
		@[Link("ejdb")]
		lib Library
			type Bool = Int32
			enum Validity
				VALID = 0
				NOT_UTF = (1<<1)
				FIELD_HAS_DOT = (1<<2)
				FIELD_INIT_DOLLAR = (1<<3)
				ALREADY_FINISHED = (1<<4)
				ERROR_ANY = (1<<5)
				NOT_FINISHED = (1<<6)
			end
			struct BSON
				data : UInt8*
				dur : UInt8*
				dataSize : Int32
				finished : Bool
				stack : StaticArray(Int32,32)
				stackPos : Int32
				err : Validity
				errstr : UInt8*
				flags : Int32
			end
			union OID
				bytes : StaticArray(Int8,12)
				ints : StaticArray(Int32,3)
			end
			type Date = Int64
			struct Timestamp
				i : Int32
				t : Int32
			end
			struct Iterator
				cur : UInt8*
				first : Bool
			end
			enum Type
				EOO = 0
				DOUBLE = 1
				STRING = 2
				OBJECT = 3
				ARRAY = 4
				BINDATA = 5
				UNDEFINED = 6
				OID = 7
				BOOL = 8
				DATE = 9
				NULL = 10
				REGEX = 11
				DBREF = 12
				CODE = 13
				SYMBOL = 14
				CODEWSCOPE = 15
				INT = 16
				TIMESTAMP = 17
				LONG = 18
			end

			fun bson_init( b : Pointer(BSON) ) : Void
			fun bson_init_as_query( b : Pointer(BSON) ) : Void
			fun bson_destroy( b : Pointer(BSON) ) : Void
			fun bson_append_int( b : Pointer(BSON), name : UInt8*, i : Int32 ) : Int32
			fun bson_append_bool( b : Pointer(BSON), name : UInt8*, v : Int32 ) : Int32
			fun bson_append_null( b : Pointer(BSON), name : UInt8* ) : Int32
			fun bson_append_double( b : Pointer(BSON), name : UInt8*, d : Float64 ) : Int32
			fun bson_append_long( b : Pointer(BSON), name : UInt8*, i : Int64 ) : Int32
			fun bson_append_string( b : Pointer(BSON), name : UInt8*, str : UInt8* ) : Int32
			fun bson_append_bson( b : Pointer(BSON), name : UInt8*, b2 : Pointer(BSON) ) : Int32
			fun bson_append_start_object( b : Pointer(BSON), name : UInt8* ) : Int32
			fun bson_append_finish_object( b : Pointer(BSON) ) : Int32
			fun bson_append_start_array( b : Pointer(BSON), bane : UInt8* ) : Int32
			fun bson_append_finish_array( b : Pointer(BSON) ) : Int32
			fun bson_data( b : Pointer(BSON) ) : UInt8*
			fun bson_data2( b : Pointer(BSON), size : Pointer(Int32) ) : UInt8*
			fun bson_finish( b : Pointer(BSON) ) : Int32
			fun json2bson( jsonstr : UInt8* ) : Pointer(BSON)
			fun bson_free( ptr : Pointer(Void) ) : Void
			fun bson_print_raw( b : Pointer(BSON), depth : Int32 ) : Void

			fun bson_iterator_init( i : Pointer(Iterator), b : Pointer(BSON) ) : Void
			fun bson_iterator_more( i : Pointer(Iterator) ) : Int32
			fun bson_iterator_next( i : Pointer(Iterator) ) : Type
			fun bson_iterator_type( i : Pointer(Iterator) ) : Type
			fun bson_iterator_from_buffer( i : Pointer(Iterator), buffer : UInt8* ) : Void
			fun bson_iterator_key( i : Pointer(Iterator) ) : UInt8*
			fun bson_iterator_string( i : Pointer(Iterator) ) : UInt8*
			fun bson_iterator_oid( i : Pointer(Iterator) ) : Pointer(OID)
			fun bson_iterator_int( i : Pointer(Iterator) ) : Int32
			fun bson_iterator_subobject( i : Pointer(Iterator), sub : Pointer(BSON) ) : Void
			fun bson_oid_to_string( oid : Pointer(OID), buffer : UInt8* ) : Void
		end

		def initialize( query = false )
			@b = Library::BSON.new()
			if !query
				Library.bson_init(pointerof(@b))
			else
				Library.bson_init_as_query(pointerof(@b))
			end
		end
		def finalize()
			Library.bson_destroy(pointerof(@b))
		end
		def append( k : String, v : Nil )
			Library.bson_append_null( pointerof(@b), k )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : Bool )
			Library.bson_append_bool( pointerof(@b), k, v )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : Float64 )
			Library.bson_append_double( pointerof(@b), k, v )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : Int32 )
			Library.bson_append_int( pointerof(@b), k, v )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : Int64 )
			Library.bson_append_long( pointerof(@b), k, v )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : String )
			Library.bson_append_string( pointerof(@b), k, v )
			raise "Error building hash #{@b.err == Library::Validity::VALID}: #{@b.errstr}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, v : JSON::Any )
			append( k, v.raw )
		end
		def append( k : String, a : Array(JSON::Any) )
			Library.bson_append_start_array( pointerof(@b), k )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
			a.each {|i| append("",i.raw) }
			Library.bson_append_finish_array( pointerof(@b) )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, h : Hash(String,JSON::Any) )
			Library.bson_append_start_object( pointerof(@b), k )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
			h.each {|k,v| append(k,v.raw) }
			Library.bson_append_finish_object( pointerof(@b) )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append( k : String, a : Array(String) )
			Library.bson_append_start_array( pointerof(@b), k )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
			a.each {|i| append("",i) }
			Library.bson_append_finish_array( pointerof(@b) )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def append_hash( hash )
			hash.each {|k,v| append( k, v ) }
			Library.bson_finish( pointerof(@b) )
			raise "Error building hash #{@b.err}" if @b.err != Library::Validity::VALID
		end
		def to_s()
			size : Int32 = 0
			bytes = Library.bson_data2(pointerof(@b),pointerof(size))
			String.new(bytes,size)
		end
		def self.hash_from_data( data : UInt8* )
			i = uninitialized Library::Iterator
			Library.bson_iterator_from_buffer( pointerof(i), data )
			hash_from_iterator(i)
		end
		def self.get_iterator_next( ip : Pointer(Library::Iterator) )
			case type=Library.bson_iterator_next(ip)
				when Library::Type::INT
					JSON::Any.new(Library.bson_iterator_int(ip).to_i64)
				when Library::Type::STRING
					JSON::Any.new(String.new(Library.bson_iterator_string( ip )))
				when Library::Type::ARRAY
					sub = Library::BSON.new()
					Library.bson_iterator_subobject( ip, pointerof(sub) )
					it = uninitialized Library::Iterator
					Library.bson_iterator_init( pointerof(it), pointerof(sub) )
					JSON::Any.new(array_from_iterator(it))
				when Library::Type::OID
					buffer = StaticArray(UInt8,50).new(0)
					oid = Library.bson_iterator_oid( ip )
					Library.bson_oid_to_string( oid, buffer.to_unsafe )
					JSON::Any.new(String.new(buffer.to_unsafe))
				when Library::Type::EOO,Library::Type::NULL
					return JSON::Any.new(nil)
				else
					raise "Unhandled type #{type}"
			end
		end
		def self.array_from_iterator( i : Library::Iterator )
			ip = pointerof(i)
			a = Array(JSON::Any).new
			while( Library.bson_iterator_more(ip) != 0 )
				v = self.get_iterator_next( ip )
				if( Library.bson_iterator_type(ip) != Library::Type::EOO )
					a.push(v)
				end
			end
			return a
		end
		def self.hash_from_iterator( i : Library::Iterator )
			ip = pointerof(i)
			h = ::Hash(String,JSON::Any).new
			while( Library.bson_iterator_more(ip) != 0 )
				v = self.get_iterator_next( ip )
				k = String.new(Library.bson_iterator_key( ip ) )
				if( Library.bson_iterator_type(ip) != Library::Type::EOO )
					h[k] = v
				end
			end
			return h
		end
		def ptr()
			pointerof(@b)
		end

		def self.from_hash( hash )
			b = BSON.new()
			b.append_hash(hash)
			return b
		end
		def self.query_from_hash( hash )
			b = BSON.new( true )
			b.append_hash(hash)
			return b
		end
		def self.from_json( json : String )
			b = Library.json2bson( json )
			ptr[0] = b[0]
			Library.bson_free(b)
		end
	end

	@[Link("ejdb")]
	lib Library
		type Bool = Int32
		struct EJDB
			dummy : UInt8
		end
		struct EJCOLL
			dummy : UInt8
		end
		struct EJQ
			dummy : UInt8
		end
		struct EJCOLLOPTS
			large : Bool
			compressed : Bool
			records : Int64
			cachedrecords : Int32
		end
		type EJQRESULT = Pointer(TokyoCabinet::Library::TCLIST)

		fun ejdbnew() : Pointer(EJDB)
		fun ejdbdel( jb : Pointer(EJDB) ) : Void
		fun ejdbecode( jb : Pointer(EJDB) ) : Int32
		fun ejdberrmsg( ecode : Int32 ) : UInt8*
		fun ejdbclose( jb : Pointer(EJDB) ) : Bool
		fun ejdbcreatecoll( jb : Pointer(EJDB), colname : Pointer(UInt8), opts : Pointer(EJCOLLOPTS) ) : Pointer(EJCOLL)

		fun ejdbopen( jb : Pointer(EJDB), path : UInt8*, mode : Int32 ) : Bool
		fun ejdbsavebson( jb : Pointer(EJCOLL), bs : Pointer(BSON::Library::BSON), oid : Pointer(BSON::Library::OID) ) : Bool
		fun ejdbcreatecoll( jb : Pointer(EJDB), colname : UInt8*, opts : Pointer(EJCOLLOPTS) ) : Pointer(EJCOLL)
		fun ejdbsyncoll( jcoll : Pointer(EJCOLL) ) : Bool

		fun ejdbcreatequery( jb : Pointer(EJDB), qobj : Pointer(BSON::Library::BSON), orqobj : Pointer(BSON::Library::BSON), 
			num : Int32, hints : Pointer(BSON::Library::BSON) ) : Pointer(EJQ)
		fun ejdbqryexecute( jcoll : Pointer(EJCOLL), q : Pointer(EJQ), count : Pointer(UInt32), qflags : Int32, 
			log : Pointer(TokyoCabinet::Library::TCXSTR) ) : Library::EJQRESULT
	end

	JBOREADER = 1<<0
	JBOWRITER = 1<<1
	JBOCREAT = 1<<2
	JBOTRUNC = 1<<3
	JBONOLCK = 1<<4
	JBOLCKNB = 1<<5
	JBOTSYNC = 1<<6
	DEFAULT_OPEN_MODE = JBOREADER | JBOWRITER | JBOCREAT

	class DB
		def initialize( filename : String, mode : Int32 )
			@ptr = Library.ejdbnew()
			@cols = {} of String => Pointer(Library::EJCOLL)
			raise Errno.new("Unable to open file") if !@ptr
			Library.ejdbopen( @ptr, filename, mode )
		end
		def finalize()
			Library.ejdbclose(@ptr) if @ptr
		end
		def close()
			Library.ejdbclose(@ptr) if @ptr
			@ptr = nil
		end
		def save( collection : String, *objs )
			col = @cols[collection] ||= Library.ejdbcreatecoll( @ptr, collection, nil )

			objs.each {|obj|
				# Remove the _id field if it is empty, as it will fail if the record doesn't alreay exist
				obj.delete("_id") if obj.has_key?("_id") && obj["_id"] == ""

				# Turn the object into BSON
				b = EJDB::BSON.from_hash( obj )

				# Save the document and get the oid of the resulting record
				oid = uninitialized BSON::Library::OID
				Library.ejdbsavebson( col, b.ptr, pointerof(oid) )

				# Convert the oid into a string representation
				buffer = uninitialized StaticArray(UInt8,50)
				BSON::Library.bson_oid_to_string( pointerof(oid), buffer.to_unsafe )
				oid_s = String.new( buffer.to_unsafe )

				# Pack the oid into the _id field
				if obj.is_a? Hash(String,JSON::Any)
					obj["_id"] = JSON::Any.new(oid_s)
				else
					obj["_id"] = oid_s
				end
			}
			Library.ejdbsyncoll(col)
			nil
		end
		def find( collection : String, query, hints = nil )
			# Open the collection
			col = @cols[collection] ||= Library.ejdbcreatecoll( @ptr, collection, nil )

			# Convert query hash into BSON
			qh = EJDB::BSON.query_from_hash(query)

			# Create the query
			if hints.nil?
				q = Library.ejdbcreatequery( @ptr, qh.ptr, nil, 0, nil )
			else
				hint = EJDB::BSON.query_from_hash(hints)
				q = Library.ejdbcreatequery( @ptr, qh.ptr, nil, 0, hint.ptr )
			end

			# Execute the query
			count = uninitialized UInt32
			res = Library.ejdbqryexecute( col, q, pointerof(count), 0, nil )

			# Process the results into an array of hash objects
			(0...res[0].num).map {|i| BSON.hash_from_data(res[0].array[i].ptr) }
		end
	end

	def self.open( filename : String, mode : Int32 )
		DB.new(filename,mode)
	end
end

