// Organization and Project Management Module
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Iter "mo:base/Iter";

module {
  

    // Define a custom hash function for Nat
    public func customNatHash(n: Nat): Hash.Hash {
        // Convert Nat to Text and hash it
        let text = Nat.toText(n);
        return Text.hash(text);
    };

    public class OrganizationManager() {
        private var nextOrgId: Nat = 0;
        private var nextProjectId: Nat = 0;
        private let organizations = HashMap.HashMap<Nat, {
            id: Nat;
            details: Blob;
            owner: Principal;
            members: [(Principal, Text)];
            projects: [Nat];
        }>(0, Nat.equal, customNatHash);
        private let userOrgs = HashMap.HashMap<Principal, [Nat]>(0, Principal.equal, Principal.hash);

        public func hasPermission(user: Principal, orgId: Nat, role: Text): async Bool {
            switch (organizations.get(orgId)) {
                case null false;
                case (?org) {
                    Array.find<(Principal, Text)>(org.members, func((member, memberRole)) {
                        member == user and memberRole == role
                    }) != null
                }
            }
        };

        public func createOrganization(caller: Principal, orgDetails: Blob): async Nat {
            // Validate organization details first to fail fast
            if (orgDetails.size() == 0) {
                throw Error.reject("Organization details cannot be empty");
            };

            // Check for unique details using entries() iterator
            label uniqueCheck for ((_, org) in organizations.entries()) {
                if (org.details == orgDetails) {
                    throw Error.reject("An organization with these details already exists");
                    break uniqueCheck;
                };
            };

            // Generate new organization ID
            let orgId = nextOrgId;
            nextOrgId += 1;

            // Create and store organization in one step
            organizations.put(orgId, {
                id = orgId;
                details = orgDetails;
                owner = caller;
                members = [(caller, "owner")];
                projects = [];
            });
            
            // Add to user's organizations if not already present
            userOrgs.put(caller, [orgId]);
            
            orgId
        };

        public func getOrganizations(caller: Principal): async [Nat] {
            switch (userOrgs.get(caller)) {
                case null [];
                case (?orgs) orgs;
            }
        };

        public func addProject(orgId: Nat, caller: Principal, projectDetails: Blob): async Nat {
            // 1. Authenticate caller by verifying organization exists
            let org = switch (organizations.get(orgId)) {
                case null throw Error.reject("Organization not found");
                case (?o) o;
            };
            
            // 2. Verify caller has admin permissions
            if (not (await hasPermission(caller, orgId, "admin"))) {
                throw Error.reject("Insufficient permissions");
            };
            
            // 3. Validate project details
            if (projectDetails.size() == 0) {
                throw Error.reject("Project details cannot be empty");
            };
            
            // 4. Generate unique project ID
            let projectId = nextProjectId;
            nextProjectId += 1;
            
            // 5. Store project data by updating organization
            organizations.put(orgId, {
                org with 
                projects = Array.append(org.projects, [projectId])
            });
            
            // 6. Return the project ID
            projectId
        };

        public func editOrganization(_orgId: Nat, _updatedDetails: Blob, caller: Principal): async () {
            // Verify the caller has edit permissions
            let hasAdminPermission = await hasPermission(caller, _orgId, "admin");
            if (not hasAdminPermission) {
                throw Error.reject("Insufficient permissions");
            };
            
            // Validate updatedDetails 
            if (_updatedDetails.size() == 0) {
                throw Error.reject("Invalid details");
            };
            
            // Update the organization's details
            switch (organizations.get(_orgId)) {
                case null { throw Error.reject("Organization not found") };
                case (?org) {
                    let updatedOrg = { org with details = _updatedDetails };
                    organizations.put(_orgId, updatedOrg);
                };
            };
        };

        public func deleteOrganization(_orgId: Nat, caller: Principal): async () {
            // Verify the caller is the owner
            switch (organizations.get(_orgId)) {
                case null { throw Error.reject("Organization not found") };
                case (?org) {
                    if (org.owner != caller) {
                        throw Error.reject("Only the owner can delete the organization");
                    };
                    // Remove the organization and associated data
                    ignore organizations.remove(_orgId);
                    
                    // Handle cascading deletions carefully (e.g., remove from userOrgs)
                    for ((user, orgs) in userOrgs.entries()) {
                        let updatedOrgs = Array.filter<Nat>(orgs, func(orgId) { orgId != _orgId });
                        userOrgs.put(user, updatedOrgs);
                    };
                    
                    // Ensure the function returns ()
                    return ();
                };
            };
        };

        public func addMember(_orgId: Nat, _userId: Principal, _role: Blob, caller: Principal): async () {
            // Verify the caller has permission to add members
            let hasAdminPermission = await hasPermission(caller, _orgId, "admin");
            if (not hasAdminPermission) {
                throw Error.reject("Insufficient permissions");
            };
            
            // Update the organization's member list
            switch (organizations.get(_orgId)) {
                case null { throw Error.reject("Organization not found") };
                case (?org) {
                    let updatedMembers = Array.append<(Principal, Text)>(org.members, [(_userId, "member")]);
                    let updatedOrg = { org with members = updatedMembers };
                    organizations.put(_orgId, updatedOrg);
                };
            };
        };
    };
};