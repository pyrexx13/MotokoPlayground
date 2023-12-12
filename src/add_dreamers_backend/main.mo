import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";

actor class DAO() = this {

    public type Member = {
        name : Text;
        age : Nat;
    };
    public type Result<A, B> = Result.Result<A, B>;
    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    let members : HashMap.HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(memberCandidate : Member) : async Result<(), Text> {
        //Implement the addMember function, this function takes a member of type Member as a parameter, adds a new member to the members HashMap. The function should check if the caller is already a member. If that's the case use a Result type to return an error message.;
        switch(members.get(caller)) {
            case(null){
                members.put(caller, memberCandidate);
                return #ok;
            };
            case(? memberCandidate){
                return #err("You already started dreaming" # memberCandidate.name);
            };
        };
    };

    public query func getMember(p : Principal) : async Result<Member, Text> {
        //Implement the getMember query function, this function takes a principal of type Principal as a parameter and returns the corresponding member. You will use a Result type for your return value.
       //if (p == null) {
        //    return #err("You submitted a ghost!");
       // }; 
        switch(members.get(p)) {
            case(null){
                #err("Your haven't started dreaming yet" # Principal.toText(p));
            };
            case(? memberCandidate){
                return #ok(memberCandidate);
            };
        }
    };

    public shared ({ caller }) func updateMember(memberInfo : Member) : async Result<(), Text> {
        //Implement the updateMember function, this function takes a member of type Member as a parameter and updates the corresponding member associated with the caller. If the member doesn't exist, return an error message. You will use a Result type for your return value.;
        switch(members.get(caller)) {
            case(null){
               return #err("No dreamer by this name exists:" # memberInfo.name # ". You need to register as a member first.");
            };
            case(? member){
                members.put(caller, memberInfo);
                return #ok;
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        //Implement the getAllMembers query function, this function takes no parameters and returns all the members of your DAO as an array of type [Member].
        return Iter.toArray(members.vals());
    };

    public query func getAllPrincipals() : async [Principal] {
        return Iter.toArray(members.keys());
    };

    public query func getAllEntries() : async [(Principal, Member)] {
        return Iter.toArray(members.entries());
    };

    public query func numberOfMembers() : async Nat {
        //Implement the numberOfMembers query function, this function takes no parameters and returns the number of members of your DAO as a Nat.
        return members.size();
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        //Implement the removeMember function, this function takes no parameter and removes the member associated with the caller. If there is no member associated with the caller, return an error message. You will use a Result type for your return value.
        switch(members.get(caller)) {
            case(null){
               return #err("No dreamer by this name exists. You need to register as a member first.");
            };
            case(? member){
                members.delete(caller);
                return #ok;
            };
        };
    };


};