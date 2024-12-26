import QuikDB "canister:database";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Array "mo:base/Array";

import Int "mo:base/Int";
import Iter "mo:base/Iter";





actor TestQuikDB {
type Field = { name: Text; fieldType: Text };
type Record = { id: Text; fields: [(Text, Text)] };
  // Test function for createSchema and getSchema
    public func testCreateSchema(): async Text {
        let _ = await QuikDB.deleteSchema("Student");
    
        let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" },
        ];

        let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);

        switch (createResult) {
        case (#ok(true)) {
            Debug.print("✅ Schema 'Student' created successfully.");
        };
        case (#ok(false)) {
            Debug.print("❌ Schema creation returned false");
            return "Test Failed: Schema creation returned false";
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to create schema: " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        let retrievedSchema = await QuikDB.getSchema("Student");

        switch (retrievedSchema) {
        case (?schema) {
            Debug.print("✅ Retrieved Schema: " # debug_show(schema));
            if (schema.schemaName == "Student" and schema.fields.size() == 5) {
            return "Test Passed: Schema creation and retrieval successful.";
            } else {
            return "Test Failed: Schema data mismatch.";
            };
        };
        case null {
            return "Test Failed: Could not retrieve created schema.";
        };
        };
    };

    public func testInsertData() : async Bool {
        // Insert a record into the "Student" schema
        // Note that "id" is separate from the fields, which matches the updated insertData logic.
        let record: Record = {
            id = "student1";
            fields = [
            ("name", "Alice"),
            ("age", "20"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
            ];
        };

        let result = await QuikDB.insertData("Student", record);
        
        switch (result) {
            case (#ok(true)) {
            Debug.print("✅ Data inserted successfully.");

            // Since the "Student" schema is indexed by "age", we can query "age" = "20"
            let queryResult = await QuikDB.queryByIndex("Student", "age", "20");
            switch (queryResult) {
                case null {
                Debug.print("❌ No data found for age=20");
                return false;
                };
                case (?ids) {
                // Check if the inserted record is returned in the query result
                if (Array.find<Text>(ids, func(x) { x == "student1" }) != null) {
                    Debug.print("✅ Found 'student1' in the index for age=20.");
                    Debug.print("✅ Record data that was just inserted: " # debug_show(record));
                    return true;
                } else {
                    Debug.print("❌ 'student1' not found by querying age=20");
                    return false;
                };
                };
            };
            };
            case (#ok(false)) {
            Debug.print("❌ Insert data returned false");
            return false;
            };
            case (#err(errMsg)) {
            Debug.print("❌ Error while inserting data: " # errMsg);
            return false;
            };
        };
    };
   public func testGetRecord(): async Text {
    // First, create the "Student" schema if not already created
    let _ = await QuikDB.deleteSchema("Student");
    
    // Define fields for the "Student" schema
    let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" }
    ];

    // Ensure schema is created
    let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);
    switch (createResult) {
        case (#err(errMsg)) {
            Debug.print("⚠️ Schema creation skipped: " # errMsg); // Likely the schema already exists
        };
        case (#ok(_)) {
            Debug.print("✅ Schema 'Student' ensured for testing.");
        };
    };

    // Create records
    let record1: Record = {
        id = "student1";
        fields = [
            ("name", "Bob"),
            ("age", "30"),
            ("color", "red"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
    };
    let record2: Record = {
        id = "student2";
        fields = [
            ("name", "Alice"),
            ("age", "25"),
            ("color", "blue"),
            ("creation_timestamp", "9876543210"),
            ("update_timestamp", "9876543210")
        ];
    };

    // Insert the first record
    let insertResult = await QuikDB.insertData("Student", record1);
    switch (insertResult) {
        case (#err(errMsg)) {
            return "Test Failed: Record insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
            Debug.print("✅ Record1 inserted successfully.");
        };
        case (#ok(false)) {
            return "Test Failed: Record1 insertion returned false.";
        };
    };

    // Insert the second record
    let insertResult1 = await QuikDB.insertData("Student", record2);
    switch (insertResult1) {
        case (#err(errMsg)) {
            return "Test Failed: Record2 insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
            Debug.print("✅ Record2 inserted successfully.");
        };
        case (#ok(false)) {
            return "Test Failed: Record2 insertion returned false.";
        };
    };

    // Step 2: Call the function for the first record
    let result = await QuikDB.getRecord("Student", "student2");
    switch (result) {
        case (#ok(details)) {
           
                   Debug.print("details for  " # debug_show(details));
                return "Test passed: Valid record size and details for student1.";
            };
        case (#err(errorMsg)) {
            return "Test Failed: Error occurred while getting record size: " # errorMsg;
        };
    };
   };
   public func testCountSchemas(): async Text {
    // Step 1: Ensure the "Student" schema exists
    let _ = await QuikDB.deleteSchema("Student");
    let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" }
    ];

    let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);
    switch (createResult) {
        case (#err(errMsg)) {
            Debug.print("⚠️ Schema creation skipped: " # errMsg); // Schema already exists or error
        };
        case (#ok(_)) {
            Debug.print("✅ Schema 'Student' created.");
        };
    };

    // Step 2: Create another schema "Teacher"
    let teacherFields = [
        { name = "name"; fieldType = "string" },
        { name = "subject"; fieldType = "string" },
        { name = "experience"; fieldType = "integer" }
    ];

    let createResult2 = await QuikDB.createSchema("Teacher", teacherFields, ["experience"]);
    switch (createResult2) {
        case (#err(errMsg)) {
            Debug.print("⚠️ Schema creation skipped: " # errMsg); // Schema already exists or error
        };
        case (#ok(_)) {
            Debug.print("✅ Schema 'Teacher' created.");
        };
    };

    // Step 3: Call the countSchemas function
    let totalSchemas = await QuikDB.noOfSchema();
    
    // Step 4: Verify the result
    if (totalSchemas == 2) {
        return "Test passed: Total schemas count is " # Int.toText(totalSchemas) # ".";
    } else {
        return "Test failed: Expected 2 schemas, but got " # Int.toText(totalSchemas) # ".";
    }
};





    // Test function to query already saved data
    public func testQuerySavedData() : async Bool {
    // Insert a couple of records into the "Student" schema
    let record1: Record = {
        id = "student1";
        fields = [
        ("name", "Alice"),
        ("age", "20"),
        ("color", "blue"),
        ("creation_timestamp", "1234567890"),
        ("update_timestamp", "1234567890")
        ];
    };
    
    let record2: Record = {
        id = "student2";
        fields = [
        ("name", "Bob"),
        ("age", "30"),
        ("color", "red"),
        ("creation_timestamp", "1234567890"),
        ("update_timestamp", "1234567890")
        ];
    };

    // Insert both records
    switch (await QuikDB.insertData("Student", record1)) {
        case (#ok(_)) {
        Debug.print("✅ Inserted 'student1' successfully.");
        };
        case (#err(errMsg)) {
        Debug.print("❌ Failed to insert 'student1': " # errMsg);
        return false;
        };
    };

    switch (await QuikDB.insertData("Student", record2)) {
        case (#ok(_)) {
        Debug.print("✅ Inserted 'student2' successfully.");
        };
        case (#err(errMsg)) {
        Debug.print("❌ Failed to insert 'student2': " # errMsg);
        return false;
        };
    };

    // Query for records by age 30
    let queryResult = await QuikDB.queryByIndex("Student", "age", "30");

    Debug.print("ℹ️ Query results for age=30: " # debug_show(queryResult));

    switch (queryResult) {
        case null {
        Debug.print("❌ No records found for age=30");
        return false;
        };
        case (?ids) {
        // Check if the record with ID "student2" is returned for age 30
        let found = Array.find<Text>(ids, func(id) { id == "student2" }) != null;
        if (found) {
            Debug.print("✅ 'student2' found in query results for age=30.");
        } else {
            Debug.print("❌ 'student2' not found in query results for age=30.");
        };
        return found;
        };
    };
    };


    // Test function to query by index after inserting data
    public func testQueryByIndex() : async Bool {
    let record: Record = {
        id = "student2";
        fields = [
        ("name", "Bob"),
        ("age", "30"),
        ("color", "red"),
        ("creation_timestamp", "1234567890"),
        ("update_timestamp", "1234567890")
        ];
    };

    // Insert the record
    switch (await QuikDB.insertData("Student", record)) {
        case (#ok(_)) {
        Debug.print("✅ Inserted 'student2' successfully.");
        };
        case (#err(errMsg)) {
        Debug.print("❌ Failed to insert 'student2': " # errMsg);
        return false;
        };
    };

    // Query by age (index)
    let ageQueryResult = await QuikDB.queryByIndex("Student", "age", "30");

    Debug.print("ℹ️ Query results for age=30: " # debug_show(ageQueryResult));

    switch (ageQueryResult) {
        case null {
        Debug.print("❌ No records found for age=30");
        return false;
        };
        case (?ids) {
        // Check if 'student2' is returned for age=30
        let found = Array.find<Text>(ids, func(id) { id == "student2" }) != null;
        if (found) {
            Debug.print("✅ 'student2' found in query results for age=30.");
        } else {
            Debug.print("❌ 'student2' not found in query results for age=30.");
        };
        return found;
        };
    };
    };
    public func testSearchByIndex() : async Text {
    // First, create the "Student" schema if not already created
    let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" }
    ];

    // Ensure schema is created
    let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);
    switch (createResult) {
        case (#err(errMsg)) {
        Debug.print("⚠️ Schema creation skipped: " # errMsg); // Likely the schema already exists
        };
        case (#ok(_)) {
        Debug.print("✅ Schema 'Student' ensured for testing.");
        };
    };

    // Insert a record into the schema
    let record: Record = {
        id = "student2";
        fields = [
        ("name", "Bob"),
        ("age", "30"),
        ("color", "red"),
        ("creation_timestamp", "1234567890"),
        ("update_timestamp", "1234567890")
        ];
    };

    let insertResult = await QuikDB.insertData("Student", record);
    switch (insertResult) {
        case (#err(errMsg)) {
        return "Test Failed: Record insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
        Debug.print("✅ Record inserted successfully.");
        };
        case (#ok(false)) {
        return "Test Failed: Record insertion returned false.";
        };
    };

    // Perform search by index
    let searchResult = await QuikDB.searchByIndex("Student", "age", "30");
    switch (searchResult) {
        case (#err(errMsg)) {
        return "Test Failed: Search failed with error: " # errMsg;
        };
        case (#ok(matchingRecords)) {
        Debug.print("✅ Search completed successfully. Matching records: " # debug_show(matchingRecords));

        // Explicitly check if the inserted record is in the search results
        let found = Array.find<Record>(
            matchingRecords,
            func(record: Record) : Bool {
            record.id == "student2"
            }
        );

        if (found != null) {
            return "Test Passed: Record found in search results.";
        } else {
            return "Test Failed: Record not found in search results.";
        };
        };
    };
    };
 // Test function for updateData
    public  func testUpdateData() : async Text {
        // Insert a record for testing
        let record: Record = {
        id = "student1";
        fields = [
            ("name", "Alice"),
            ("age", "20"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
        };

        // Insert the record
        switch (await QuikDB.insertData("Student", record)) {
        case (#ok(_)) {
            Debug.print("✅ Inserted 'student1' successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to insert 'student1': " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        // Update the record's age and color
        let updatedFields: [(Text, Text)] = [
        ("age", "21"),
        ("color", "green")
        ];

        // Perform the update
    switch (await QuikDB.updateData("Student", "student1", updatedFields)) {
            case (#ok(true)) {
            Debug.print("✅ Updated 'student1' successfully.");
            };
            case (#ok(false)) {
            return "Test Failed: Update returned false."; // Handle #ok(false) case
            };
            case (#err(errMsg)) {
            Debug.print("❌ Failed to update 'student1': " # errMsg);
            return "Test Failed: " # errMsg;
            };
    };
        // Retrieve the updated record
        let updatedRecordOpt = await QuikDB.getRecordById("Student", "student1");
        switch (updatedRecordOpt) {
        case null {
            return "Test Failed: Could not retrieve updated record.";
        };
        case (?updatedRecord) {
            Debug.print("✅ Retrieved updated record: " # debug_show(updatedRecord));
            let ageOpt = Array.find<(Text, Text)>(updatedRecord.fields, func(field) { field.0 == "age" });
            let colorOpt = Array.find<(Text, Text)>(updatedRecord.fields, func(field) { field.0 == "color" });

            switch (ageOpt, colorOpt) {
            case (?age, ?color) {
                if (age.1 == "21" and color.1 == "green") {
                return "Test Passed: Record updated successfully.";
                } else {
                return "Test Failed: Record fields do not match expected values.";
                };
            };
            case _ {
                return "Test Failed: Updated fields not found.";
            };
            };
        };
        };
    };
    public  func testDeleteData() : async Text {
        let _ = await QuikDB.deleteSchema("Student");
        // Create schema
        let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" }
        ];
        switch (await QuikDB.createSchema("Student", studentFields, ["age", "color"])) {
        case (#ok(_)) {
            Debug.print("✅ Schema 'Student' created successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to create schema: " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        // Insert some records for testing
        let record: Record = {
        id = "student1";
        fields = [
            ("name", "John"),
            ("age", "30"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
        };
        switch (await QuikDB.insertData("Student", record)) {
        case (#ok(_)) {
            Debug.print("✅ Inserted 'student1' successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to insert 'student1': " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        // Perform deletion of the record
        // let _ = await QuikDB.deleteData("Student", "student1");
        switch (await QuikDB.deleteRecord("Student", "student1")) {
            case (#ok(true)) {
            Debug.print("✅ Deleted 'student1' successfully.");
            };
            case (#ok(false)) {
            return "Test Failed: Deletion returned false."; // Handle #ok(false) case
            };
            case (#err(errMsg)) {
            Debug.print("❌ Failed to delete 'student1': " # errMsg);
            return "Test Failed: " # errMsg;
            };
        };

        // Verify deletion
        let verifyResult = await QuikDB.getRecordById("Student", "student1");
        switch (verifyResult) {
        case null {
            Debug.print("✅ Verified 'student1' has been deleted.");
            return "Test Passed: 'student1' was successfully deleted.";
        };
        case (?_) {
            return "Test Failed: 'student1' still exists after deletion.";
        };
        };
    };
    // Test function for searchByMultipleFields
    public  func testSearchByMultipleFields() : async Text {


        let _ = await QuikDB.deleteSchema("Student");
        // First, create the "Student" schema if not already created
        let studentFields = [
            { name = "name"; fieldType = "string" },
            { name = "age"; fieldType = "integer" },
            { name = "color"; fieldType = "string" }
        ];

    // Ensure schema is created
    let createResult = await QuikDB.createSchema("Student", studentFields, ["age", "color"]);
    switch (createResult) {
        case (#err(errMsg)) {
        Debug.print("⚠️ Schema creation skipped: " # errMsg); // Likely the schema already exists
        };
        case (#ok(_)) {
        Debug.print("✅ Schema 'Student' ensured for testing.");
        };
    };


        // Insert some records for testing
        let record1: Record = {
        id = "student1";
        fields = [
            ("name", "Alice"),
            ("age", "30"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
        };
        let record2: Record = {
        id = "student2";
        fields = [
            ("name", "Bob"),
            ("age", "30"),
            ("color", "red"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
        };
        let record3: Record = {
        id = "student3";
        fields = [
            ("name", "Charlie"),
            ("age", "25"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
        };

        // Insert records
        switch (await QuikDB.insertData("Student", record1)) {
        case (#ok(_)) {
            Debug.print("✅ Inserted 'student1' successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to insert 'student1': " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        switch (await QuikDB.insertData("Student", record2)) {
        case (#ok(_)) {
            Debug.print("✅ Inserted 'student2' successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to insert 'student2': " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        switch (await QuikDB.insertData("Student", record3)) {
        case (#ok(_)) {
            Debug.print("✅ Inserted 'student3' successfully.");
        };
        case (#err(errMsg)) {
            Debug.print("❌ Failed to insert 'student3': " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };

        // Perform search by multiple fields (age = "30" and color = "blue")
        let searchFilters: [(Text, Text)] = [
        ("age", "30"),
        ("color", "blue")
        ];

        let searchResult = await QuikDB.searchByMultipleFields("Student", searchFilters);
        switch (searchResult) {
        case (#ok(records)) {
            Debug.print("✅ Search results for age=30 and color=blue: " # debug_show(records));
            if (Array.find<Record>(records, func(record) { record.id == "student1" }) != null) {
            return "Test Passed: 'student1' found in search results for age=30 and color=blue.";
            } else {
            return "Test Failed: 'student1' not found in search results for age=30 and color=blue.";
            };
        };
        case (#err(errMsg)) {
            Debug.print("❌ Search failed: " # errMsg);
            return "Test Failed: " # errMsg;
        };
        };
    };
    public func testGetAllRecords(): async Text {
    // Step 1: Set up test data
    let schemaName = "TestSchema";

    // First, delete the schema if it already exists to ensure a clean slate
    let _ = await QuikDB.deleteSchema(schemaName);

    // Define schema fields
    let schemaFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "city"; fieldType = "string" }
    ];

    // Create the schema
    let createResult = await QuikDB.createSchema(schemaName, schemaFields, ["name"]);
    switch (createResult) {
        case (#err(errMsg)) {
            return "Test Failed: Schema creation failed with error: " # errMsg;
        };
        case (#ok(_)) {
            Debug.print("✅ Schema '" # schemaName # "' created successfully.");
        };
    };

    // Insert multiple records into the schema
    let record1: Record = {
        id = "record1";
        fields = [("name", "Alice"), ("age", "25"), ("city", "London"),   ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")];
    };
    let record2: Record = {
        id = "record2";
        fields = [("name", "Bob"), ("age", "30"), ("city", "Paris"),   ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")];
    };
    let record3: Record = {
        id = "record3";
        fields = [("name", "Charlie"), ("age", "35"), ("city", "Berlin"),   ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")];
    };

    // Insert the records
    let insertResults = [
        await QuikDB.insertData(schemaName, record1),
        await QuikDB.insertData(schemaName, record2),
        await QuikDB.insertData(schemaName, record3)
    ];

    // Check for insertion errors
    for (result in insertResults.vals()) {
        switch (result) {
            case (#err(errMsg)) {
                return "Test Failed: Record insertion failed with error: " # errMsg;
            };
            case (#ok(true)) {
                Debug.print("✅ Record inserted successfully.");
            };
            case (#ok(false)) {
                return "Test Failed: Record insertion returned false.";
            };
        };
    };

    // Step 2: Call the `getAllRecords` function
   let result = await QuikDB.getAllRecords(schemaName);

    // Step 3: Validate and Display the Result
    switch (result) {
        case (#err(errMsg)) {
            return "Test Failed: getAllRecords returned error: " # errMsg;
        };
        case (#ok(recordsArray)) {
            // Log each record for debugging
            for (record in recordsArray.vals()) {
                Debug.print("📄 Record ID: " # record.id);
                for ((fieldName, fieldValue) in record.fields.vals()) {
                    Debug.print("    " # fieldName # ": " # fieldValue);
                };
            };

            // Create a summary of all records
            let recordsSummary = Array.map<Record, Text>(
                recordsArray,
                func(record: Record): Text {
                    let fieldDetails = Array.map<(Text, Text), Text>(
                        record.fields,
                        func(field: (Text, Text)): Text {
                            let (fieldName, fieldValue) = field;
                            fieldName # ": " # fieldValue;
                        }
                    );
                    "Record ID: " # record.id # "\n" #
                    Text.join("\n", Iter.fromArray(fieldDetails));
                }
            );

            // Combine summaries into a single result
            let resultText = Text.join("\n\n", Iter.fromArray(recordsSummary));
            return "Test Passed: Retrieved records:\n\n" # resultText;
        };
    };
};

     // Function to test getRecordSizes
    // public  func testGetRecordSizes(): async Text {
    //         // First, create the "Student" schema if not already created
    //                 let _ = await QuikDB.deleteSchema("Student");
    //     let studentFields = [
    //         { name = "name"; fieldType = "string" },
    //         { name = "age"; fieldType = "integer" },
    //         { name = "color"; fieldType = "string" }
    //     ];

    //     // Ensure schema is created
    //     let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);
    //     switch (createResult) {
    //         case (#err(errMsg)) {
    //         Debug.print("⚠️ Schema creation skipped: " # errMsg); // Likely the schema already exists
    //         };
    //         case (#ok(_)) {
    //         Debug.print("✅ Schema 'Student' ensured for testing.");
    //         };
    //     };

    //     // Insert a record into the schema
    //     let record: Record = {
    //         id = "student1";
    //         fields = [
    //         ("name", "Bob"),
    //         ("age", "30"),
    //         ("color", "red"),
    //         ("creation_timestamp", "1234567890"),
    //         ("update_timestamp", "1234567890")
    //         ];
    //     };
    //     let record2: Record = {
    //         id = "student2";
    //         fields = [
    //         ("name", "Bob"),
    //         ("age", "30"),
    //         ("color", "red"),
    //         ("creation_timestamp", "1234567890"),
    //         ("update_timestamp", "1234567890")
    //         ];
    //     };
    //     let record3: Record = {
    //         id = "student3";
    //         fields = [
    //             ("name", "Charlie"),
    //             ("age", "25"),
    //             ("color", "blue"),
    //             ("creation_timestamp", "1234567890"),
    //             ("update_timestamp", "1234567890")
    //         ];
    //         };

    //     let insertResult = await QuikDB.insertData("Student", record);
    //     switch (insertResult) {
    //         case (#err(errMsg)) {
    //         return "Test Failed: Record insertion failed with error: " # errMsg;
    //         };
    //         case (#ok(true)) {
    //         Debug.print("✅ Record inserted successfully.");
    //         };
    //         case (#ok(false)) {
    //         return "Test Failed: Record insertion returned false.";
    //         };
    //     };

    //     let insertResult1 = await QuikDB.insertData("Student", record2);
    //     switch (insertResult1) {
    //         case (#err(errMsg)) {
    //         return "Test Failed: Record2 insertion failed with error: " # errMsg;
    //         };
    //         case (#ok(true)) {
    //         Debug.print("✅ Record2 inserted successfully.");
    //         };
    //         case (#ok(false)) {
    //         return "Test Failed: Record 2insertion returned false.";
    //         };
    //     };
    //     let insertResultw = await QuikDB.insertData("Student", record3);
    //     switch (insertResultw) {
    //         case (#err(errMsg)) {
    //         return "Test Failed: Record2 insertion failed with error: " # errMsg;
    //         };
    //         case (#ok(true)) {
    //         Debug.print("✅ Record2 inserted successfully.");
    //         };
    //         case (#ok(false)) {
    //         return "Test Failed: Record 2insertion returned false.";
    //         };
    //     };

    //         let result = await QuikDB.getRecord("Student");

    //         // Check if the result is an error or ok, and return a debug-friendly output
    //         switch (result) {
    //             case (#err(errMsg)) {
    //                 return "Error: " # errMsg;
    //             };
    //             case( #ok(sizes)) {
    //                 // Convert the list of sizes to a string for easier inspection
    //                 let sizeList = Array.foldLeft<Text, Text>(sizes, "", func(acc, sizeText) {
    //                     acc # sizeText # "\n";
    //                 });
    //                 return "Sizes: \n" # sizeList;
    //             };
    //         };
    // };
    public func testGetMetrics(): async Text {
    // First, create the "Student" schema if not already created
    let _ = await QuikDB.deleteSchema("Student");
    
    let studentFields = [
        { name = "name"; fieldType = "string" },
        { name = "age"; fieldType = "integer" },
        { name = "color"; fieldType = "string" }
    ];

    // Ensure schema is created
    let createResult = await QuikDB.createSchema("Student", studentFields, ["age"]);
    switch (createResult) {
        case (#err(errMsg)) {
            Debug.print("⚠️ Schema creation skipped: " # errMsg); // Likely the schema already exists
        };
        case (#ok(_)) {
            Debug.print("✅ Schema 'Student' ensured for testing.");
        };
    };

    // Insert records into the schema
    let record: Record = {
        id = "student1";
        fields = [
            ("name", "Bob"),
            ("age", "30"),
            ("color", "red"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
    };
    let record2: Record = {
        id = "student2";
        fields = [
            ("name", "Bob"),
            ("age", "30"),
            ("color", "red"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
    };
    let record3: Record = {
        id = "student3";
        fields = [
            ("name", "Charlie"),
            ("age", "25"),
            ("color", "blue"),
            ("creation_timestamp", "1234567890"),
            ("update_timestamp", "1234567890")
        ];
    };

    // Insert records into the database
    let insertResult = await QuikDB.insertData("Student", record);
    switch (insertResult) {
        case (#err(errMsg)) {
            return "Test Failed: Record insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
            Debug.print("✅ Record inserted successfully.");
        };
        case (#ok(false)) {
            return "Test Failed: Record insertion returned false.";
        };
    };

    let insertResult1 = await QuikDB.insertData("Student", record2);
    switch (insertResult1) {
        case (#err(errMsg)) {
            return "Test Failed: Record2 insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
            Debug.print("✅ Record2 inserted successfully.");
        };
        case (#ok(false)) {
            return "Test Failed: Record2 insertion returned false.";
        };
    };

    let insertResultw = await QuikDB.insertData("Student", record3);
    switch (insertResultw) {
        case (#err(errMsg)) {
            return "Test Failed: Record3 insertion failed with error: " # errMsg;
        };
        case (#ok(true)) {
            Debug.print("✅ Record3 inserted successfully.");
        };
        case (#ok(false)) {
            return "Test Failed: Record3 insertion returned false.";
        };
    };

    // Step 2: Call the updated function
    let result = await QuikDB.getMetrics("Student");

    // Step 3: Verify the result
    switch (result) {
        case (#ok((totalSize, schemaCount))) {
            Debug.print("✅ Total record size: " # Int.toText(totalSize) # " bytes.");
            Debug.print("✅ Total number of schemas: " # Int.toText(schemaCount));
            return "Test passed: Total size is " # Int.toText(totalSize) # " bytes, total schemas: " # Int.toText(schemaCount);
        };
        case (#err(errorMsg)) {
            return "Test failed: " # errorMsg;
        };
    };
};


    // Test function for listSchemas
        public  func testListSchemas(): async Text {
            // Step 1: Create a few schemas
            let _ = await QuikDB.createSchema("Users", [{ name = "name"; fieldType = "Text" }, { name = "age"; fieldType = "Int" }], ["name"]);
            let _ = await QuikDB.createSchema("Products", [{ name = "productName"; fieldType = "Text" }, { name = "price"; fieldType = "Float" }], ["productName"]);

            // Step 2: List all schemas
            let schemaNames = await QuikDB.listSchemas();
            let schemaNamesString = Array.foldLeft<Text, Text>(schemaNames, "", func(acc, schemaName) {
                acc # schemaName # ", ";
            });
            Debug.print("✅ Schemas listed successfully: " # schemaNamesString);

            return schemaNamesString;

        };
};
