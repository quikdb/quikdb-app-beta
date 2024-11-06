import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Time "mo:base/Time";

module {
    // Type definitions
    public type Transaction = {
        userId: Principal;
        amount: Nat;
        timestamp: Int;
        transactionType: Text; // "credit" or "debit"
    };

    public func addCredits(
        userId: Principal, 
        amount: Nat, 
        userCredits: HashMap.HashMap<Principal, Nat>,
        transactions: [Transaction]
    ) :  async Result.Result<[Transaction], Text> {
        let currentBalance = switch (userCredits.get(userId)) {
            case (null) { 0 };
            case (?balance) { balance };
        };
        
        userCredits.put(userId, currentBalance + amount);
        // Record transaction
        let newTransaction = {
            userId = userId;
            amount = amount;
            timestamp = Time.now();
            transactionType = "credit";
        };
       let newTransactions = Array.append(transactions, [newTransaction]);
        #ok(newTransactions)
        
    };

    public func getCreditBalance(
        userId: Principal,
        userCredits: HashMap.HashMap<Principal, Nat>
    ) : async Result.Result<Nat, Text> {
        switch (userCredits.get(userId)) {
            case (null) { #ok(0) };
            case (?balance) { #ok(balance) };
        }
    };

    public func deductCredits(
        userId: Principal, 
        amount: Nat,
        userCredits: HashMap.HashMap<Principal, Nat>,
        transactions: [Transaction]
    ) :  async Result.Result<[Transaction], Text>{
        let currentBalance = switch (userCredits.get(userId)) {
            case (null) { return #err("User has no credits") };
            case (?balance) { balance };
        };

        if (currentBalance < amount) {
            return #err("Insufficient balance");
        };

        userCredits.put(userId, currentBalance - amount);
        // Record transaction
        let newTransaction = {
            userId = userId;
            amount = amount;
            timestamp = Time.now();
            transactionType = "debit";
        };
        let newTransactions = Array.append(transactions, [newTransaction]);
        #ok(newTransactions) 


    };

    public func getTransactionHistory(
        userId: Principal,
        transactions: [Transaction]
    ) : async Result.Result<[Transaction], Text> {
        let userTransactions = Array.filter<Transaction>(
            transactions,
            func(tx: Transaction) : Bool { Principal.equal(tx.userId, userId) }
        );
        #ok(userTransactions)
    };
}