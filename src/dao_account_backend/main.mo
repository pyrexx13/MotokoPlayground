import Account "account";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Option "mo:base/Option";



actor class DAO()  {

    // For this level make sure to use the helpers function in Account.mo
    public type Subaccount = Blob;
    public type Result<A,B> = Result.Result<A,B>;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
    let NAME : Text = "Dream Token";
    let SYMBOL : Text = "SUN";

    public query func tokenName() : async Text {
        return NAME;
    };

    public query func tokenSymbol() : async Text {
        return SYMBOL;
    };

    public func mint(owner : Principal, amount : Nat) : async () {
        let defaultAccount : Account ={
            owner = owner;
            subaccount = null;
        };
        switch(ledger.get(defaultAccount)){
            case(? oldAmount){
                ledger.put(defaultAccount, oldAmount + amount);
            };
            case(null){
                ledger.put(defaultAccount, amount);
            };

        };
        return;
    };

    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result<(), Text> {

        let fromBalance = Option.get<Nat>(ledger.get(from), 0);
        let toBalance = Option.get<Nat>(ledger.get(to), 0);

        if(fromBalance < amount){
            return #err("The sender does not have enough tokens to send.");
        };
            ledger.put(from, fromBalance - amount);
            ledger.put(to, toBalance + amount);
            return #ok();
 
    };
    
    public query func balanceOf(account : Account) : async Nat {
        return(Option.get<Nat>(ledger.get(account),0));
    };

    public query func totalSupply() : async Nat {
        var supply = 0;
        for(amount in ledger.vals()){
            supply := supply + amount;
        };
       return supply;
    };


};