require "spec_helper"

describe Hash do

  describe "to_soap_xml" do
    describe "returns SOAP request compatible XML" do
      it "for a simple Hash" do
        { :some => "user" }.to_soap_xml.should == "<some>user</some>"
      end

      it "for a nested Hash" do
        { :some => { :new => "user" } }.to_soap_xml.
          should == "<some><new>user</new></some>"
      end

      it "for a Hash with multiple keys" do
        soap_xml = { :all => "users", :before => "whatever" }.to_soap_xml

        soap_xml.should include "<all>users</all>"
        soap_xml.should include "<before>whatever</before>"
      end

      it "for a Hash containing an Array" do
        { :some => ["user", "gorilla"] }.to_soap_xml.
          should == "<some>user</some><some>gorilla</some>"
      end

      it "for a Hash containing an Array of Hashes" do
        { :some => [{ :new => "user" }, { :old => "gorilla" }] }.to_soap_xml.
          should == "<some><new>user</new></some><some><old>gorilla</old></some>"
      end
    end

    it "converts Hash key Symbols to lowerCamelCase" do
      { :find_or_create => "user" }.to_soap_xml.
        should == "<findOrCreate>user</findOrCreate>"
    end

    it "does not convert Hash key Strings" do
      { "find_or_create" => "user" }.to_soap_xml.
        should == "<find_or_create>user</find_or_create>"
    end

    it "converts DateTime objects to xs:dateTime compliant Strings" do
      { :before => UserFixture.datetime_object }.to_soap_xml.
        should == "<before>" << UserFixture.datetime_string << "</before>"
    end

    it "converts Objects responding to to_datetime to xs:dateTime compliant Strings" do
      singleton = Object.new
      def singleton.to_datetime
        UserFixture.datetime_object
      end

      { :before => singleton }.to_soap_xml.
        should == "<before>" << UserFixture.datetime_string << "</before>"
    end

    it "calls to_s on Strings even if they respond to to_datetime" do
      singleton = "gorilla"
      def singleton.to_datetime
        UserFixture.datetime_object
      end

      { :name => singleton }.to_soap_xml.should == "<name>gorilla</name>"
    end

    it "call to_s on any other Object" do
      [666, true, false, nil].each do |object|
        { :some => object }.to_soap_xml.should == "<some>#{object}</some>"
      end
    end
  end

  describe "map_soap_response" do
    it "needs specs"
  end

end