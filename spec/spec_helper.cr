require "spec"
require "../src/discordcr"

def load_json(filename)
  File.read("spec/json/#{filename}.json")
end
