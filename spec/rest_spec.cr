require "./spec_helper"

describe Discord::REST do
  client = Discord::Client.new(token: "Bot token")

  describe "#encode_tuple" do
    it "doesn't emit null values" do
      client = Discord::Client.new("foo", 0_u64)
      client.encode_tuple(foo: ["bar", 1, 2], baz: nil).should eq(%({"foo":["bar",1,2]}))
    end
  end

  {% if flag?(:mock_server) %}
    describe "#request" do
      context "successful request" do
        it "returns the HTTP::Response" do
          Discord::MockServer.prepare_endpoint("GET", "/success", 200,
            {"Content-Type" => "text/plain"}, "OK")
          response = client.request(:success, nil, "GET", "/success", HTTP::Headers.new, nil)
          response.should be_a HTTP::Client::Response
        end
      end

      context "unsuccessful request" do
        it "raises StatusException when not application/json" do
          Discord::MockServer.prepare_endpoint("GET", "/fail", 400,
            {"Content-Type" => "text/plain"}, "400 Bad Request")
          expect_raises(Discord::StatusException, "400 Bad Request") do
            client.request(:fail, nil, "GET", "/fail", HTTP::Headers.new, nil)
          end
        end

        it "tries to parse API error, or falls back to StatusException" do
          Discord::MockServer.prepare_endpoint("GET", "/fail", 400,
            {"Content-Type" => "application/json"}, %({"code": 1, "message": "test"}))
          expect_raises(Discord::CodeException, "400 Bad Request: Code 1 - test") do
            client.request(:fail, nil, "GET", "/fail", HTTP::Headers.new, nil)
          end

          Discord::MockServer.prepare_endpoint("GET", "/fail", 400,
            {"Content-Type" => "application/json"}, %(invalid json))
          expect_raises(Discord::StatusException, "400 Bad Request") do
            client.request(:fail, nil, "GET", "/fail", HTTP::Headers.new, nil)
          end
        end
      end
    end

    it "#get_gateway" do
      expected = Discord::REST::GatewayResponse.from_json load_json("gateway_response")
      Discord::MockServer.prepare_endpoint("GET", "/gateway", 200,
        {"Content-Type" => "application/json"}, expected.to_json)
      client.get_gateway.should eq expected
    end

    it "#get_gateway_bot" do
      expected = Discord::REST::GatewayBotResponse.from_json load_json("gateway_bot_response")
      Discord::MockServer.prepare_endpoint("GET", "/gateway/bot", 200,
        {"Content-Type" => "application/json"}, expected.to_json)
      client.get_gateway_bot.should eq expected
    end

    it "#get_oauth2_application" do
      expected = Discord::OAuth2Application.from_json load_json("oauth2_application")
      Discord::MockServer.prepare_endpoint("GET", "/oauth2/applications/@me", 200,
        {"Content-Type" => "application/json"}, expected.to_json)
      client.get_oauth2_application.should eq expected
    end

    it "#create_message" do
      expected = Discord::Message.from_json load_json("message")
      Discord::MockServer.prepare_endpoint("POST", "/channels/1/messages", 200,
        {"Content-Type" => "application/json"}, expected.to_json)
      client.create_message(1, "foo").should eq expected
    end

    it "#delete_message" do
      Discord::MockServer.prepare_endpoint(
        "DELETE", "/channels/1/messages/2", 204, nil, "")
      client.delete_message(1, 2)
    end
  {% end %}
end
