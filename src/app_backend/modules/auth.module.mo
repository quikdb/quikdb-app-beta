// Authentication Module
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import ErrorModule "./error.module";
import Result "mo:base/Result";

module Authentication {

    public type PermissionsDetails = {
        asignee : Text;
        canReadDatabase : Bool;
        canWriteDatabase : Bool;
        canCreateCanister : Bool;
        canUpdateCanister : Bool;
        canDeleteCanister : Bool;
        canReadProject : Bool;
        canUpdateProject : Bool;
        canDeleteProject : Bool;
        canReadDataGroup : Bool;
        canUpdateDataGroup : Bool;
        canDeleteDataGroup : Bool;
        canReadGroupItems : Bool;
        canUpdateGroupItems : Bool;
        canDeleteGroupItems : Bool;
        isAdmin : Bool;
        readsOnly : Bool;
        readsAndWrites : Bool;
    };
    public type OwnerDetails = {
        canisterId : Text;
        canisterUrl : Text;
        name : Text;
        createdBy : Principal;
        createdAt : Time.Time;
    };

    public func initOwner(_token : OwnerDetails) : async Text {
        // Implementation steps: None for now.
        // any one can call this function
        return "Owner Details To be Saved in Permanent Storage";
    };

    // Sets permissions for a team member within an organization.
    // public func setPermissions(_orgId: Nat, _userId: Principal, _role: Text): async () {
    //     // Implementation steps:
    //     // 1. Authenticate the caller.
    //     // 2. Verify caller's authority to assign roles.
    //     // 3. Update the user's role in the organization's context.
    //     // 4. Enforce role-based access control.
    // };

    public shared ({ caller }) func setPermissions(_orgId : Nat, _userId : Principal, _role : Text) : async Result.Result<(), ErrorModule.QuikDBError> {
        // Step 1: Authenticate the caller.
       if (Principal.isAnonymous(caller)) {
            return #err(#ValidationError("Unauthorized: Anonymous caller cannot set permissions"));
        };

        // Further implementation for setting permissions will go here...

        return #ok(());
    };
};
