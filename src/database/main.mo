import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Blob "mo:base/Blob";


// Import your modules
import OrgModule "./modules/org.mod";
import IncentiveModule "./modules/incentives.mod";
actor  QuikDB {
     private var owner: Principal = Principal.fromText("2vxsx-fae");

    // Organization and Incentive Managers
    private let orgManager = OrgModule.OrganizationManager();
    private let incentiveManager = IncentiveModule.IncentiveManager();

     // Initialization function (custom "constructor")
    public func initOwner(initOwner: Principal): async Bool {
        if (Principal.isAnonymous(owner)) { // Ensure it can only be initialized once
            owner := initOwner;
            return true;
        } else {
            return false; // Already initialized
        };
    };

    // Getter function for the owner
    public query func getOwner(): async Principal {
        owner;
    };
    // Organization Management Functions
    public shared(msg) func createOrganization(id: Text, name: Text, details: ?Blob) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.createOrganization(id, name, msg.caller, details)
    };

    public shared(msg) func addMemberToOrg(orgId: Text, newMember: Principal) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.addMemberToOrganization(orgId, newMember, msg.caller)
    };

    public query func getOrganization(id: Text) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.getOrganization(id)
    };

    public query func getAllOrganizations() : async [OrgModule.Organization] {
        orgManager.getAllOrganizations()
    };

    public query(msg) func getMyOrganizations() : async [OrgModule.Organization] {
        orgManager.getOrganizationsForUser(msg.caller)
    };

    // Credit Management Functions
    public shared(msg) func addCredits(userId: Principal, amount: Nat) : async Result.Result<Nat, Text> {
        // Verify caller is authorized (e.g., organization owner or admin)
        switch (await isAuthorizedToManageCredits(msg.caller)) {
            case false { #err("Not authorized to manage credits") };
            case true {
                incentiveManager.addCredits(userId, amount)
            };
        }
    };

    public shared(msg) func deductCredits(amount: Nat) : async Result.Result<Nat, Text> {
        incentiveManager.deductCredits(msg.caller, amount)
    };

    public query(msg) func getCreditBalance() : async Result.Result<Nat, Text> {
        incentiveManager.getCreditBalance(msg.caller)
    };

    public query(msg) func getMyTransactionHistory() : async [IncentiveModule.Transaction] {
        incentiveManager.getTransactionHistory(msg.caller)
    };

    // Helper Functions
    private func isAuthorizedToManageCredits(caller: Principal) : async Bool {
        // Example: Check if caller is an org owner or admin
        let userOrgs = orgManager.getOrganizationsForUser(caller);
        for (org in userOrgs.vals()) {
            if (org.owner == caller) {
                return true;
            };
        };
        false
    };

    // Other methods remain unchanged...
};
