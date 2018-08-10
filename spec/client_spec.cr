require "./spec_helper"

describe Discord::Client do
  {% if flag?(:mock_server) %}
    describe "#client_id" do
      Discord::MockServer.prepare_endpoint("GET", "/oauth2/applications/@me", 200,
        {"Content-Type" => "application/json"}, load_json("oauth2_application"))

      it "returns constructed client_id" do
        client_with_id = Discord::Client.new token: "token", client_id: 2
        client_with_id.client_id.should eq 2_u64
      end

      it "fetches client id if not set" do
        client = Discord::Client.new token: "token", client_id: nil
        client.client_id.should eq 1_u64
      end
    end
  {% end %}
end
