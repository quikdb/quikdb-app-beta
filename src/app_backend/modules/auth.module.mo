import Time "mo:base/Time";
import Principal "mo:base/Principal";
import ErrorTypes "./error.module";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";

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

    // Sample permissions storage
    var permissionsMap = HashMap<Principal, PermissionsDetails>();

    public func initOwner(_token : OwnerDetails) : async Text {
        return "Owner Details To be Saved in Permanent Storage";
    };

    public func setPermissions(_orgId : Nat, _userId : Principal, _role : Text) : async Result.Result<(), ErrorTypes.QuikDBError> {
        // Step 1: Check if the caller is a valid principal (not anonymous).
        if (Principal.isAnonymous(_userId)) {
            return #err(#ValidationError("Unauthorized: Anonymous caller cannot set permissions"));
        };

        // Step 2: Verify caller's authority to assign roles.
        let callerPermissionsOpt = permissionsMap.get(caller);
        switch (callerPermissionsOpt) {
            case (?permissions) {
                if permissions.isAdmin == false {
                    return #err(#ValidationError("Unauthorized: Caller does not have authority to assign roles"));
                };
            };
            case (null) {
                return #err(#ValidationError("Unauthorized: Caller permissions not found"));
            };
        };

        // Further implementation for setting permissions will go here...

        return #ok(());
    };
};
