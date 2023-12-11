import Buffer "mo:base/Buffer";

actor class DAO() {


//How do you want to live your life?
//What’s your idea (doesn't matter if it's small or big)?
//What do you want to achieve?
//What's your vision for the future?
let name: Text = "Osah";
var manifesto: Text = "Free all individuals from the influence of others and align them with power of unique self.";
var goals: Buffer<Text>;

    public shared query func getName() : async Text {
        return name;
    };

    public shared query func getManifesto() : async Text {
        return manifesto;
    };

    public func setManifesto(newManifesto : Text) : async () {
        manifesto := newManifesto;
        return;
    };

    public func addGoal(newGoal : Text) : async () {
        goals.add(newGoal);
        )
        return;
    };

    public shared query func getGoals() : async [Text] {
        return Buffer.toArray(goals);
    };
};