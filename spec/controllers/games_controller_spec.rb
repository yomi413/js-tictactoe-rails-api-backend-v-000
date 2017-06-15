require "rails_helper"

RSpec.describe GamesController, :type => :controller do
  before(:each) do
    Game.destroy_all
  end

  describe "#create" do
    it "can create a new Game instance" do
      post :create, {
        :state => ["X", "", "", "", "", "", "", "", ""]
      }

      expect(Game.count).to eq(1)
    end

    it "properly serializes the 'state' attribute as an array instead of as a string" do
      post :create, {
        :state => ["X", "", "", "", "", "", "", "", ""]
      }

      expect(Game.last.state).to eq ["X", "", "", "", "", "", "", "", ""]
    end
  end

  describe "#show" do
    it "returns a JSON:API-compliant, serialized object representing the specified Game instance" do
      Game.create(:state => ["", "", "", "", "", "O", "", "", "X"])

      get :show, id: Game.last.id
      returned_json = response.body
      parsed_json = JSON.parse(returned_json)

      correctly_serialized_json = {
        "data" => {
          "id" => Game.last.id.to_s,
          "type" => "games",
          "attributes" => {
            "state" => ["", "", "", "", "", "O", "", "", "X"]
          }
        }
      }

      expect(parsed_json).to eq(correctly_serialized_json)
    end
  end

  describe "#update" do
    it "persists changes to a previously-saved game's state (as players make additional moves)" do
      Game.create(:state => ["X", "", "", "", "", "", "", "", ""])

      patch :update, {
        :id => Game.last.id,
        :state => ["X", "O", "", "", "", "", "", "", ""]
      }

      expect(Game.last.state).to eq ["X", "O", "", "", "", "", "", "", ""]
    end
  end

  describe "#index" do
    it "returns a JSON:API-compliant, serialized object representing all of the saved games" do
      Game.create(:state => ["X", "O",  "", "", "", "", "", "", ""])
      Game.create(:state => ["X", "O", "X", "", "", "", "", "", ""])

      get :index
      returned_json = response.body
      parsed_json = JSON.parse(returned_json)

      correctly_serialized_json = {
        "data" => [
          {
            "id" => (Game.last.id - 1).to_s,
            "type" => "games",
            "attributes" => {
              "state" => ["X", "O",  "", "", "", "", "", "", ""]
            }
          },
          {
            "id" => Game.last.id.to_s,
            "type" => "games",
            "attributes" => {
              "state" => ["X", "O", "X", "", "", "", "", "", ""]
            }
          }
        ]
      }

      expect(parsed_json).to eq(correctly_serialized_json)
    end
  end
end
