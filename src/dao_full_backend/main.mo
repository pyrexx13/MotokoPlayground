import Account "account";
import Array "mo:base/Array";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Http "http";

actor class DAO() {

    // To implement the voting logic in this level you need to make use of the code implemented in previous levels.
    // That's why we bring back the code of the previous levels here.

    // For the logic of this level we need to bring back all the previous levels

    ///////////////
    // LEVEL #1 //
    /////////////

    let name : Text = "Motoko Bootcamp DAO";
    var manifesto : Text = "Empower the next wave of builders to make the Web3 revolution a reality";

    let goals : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);

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
        return;
    };

    public shared query func getGoals() : async [Text] {
        return Buffer.toArray(goals);
    };

    ///////////////
    // LEVEL #2 //
    /////////////

    public type Member = {
        name : Text;
        age : Nat;
    };
    public type Result<A, B> = Result.Result<A, B>;
    public type HashMap<A, B> = HashMap.HashMap<A, B>;

    let dao : HashMap.HashMap<Principal, Member> = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(memberCandidate : Member) : async Result<(), Text> {
        //Implement the addMember function, this function takes a member of type Member as a parameter, adds a new member to the members HashMap. The function should check if the caller is already a member. If that's the case use a Result type to return an error message.;
        switch(dao.get(caller)) {
            case(null){
                dao.put(caller, memberCandidate);
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
        switch(dao.get(p)) {
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
        switch(dao.get(caller)) {
            case(null){
               return #err("No dreamer by this name exists:" # memberInfo.name # ". You need to register as a member first.");
            };
            case(? member){
                dao.put(caller, memberInfo);
                return #ok;
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        //Implement the getAllMembers query function, this function takes no parameters and returns all the members of your DAO as an array of type [Member].
        return Iter.toArray(dao.vals());
    };

    public query func getAllPrincipals() : async [Principal] {
        return Iter.toArray(dao.keys());
    };

    public query func getAllEntries() : async [(Principal, Member)] {
        return Iter.toArray(dao.entries());
    };

    public query func numberOfMembers() : async Nat {
        //Implement the numberOfMembers query function, this function takes no parameters and returns the number of members of your DAO as a Nat.
        return dao.size();
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
        //Implement the removeMember function, this function takes no parameter and removes the member associated with the caller. If there is no member associated with the caller, return an error message. You will use a Result type for your return value.
        switch(dao.get(caller)) {
            case(null){
               return #err("No dreamer by this name exists. You need to register as a member first.");
            };
            case(? member){
                dao.delete(caller);
                return #ok;
            };
        };
    };


    ///////////////
    // LEVEL #3 //
    /////////////

    public type Subaccount = Blob;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    let nameToken = "Motoko Bootcamp Token";
    let symbolToken = "MBT";

    let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap(Account.accountsEqual, Account.accountsHash);

    public query func tokenName() : async Text {
        return nameToken;
    };

    public query func tokenSymbol() : async Text {
        return symbolToken;
    };

    public func mint(owner : Principal, amount : Nat) : async () {
        let defaultAccount = { owner = owner; subaccount = null };
        switch (ledger.get(defaultAccount)) {
            case (null) {
                ledger.put(defaultAccount, amount);
            };
            case (?some) {
                ledger.put(defaultAccount, some + amount);
            };
        };
        return;
    };

    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {
        let fromBalance = switch (ledger.get(from)) {
            case (null) { 0 };
            case (?some) { some };
        };
        if (fromBalance < amount) {
            return #err("Not enough balance");
        };
        let toBalance = switch (ledger.get(to)) {
            case (null) { 0 };
            case (?some) { some };
        };
        ledger.put(from, fromBalance - amount);
        ledger.put(to, toBalance + amount);
        return #ok();
    };

    public query func balanceOf(account : Account) : async Nat {
        return switch (ledger.get(account)) {
            case (null) { 0 };
            case (?some) { some };
        };
    };

    func _balanceOf(account : Account) : Nat {
        return switch (ledger.get(account)) {
            case (null) { 0 };
            case (?some) { some };
        };
    };

    public query func totalSupply() : async Nat {
        var total = 0;
        for (balance in ledger.vals()) {
            total += balance;
        };
        return total;
    };

    // burn the specified amount from the defaultAccount of the specified principal
    // @trap if the defaultAccount has less token than the burned Amount
    func _burnTokens(caller : Principal, burnAmount : Nat) {
        let defaultAccount = { owner = caller; subaccount = null };
        switch (ledger.get(defaultAccount)) {
            case (null) { return };
            case (?some) { ledger.put(defaultAccount, some - burnAmount) };
        };
    };





    ///////////////
    // LEVEL #4 //
    /////////////

    public type Status = {
        #Open;
        #Accepted;
        #Rejected;
    };

    public type Proposal = {
        id : Nat;
        status : Status;
        manifest : Text;
        votes : Int;
        voters : [Principal];
    };

    public type CreateProposalOk = Nat;

    public type CreateProposalErr = {
        #NotDAOMember;
        #NotEnoughTokens;
    };

    public type CreateProposalResult = Result<CreateProposalOk, CreateProposalErr>;

    public type VoteOk = {
        #ProposalAccepted;
        #ProposalRefused;
        #ProposalOpen;
    };

    public type VoteErr = {
        #NotDAOMember;
        #ProposalNotFound;
        #NotEnoughTokens;
        #AlreadyVoted;
        #ProposalEnded;
    };

    public type voteResult = Result<VoteOk, VoteErr>;

    var nextProposalId : Nat = 0;
    let proposals = TrieMap.TrieMap<Nat, Proposal>(Nat.equal, Hash.hash);

    // Returns a boolean indicating if the specified principal is a member of our DAO.
    func _isMemberDAO(p : Principal) : Bool {
        switch (dao.get(p)) {
            case (null) {
                return false;
            };
            case (?member) {
                return true;
            };
        };
    };

    // Returns a boolean indicating if the specified principal has n or more token.
    func _hasEnoughToken(p : Principal, n : Nat) : Bool {
        let defaultAccount : Account = {
            owner = p;
            subaccount = null;
        };
        let balance = _balanceOf(defaultAccount);
        if (n >= balance) {
            return false;
        };
        return true;
    };

    public shared ({ caller }) func createProposal(manifest : Text) : async CreateProposalResult {
        // Check that the caller is a member
        if (not (_isMemberDAO(caller))) {
            return #err(#NotDAOMember);
        };
        // Check that the call has enough token
        if (not (_hasEnoughToken(caller, 1))) {
            return #err(#NotEnoughTokens);
        };
        let currentId = nextProposalId;
        let proposal : Proposal = {
            id = currentId;
            status = #Open;
            manifest;
            votes = 0;
            voters = [];
        };
        proposals.put(currentId, proposal);
        _burnTokens(caller, 1);
        nextProposalId += 1;
        return #ok(currentId);
    };

    public query func getProposal(id : Nat) : async ?Proposal {
        return proposals.get(id);
    };

    public query func getAllProposals() : async [Proposal] {
                 return Iter.toArray(proposals.vals());
   };

    func _isProposalOpen(proposal : Proposal) : Bool {
        switch (proposal.status) {
            case (#Open) {
                return true;
            };
            case (_) {
                return false;
            };
        };
    };

    func _hasAlreadyVoted(p : Principal, proposal : Proposal) : Bool {
        for (voter in proposal.voters.vals()) {
            if (voter == p) {
                return true;
            };
        };
        return false;
    };
    
    public shared ({ caller }) func vote(id : Nat, vote : Bool) : async voteResult {
        // Check that the caller is a member
        if (not (_isMemberDAO(caller))) {
            return #err(#NotDAOMember);
        };
        // Check that the caller has enough token
        if (not (_hasEnoughToken(caller, 1))) {
            return #err(#NotEnoughTokens);
        };
        switch (proposals.get(id)) {
            case (null) {
                return #err(#ProposalNotFound);
            };
            case (?proposal) {
                if (not (_isProposalOpen(proposal))) {
                    return #err(#ProposalEnded);
                };
                if (_hasAlreadyVoted(caller, proposal)) {
                    return #err(#AlreadyVoted);
                };

                let newVotes = switch (vote) {
                    case (true) {
                        proposal.votes + 1;
                    };
                    case (false) {
                        proposal.votes - 1;
                    };
                };

                let newStatus = switch (newVotes) {
                    case (10) {
                        #Accepted;
                    };
                    case (-10) {
                        #Rejected;
                    };
                    case (_) {
                        #Open;
                    };
                };

                let newVoters = Array.append<Principal>(proposal.voters, [caller]);

                let newProposal : Proposal = {
                    id = proposal.id;
                    status = newStatus;
                    manifest = proposal.manifest;
                    votes = newVotes;
                    voters = newVoters;
                };

                proposals.put(proposal.id, newProposal);

                let returnValue = switch (newStatus) {
                    case (#Open) {
                        #ProposalOpen;
                    };
                    case (#Accepted) {
                        #ProposalAccepted;
                    };
                    case (#Rejected) {
                        #ProposalRefused;
                    };
                };
                return #ok(returnValue);
            };
        };
    };

///////////////
    // LEVEL #5 //
    /////////////

    let logo : Text = "<path xmlns='http://www.w3.org/2000/svg' d='M192 104.8c0-9.2-5.8-17.3-13.2-22.8C167.2 73.3 160 61.3 160 48c0-26.5 28.7-48 64-48s64 21.5 64 48c0 13.3-7.2 25.3-18.8 34c-7.4 5.5-13.2 13.6-13.2 22.8c0 12.8 10.4 23.2 23.2 23.2H336c26.5 0 48 21.5 48 48v56.8c0 12.8 10.4 23.2 23.2 23.2c9.2 0 17.3-5.8 22.8-13.2c8.7-11.6 20.7-18.8 34-18.8c26.5 0 48 28.7 48 64s-21.5 64-48 64c-13.3 0-25.3-7.2-34-18.8c-5.5-7.4-13.6-13.2-22.8-13.2c-12.8 0-23.2 10.4-23.2 23.2V464c0 26.5-21.5 48-48 48H279.2c-12.8 0-23.2-10.4-23.2-23.2c0-9.2 5.8-17.3 13.2-22.8c11.6-8.7 18.8-20.7 18.8-34c0-26.5-28.7-48-64-48s-64 21.5-64 48c0 13.3 7.2 25.3 18.8 34c7.4 5.5 13.2 13.6 13.2 22.8c0 12.8-10.4 23.2-23.2 23.2H48c-26.5 0-48-21.5-48-48V343.2C0 330.4 10.4 320 23.2 320c9.2 0 17.3 5.8 22.8 13.2C54.7 344.8 66.7 352 80 352c26.5 0 48-28.7 48-64s-21.5-64-48-64c-13.3 0-25.3 7.2-34 18.8C40.5 250.2 32.4 256 23.2 256C10.4 256 0 245.6 0 232.8V176c0-26.5 21.5-48 48-48H168.8c12.8 0 23.2-10.4 23.2-23.2z'/>";
 

    func _getWebpage() : Text {
        var webpage = "<style>" #
        "body { text-align: center; font-family: Arial, sans-serif; background-color: #f0f8ff; color: #333; }" #
        "h1 { font-size: 3em; margin-bottom: 10px; }" #
        "hr { margin-top: 20px; margin-bottom: 20px; }" #
        "em { font-style: italic; display: block; margin-bottom: 20px; }" #
        "ul { list-style-type: none; padding: 0; }" #
        "li { margin: 10px 0; }" #
        "li:before { content: '👉 '; }" #
        "svg { max-width: 150px; height: auto; display: block; margin: 20px auto; }" #
        "h2 { text-decoration: underline; }" #
        "</style>";

        webpage := webpage # "<div><h1>" # name # "</h1></div>";
        webpage := webpage # "<em>" # manifesto # "</em>";
        webpage := webpage # "<div>" # logo # "</div>";
        webpage := webpage # "<hr>";
        webpage := webpage # "<h2>Our goals:</h2>";
        webpage := webpage # "<ul>";
        for (goal in goals.vals()) {
            webpage := webpage # "<li>" # goal # "</li>";
        };
        webpage := webpage # "</ul>";
        return webpage;
    };

    public type DAOStats = {
        name : Text;
        manifesto : Text;
        goals : [Text];
        member : [Text];
        logo : Text;
        numberOfMembers : Nat;
    };
    public type HttpRequest = Http.Request;
    public type HttpResponse = Http.Response;

    public query func http_request(request : HttpRequest) : async HttpResponse {
        return ({
            status_code = 200;
            headers = [("Content-Type", "text/html; charset=UTF-8")];
            body = Text.encodeUtf8(_getWebpage());
            streaming_strategy = null;
        });
     
    };

    func _getMemberName (member : Member) : Text {
        return member.name;
    };

    public query func getStats() : async DAOStats {
    
        return ({
            name;
            manifesto;
            goals = Buffer.toArray(goals);
            member = Iter.toArray(Iter.map(dao.vals(), _getMemberName));      
            logo;
            numberOfMembers = dao.size();
        });
    };

};