import OrganizationManagement "org.mod";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Incentives "incentives.mod";

// Main actor
actor {
  // Define ResultType for error handling
type ResultType = Result.Result<Nat, Text>;
    // Types and data structures
    public type Organization = {
        id: Nat;
        details: Blob;
        owner: Principal;
        members: [(Principal, Text)]; // (userId, role)
        projects: [Nat];
    };

     // Create stable storage for credits and transactions
    private let userCredits = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    private let transactions : [Incentives.Transaction] = [];

    // Example of using two functions from the Incentives module
    public shared(msg) func addUserCredits(amount: Nat) : async Result.Result<(), Text> {
        let userId = msg.caller;
        await Incentives.addCredits(userId, amount, userCredits, transactions)
    };

    public shared(msg) func checkMyBalance() : async Result.Result<Nat, Text> {
        let userId = msg.caller;
        await Incentives.getCreditBalance(userId, userCredits)
    };
    // Exported variables
    private stable var nextOrgId = 0;
    private stable var nextProjectId = 0;
    

    // Add these stable variables for upgrade persistence
    private stable var organizationsEntries : [(Nat, Organization)] = [];
    private stable var userOrgsEntries : [(Principal, [Nat])] = [];
       // Helper function moved inside the actor
     func customNatHash(n: Nat): Hash.Hash {
        let text = Nat.toText(n);
        return Text.hash(text);
    };
    // Change HashMap declarations to be non-stable
    private var organizations = HashMap.HashMap<Nat, Organization>(0, Nat.equal, customNatHash);
    private var userOrgs = HashMap.HashMap<Principal, [Nat]>(0, Principal.equal, Principal.hash);

    // Add system functions for upgrades
    system func preupgrade() {
        organizationsEntries := Iter.toArray(organizations.entries());
        userOrgsEntries := Iter.toArray(userOrgs.entries());
    };

    system func postupgrade() {
        organizations := HashMap.fromIter<Nat, Organization>(organizationsEntries.vals(), 0, Nat.equal, customNatHash);
        userOrgs := HashMap.fromIter<Principal, [Nat]>(userOrgsEntries.vals(), 0, Principal.equal, Principal.hash);
    };
   

// Add this near the top of the actor block
private let orgManager = OrganizationManagement.OrganizationManager();

public shared ({ caller }) func createOrganization(owner: Principal, organizationData: Blob) : async ResultType {
    let orgId = await orgManager.createOrganization(owner, organizationData);
    return #ok(orgId);
};
// ... existing code ...
    public query func greet(name : Text) : async Text {
        return "Hello, " # name # "!";
    };
};
