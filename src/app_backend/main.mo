import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Int "mo:base/Int";

// Import your modules
import OrgModule "org.mod";
import IncentiveModule "incentives.mod";

actor class QuikDB() = this {
    // Initialize managers from both modules
    private let orgManager = OrgModule.OrganizationManager();
    private let incentiveManager = IncentiveModule.IncentiveManager();

    // Organization Management Functions
    public shared(msg) func createOrganization(id: Text, name: Text, details: ?Blob) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.createOrganization(id, name, msg.caller, details)
    };

    public shared(msg) func addMemberToOrg(orgId: Text, newMember: Principal, role: Blob) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.addMemberToOrganization(orgId, newMember, role, msg.caller)
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
        switch(await isAuthorizedToManageCredits(msg.caller)) {
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

    // Combined Organization and Credit Functions
    public shared(msg) func distributeCreditsToOrg(orgId: Text, creditsPerMember: Nat) : async Result.Result<Text, Text> {
        // Verify caller is org owner
        switch (orgManager.getOrganization(orgId)) {
            case (#err(e)) { #err(e) };
            case (#ok(org)) {
                if (org.owner != msg.caller) {
                    return #err("Only organization owner can distribute credits");
                };

                var successCount = 0;
                for (member in org.members.vals()) {
                    switch (await addCredits(member, creditsPerMember)) {
                        case (#ok(_)) { successCount += 1; };
                        case (#err(_)) { /* Continue with next member */ };
                    };
                };

                #ok("Credits distributed to " # Int.toText(successCount) # " members")
            };
        }
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

    // Organization Project Management
    public shared(msg) func createOrgProject(orgId: Text, details: Blob) : async Result.Result<OrgModule.Project, Text> {
        orgManager.addProject(orgId, details, msg.caller)
    };

    public query func getOrgProjects(orgId: Text) : async [OrgModule.Project] {
        orgManager.getOrganizationProjects(orgId)
    };

    // Administrative Functions
    public shared(msg) func editOrganization(orgId: Text, newName: Text, newDetails: ?Blob) : async Result.Result<OrgModule.Organization, Text> {
        orgManager.editOrganization(orgId, newName, newDetails, msg.caller)
    };

    public shared(msg) func deleteOrganization(orgId: Text) : async Result.Result<(), Text> {
        orgManager.deleteOrganization(orgId, msg.caller)
    };

    // System Metrics
    public query func getSystemMetrics() : async {
        totalOrgs: Nat;
        totalTransactions: Nat;
    } {
        {
            totalOrgs = orgManager.getAllOrganizations().size();
            totalTransactions = incentiveManager.getTransactionHistory(Principal.fromText("2vxsx-fae")).size(); // Example principal
        }
    };

    // Batch Operations
    public shared(msg) func batchAddCredits(userIds: [Principal], amount: Nat) : async Result.Result<Text, Text> {
        // Verify caller is authorized
        switch(await isAuthorizedToManageCredits(msg.caller)) {
            case false { #err("Not authorized to manage credits") };
            case true {
                var successCount = 0;
                for (userId in userIds.vals()) {
                    switch (await addCredits(userId, amount)) {
                        case (#ok(_)) { successCount += 1; };
                        case (#err(_)) { /* Continue with next user */ };
                    };
                };
                #ok("Credits added for " # Int.toText(successCount) # " users")
            };
        }
    };

    // Query Functions
    public query func getUserTransactionHistory(userId: Principal) : async Result.Result<[IncentiveModule.Transaction], Text> {
        // Add authorization check if needed
        #ok(incentiveManager.getTransactionHistory(userId))
    };
}
