 import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";




actor QuikDB {
  private var owner: Principal = Principal.fromText("2vxsx-fae");
  private var totalRecordSize: Int = 0;


  type Field = {
    name: Text;
    fieldType: Text;
    unique: Bool; 
  };

  type Schema = {
    schemaName: Text;
    fields: [Field];
    indexes: [Text]; // User-defined indexes (up to 2 fields)
    createdAt: Int;
  };

  type Result<T, E> = {
    #ok: T;
    #err: E;
  };

  type Record = {
    id: Text;
    fields: [(Text, Text)];  // Array of (fieldName, value) pairs
  };

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

  // Initialize an empty TrieMap for schemas and indexes
  private let schemas = TrieMap.TrieMap<Text, Schema>(Text.equal, Text.hash);
  private let indexes = TrieMap.TrieMap<Text, TrieMap.TrieMap<Text, [Text]>>(Text.equal, Text.hash);
  private let records = TrieMap.TrieMap<Text, TrieMap.TrieMap<Text, Record>>(Text.equal, Text.hash);
  
  


  public func createSchema(
      schemaName: Text,
      customFields: [Field],
      userDefinedIndexes: [Text]
    ) : async Result<Bool, Text> {
      // Check if the schema already exists
      if (schemas.get(schemaName) != null) {
        return #err("A schema with this name already exists!");
      };

      // Validate user-defined indexes
      if (userDefinedIndexes.size() > 2) {
        return #err("You can define up to 2 indexes only.");
      };

      // Add default fields
      let defaultFields: [Field] = [
        { name = "creation_timestamp"; fieldType = "timestamp"; unique = false },
        { name = "update_timestamp"; fieldType = "timestamp"; unique = false }

      ];

      // Combine default fields with user-provided fields
      let allFields = Array.append(customFields, defaultFields);

      // Convert arrays to iterators for loops
      for (index in userDefinedIndexes.vals()) {
        var isValidIndex = false;
        label indexCheck for (field in allFields.vals()) {
          if (field.name == index) {
            isValidIndex := true;
            break indexCheck;
          };
        };
        if (not isValidIndex) {
          return #err("Index '" # index # "' is not a valid field in the schema.");
        };
      };

      // Create a new schema
      let newSchema: Schema = {
        schemaName = schemaName;
        fields = allFields;
        indexes = userDefinedIndexes;
        createdAt = Time.now();
      };

      // Insert the schema into the TrieMap
      schemas.put(schemaName, newSchema);

      // Initialize empty indexes
      for (index in userDefinedIndexes.vals()) {
        indexes.put(schemaName # "." # index, TrieMap.TrieMap<Text, [Text]>(Text.equal, Text.hash));
      };
      // Initialize empty record storage for the schema
      records.put(schemaName, TrieMap.TrieMap<Text, Record>(Text.equal, Text.hash));

      return #ok(true);
  };
  public shared func createRecordData(schemaName: Text, record: Record): async Result<Bool, Text> {
      // Convert Record to TrieMap internally for field validation
      let recordMap = TrieMap.fromEntries<Text, Text>(record.fields.vals(), Text.equal, Text.hash);

      // Check if schema exists
      let schemaOpt = schemas.get(schemaName);
      switch (schemaOpt) {
          case null {
              return #err("Schema not found!");
          };
          case (?schema) {
              // Validate fields but skip 'creation_timestamp' and 'update_timestamp'
              for (field in schema.fields.vals()) {
                  if (field.name != "creation_timestamp" and field.name != "update_timestamp") {
                      // Validate that the field is present in the record
                      if (recordMap.get(field.name) == null) {
                          return #err("Field '" # field.name # "' is missing in the record.");
                      };

                      // Enforce uniqueness for fields marked as unique
                      if (field.unique) {
                          let fieldValue = recordMap.get(field.name);
                          switch (fieldValue) {
                              case null {
                                  return #err("Field '" # field.name # "' has no value in the record.");
                              };
                              case (?value) {
                                  // Check if the value already exists in the records
                                  let indexKey = schemaName # "." # field.name;
                                  let indexMapOpt = indexes.get(indexKey);
                                  switch (indexMapOpt) {
                                      case null {
                                          // Index not found, initialize it
                                          let newIndexMap = TrieMap.TrieMap<Text, [Text]>(Text.equal, Text.hash);
                                          newIndexMap.put(value, [record.id]);
                                          indexes.put(indexKey, newIndexMap);
                                      };
                                      case (?indexMap) {
                                          let existingRecordIdsOpt = indexMap.get(value);
                                          switch (existingRecordIdsOpt) {
                                              case null {};
                                              case (?_existingRecordIds) {
                                                  // If the value already exists, reject the insert
                                                  return #err("Duplicate value found for unique field '" # field.name # "'.");
                                              };
                                          };
                                      };
                                  };
                              };
                          };
                      };
                  }
              };

              // Automatically set timestamps
              let currentTimestamp = Int.toText(Time.now());
              recordMap.put("creation_timestamp", currentTimestamp);
              recordMap.put("update_timestamp", currentTimestamp);

              // Use record.id directly
              let recordId = record.id;

              // Check if the record ID already exists
              let schemaRecordsOpt = records.get(schemaName);
              switch (schemaRecordsOpt) {
                  case null {
                      return #err("Record storage for schema not initialized properly.");
                  };
                  case (?schemaRecords) {
                      if (schemaRecords.get(recordId) != null) {
                          return #err("Record with ID '" # recordId # "' already exists. Insertion aborted.");
                      };

                      // Update the record to include timestamps
                      let newRecord: Record = {
                          id = recordId;
                          fields = Iter.toArray(recordMap.entries()); // Convert iterator to array
                      };

                      schemaRecords.put(recordId, newRecord); // Store the new record
                  };
              };

              // Update indexes
              for (index in schema.indexes.vals()) {
                  let indexKey = schemaName # "." # index;
                  let indexMapOpt = indexes.get(indexKey);
                  switch (indexMapOpt) {
                      case null {
                          return #err("Index '" # index # "' not initialized properly.");
                      };
                      case (?indexMap) {
                          let fieldValue = recordMap.get(index);
                          switch (fieldValue) {
                              case null {
                                  return #err("Field '" # index # "' is missing in the record.");
                              };
                              case (?fieldValue) {
                                  let recordsOpt = indexMap.get(fieldValue);
                                  switch (recordsOpt) {
                                      case null {
                                          // Insert the actual record ID into the index
                                          indexMap.put(fieldValue, [recordId]);
                                      };
                                      case (?records) {
                                          // Append the new record ID to the existing list
                                          indexMap.put(fieldValue, Array.append(records, [recordId]));
                                      };
                                  };
                              };
                          };
                      };
                  };
              };

              return #ok(true);
          };
      };
  };
  public shared func updateData(
      schemaName: Text,
      recordId: Text,
      updatedFields: [(Text, Text)]
    ) : async Result<Bool, Text> {
      // Fetch the schema
      let schemaOpt = schemas.get(schemaName);
      switch (schemaOpt) {
        case null {
          return #err("Schema not found!");
        };
        case (?schema) {
          // Get the existing record
          let schemaRecordsOpt = records.get(schemaName);
          switch (schemaRecordsOpt) {
            case null {
              return #err("Record storage for schema not initialized properly.");
            };
            case (?schemaRecords) {
              let existingRecordOpt = schemaRecords.get(recordId);
              switch (existingRecordOpt) {
                case null {
                  return #err("Record with ID '" # recordId # "' not found!");
                };
                case (?existingRecord) {
                  // Convert Record fields to TrieMap for easier updates
                  var recordMap = TrieMap.fromEntries<Text, Text>(existingRecord.fields.vals(), Text.equal, Text.hash);

                  // Apply updates
                  for (fieldUpdate in updatedFields.vals()) {
                    let (fieldName, newValue) = fieldUpdate;
                    // Validate if the field exists in the schema
                  let fieldOpt: ?Field = Array.find(schema.fields, func(field: Field): Bool { field.name == fieldName });
                  switch (fieldOpt) {
                    case null {
                      return #err("Field '" # fieldName # "' does not exist in the schema!");
                    };
                    case (?_) {
                      recordMap.put(fieldName, newValue);
                    };
                  };

                  };

                  // Update the `update_timestamp` field
                  recordMap.put("update_timestamp", Int.toText(Time.now()));

                  // Remove record from outdated index values
                for (index in schema.indexes.vals()) { 
                    let indexKey = schemaName # "." # index;
                    let indexMapOpt = indexes.get(indexKey);
                    switch (indexMapOpt) {
                      case null {};
                      case (?indexMap) {
                        let oldValueOpt = Array.find<(Text, Text)>(existingRecord.fields, func(field: (Text, Text)): Bool { field.0 == index });
                        switch (oldValueOpt) {
                          case null {};
                          case (?oldValue) {
                            let updatedIndexRecordsOpt = indexMap.get(oldValue.1);
                            switch (updatedIndexRecordsOpt) {
                              case null {};
                              case (?updatedIndexRecords) {
                                let filteredRecords = Array.filter<Text>(updatedIndexRecords, func(rId: Text): Bool { rId != recordId });
                                indexMap.put(oldValue.1, filteredRecords);
                              };
                            };
                          };
                        };
                      };
                    };
                  };

                  // Add record to updated index values
                  for (index in schema.indexes.vals()) {
                    let indexKey = schemaName # "." # index;
                    let indexMapOpt = indexes.get(indexKey);
                    switch (indexMapOpt) {
                      case null {};
                      case (?indexMap) {
                        let newValueOpt = recordMap.get(index);
                        switch (newValueOpt) {
                          case null {};
                          case (?newValue) {
                            let indexedRecordsOpt = indexMap.get(newValue);
                            switch (indexedRecordsOpt) {
                              case null {
                                indexMap.put(newValue, [recordId]);
                              };
                              case (?indexedRecords) {
                                indexMap.put(newValue, Array.append(indexedRecords, [recordId]));
                              };
                            };
                          };
                        };
                      };
                    };
                  };

                  // Commit the updated record back to `schemaRecords`
                  schemaRecords.put(recordId, { id = recordId; fields = Iter.toArray(recordMap.entries()) });

                  return #ok(true);
                };
              };
            };
          };
        };
      };
  };
  public func getMetrics(schemaName: Text): async Result<(Int, Int), Text> {
    // Retrieve the records for the schema
    let schemaRecordsOpt = records.get(schemaName);
    
    // Get the total number of schemas
    let schemaLenSize = await noOfSchema(); 

    switch (schemaRecordsOpt) {
        case null {
            return #err("Schema not found or no records exist!");
        };
        case (?schemaRecords) {
            // Convert the iterator to an array
            let entriesArray = Iter.toArray(schemaRecords.entries());
            
            // Calculate the total size of all records
            let totalSize = Array.foldLeft<(Text, { fields: [(Text, Text)] }), Int>(
                entriesArray,
                0,
                func(acc: Int, entry: (Text, { fields: [(Text, Text)] })): Int {
                    let (_, record) = entry;
                    let recordSize = Array.foldLeft<(Text, Text), Int>(
                        record.fields,
                        0,
                        func(innerAcc: Int, field: (Text, Text)): Int {
                            let (fieldName, fieldValue) = field;
                            innerAcc + fieldName.size() + fieldValue.size();
                        }
                    );
                    acc + recordSize;
                }
            );
            
            // Save the total size to the state variable
            totalRecordSize := totalSize;

            // Return a tuple with total size and the number of schemas
            return #ok(totalSize, schemaLenSize);
        };
    };
  };
  // Search by multiple fields (e.g., age and color)
  public shared func searchByMultipleFields(schemaName: Text, filters: [(Text, Text)]) : async Result<[Record], Text> {
    if (filters.size() == 0) {
      return #err("No filters provided.");
    };

    var resultIds: ?[Text] = null;

    // Iterate through each filter and perform search
    for (filter in filters.vals()) {
      let (indexName, value) = filter;
      let matchingIdsOpt = await queryByIndex(schemaName, indexName, value);
      switch (matchingIdsOpt) {
        case null {
          Debug.print("ℹ️ No matching records found for " # indexName # " = " # value);
          return #err("No matching records found for " # indexName # " = " # value);
        };
        case (?matchingIds) {
          // Debug.print("🔍 Found " # matchingIds.size().toText() # " matching records for " # indexName # " = " # value);
          if (resultIds == null) {
            resultIds := ?matchingIds;
          } else {
            // Perform intersection of current results with the new matching IDs
            resultIds := switch (resultIds) {
              case (?ids) {
                let intersection = Array.filter<Text>(ids, func(id: Text): Bool {
                  Array.find<Text>(matchingIds, func(mid: Text): Bool { mid == id }) != null
                });
                if (intersection.size() == 0) {
                  Debug.print("⚠️ No records remain after applying filter " # indexName # " = " # value);
                  return #err("No matching records found after applying filter " # indexName # " = " # value);
                };
                Debug.print("🔗 Intersection result for " # indexName # " = " # value # ": " # debug_show(intersection));
                ?intersection
              };
              case null {
                ?matchingIds
              };
            };
          };
        };
      };
    };

    // Retrieve records based on the intersected result IDs
    switch (resultIds) {
      case null {
        return #err("No matching records found after applying all filters.");
      };
      case (?ids) {
        var matchingRecords: [Record] = [];
        for (recordId in ids.vals()) {
          let recordOpt = await getRecordById(schemaName, recordId);
          switch (recordOpt) {
            case (?record) { matchingRecords := Array.append(matchingRecords, [record]); };
            case null {
              Debug.print("⚠️ Record with ID " # recordId # " could not be found.");
            };
          };
        };
        Debug.print("✅ Final matching records: " # debug_show(matchingRecords));
        return #ok(matchingRecords);
      };
    };
  };
  // Search functionality based on indexed fields
  public shared func searchByIndex(schemaName: Text, indexName: Text, value: Text) : async Result<[Record], Text> {
    // Use queryByIndex to get matching record IDs
    let matchingRecordIdsOpt = await queryByIndex(schemaName, indexName, value);
    switch (matchingRecordIdsOpt) {
      case null {
        return #err("No matching records found.");
      };
      case (?matchingRecordIds) {
        var matchingRecords: [Record] = [];
        for (recordId in matchingRecordIds.vals()) {
          let recordOpt = await getRecordById(schemaName, recordId);
          switch (recordOpt) {
            case (?record) { matchingRecords := Array.append(matchingRecords, [record]); };
            case null {};
          };
        };
        return #ok(matchingRecords);
      };
    };
  };
  public shared func deleteSchema(schemaName: Text): async Result<Bool, Text> {
    // Check if the schema exists
    let schemaOpt = schemas.get(schemaName);
    switch (schemaOpt) {
      case null {
        return #err("Schema '" # schemaName # "' does not exist!");
      };
      case (?schema) {
        // Remove all associated indexes
        for (index in schema.indexes.vals()) {
          let indexKey = schemaName # "." # index;
          let removedIndexOpt = indexes.remove(indexKey);
          switch (removedIndexOpt) {
            case null {
              Debug.print("⚠️ Index '" # indexKey # "' was not found during deletion.");
            };
            case (?_removedIndex) {
              Debug.print("✅ Index '" # indexKey # "' deleted successfully.");
            };
          };
        };

        // Remove all associated records
        let removedRecordsOpt = records.remove(schemaName);
        switch (removedRecordsOpt) {
          case null {
            Debug.print("⚠️ Records for schema '" # schemaName # "' were not found during deletion.");
          };
          case (?_removedRecords) {
            Debug.print("✅ Records for schema '" # schemaName # "' deleted successfully.");
          };
        };

        // Finally, remove the schema itself
        let removedSchemaOpt = schemas.remove(schemaName);
        if (removedSchemaOpt == null) {
          return #err("Unexpected error: Schema '" # schemaName # "' could not be removed.");
        } else {
          Debug.print("✅ Schema '" # schemaName # "' deleted successfully.");
          return #ok(true);
        };
      };
    };
  };
  // Delete a record
  public shared func deleteRecord(schemaName: Text, recordId: Text) : async Result<Bool, Text> {
    // Check if the schema exists
    let schemaOpt = schemas.get(schemaName);
    switch (schemaOpt) {
      case null {
        return #err("Schema not found!");
      };
      case (?schema) {
        // Get the records for the schema
        let schemaRecordsOpt = records.get(schemaName);
        switch (schemaRecordsOpt) {
          case null {
            return #err("No records found for schema.");
          };
          case (?schemaRecords) {
            // Get the record to delete
            let recordOpt = schemaRecords.get(recordId);
            switch (recordOpt) {
              case null {
                return #err("Record with ID '" # recordId # "' not found!");
              };
              case (?record) {
                // Remove the record from schema records
                // Remove the record from schema records
                ignore schemaRecords.remove(recordId);
                records.put(schemaName, schemaRecords);

                // Remove the record from the indexes
                for (index in schema.indexes.vals()) {
                  let indexKey = schemaName # "." # index;
                  let indexMapOpt = indexes.get(indexKey);
                  switch (indexMapOpt) {
                    case null {
                      Debug.print("⚠️ Index '" # index # "' not found during deletion.");
                    };
                    case (?indexMap) {
                      let fieldValueOpt = Array.find<(Text, Text)>(record.fields, func(field: (Text, Text)) : Bool { field.0 == index });
                      switch (fieldValueOpt) {
                        case null {
                          Debug.print("⚠️ Field '" # index # "' not found in record during deletion.");
                        };
                        case (?fieldValue) {
                          let value = fieldValue.1;
                          let recordsListOpt = indexMap.get(value);
                          switch (recordsListOpt) {
                            case null {
                              Debug.print("⚠️ No records found in index for value '" # value # "'.");
                            };
                            case (?recordsList) {
                              let updatedRecords = Array.filter<Text>(recordsList, func(rId) { rId != recordId });
                              if (updatedRecords.size() == 0) {
                                ignore indexMap.remove(value);
                              } else {
                                indexMap.put(value, updatedRecords);
                              };
                              indexes.put(indexKey, indexMap);
                            };
                          };
                        };
                      };
                    };
                  };
                };
                return #ok(true);
              };
            };
          };
        };
      };
    };
  };
  public shared func deleteAllRecords(schemaName: Text): async Result<Bool, Text> {
    // Check if the schema exists
    let schemaOpt = schemas.get(schemaName);
    switch (schemaOpt) {
        case null {
            return #err("Schema not found!");
        };
        case (?schema) {
            // Get the records for the schema
            let schemaRecordsOpt = records.get(schemaName);
            switch (schemaRecordsOpt) {
                case null {
                    return #err("No records found for schema.");
                };
                case (?schemaRecords) {
                    // Iterate directly over the record IDs and remove them
                    for (recordId in schemaRecords.keys()) {
                        ignore schemaRecords.remove(recordId);
                    };
                    records.put(schemaName, schemaRecords);

                    // Remove all index entries for this schema
                    for (index in schema.indexes.vals()) {
                        let indexKey = schemaName # "." # index;
                        let indexMapOpt = indexes.get(indexKey);
                        switch (indexMapOpt) {
                            case null {
                                Debug.print("⚠️ Index '" # index # "' not found during cleanup.");
                            };
                            case (?indexMap) {
                                // Iterate directly over the field values and remove them
                                for (fieldValue in indexMap.keys()) {
                                    ignore indexMap.remove(fieldValue);
                                };
                                indexes.put(indexKey, indexMap);
                            };
                        };
                    };
                    return #ok(true);
                };
            };
        };
    };
  };
  public shared func deleteRecordsByIndex(schemaName: Text, fieldName: Text, fieldValue: Text): async Result<Bool, Text> {
    // Check if the schema exists
    let schemaOpt = schemas.get(schemaName);
    switch (schemaOpt) {
        case null {
            return #err("Schema not found!");
        };
        case (?schema) {
            // Ensure the field is indexed
            if (Array.find<Text>(schema.indexes, func(index) { index == fieldName }) == null) {
                return #err("Field '" # fieldName # "' is not an indexed field.");
            };

            let indexKey = schemaName # "." # fieldName;
            let indexMapOpt = indexes.get(indexKey);
            switch (indexMapOpt) {
                case null {
                    return #err("Index '" # fieldName # "' not found.");
                };
                case (?indexMap) {
                    let recordIdsOpt = indexMap.get(fieldValue);
                    switch (recordIdsOpt) {
                        case null {
                            return #err("No records found for field '" # fieldName # "' with value '" # fieldValue # "'.");
                        };
                        case (?recordIds) {
                            let schemaRecordsOpt = records.get(schemaName);
                            switch (schemaRecordsOpt) {
                                case null {
                                    return #err("Record storage for schema not initialized properly.");
                                };
                                case (?schemaRecords) {
                                    // Convert recordIds to an iterable using Iter.fromArray
                                    let iterableRecordIds = Iter.fromArray(recordIds);
                                    for (recordId in iterableRecordIds) { // Iterate over the iterable
                                        ignore schemaRecords.remove(recordId); // Remove from schema records
                                    };
                                    records.put(schemaName, schemaRecords);

                                    // Remove the field value from the index
                                    ignore indexMap.remove(fieldValue);
                                    indexes.put(indexKey, indexMap);

                                    return #ok(true);
                                };
                            };
                        };
                    };
                };
            };
        };
    };
  };


  public  func getRecordSizes(schemaName: Text): async Result<[Text], Text> {
    // Retrieve the records for the schema
    let schemaRecordsOpt = records.get(schemaName);
  
    switch (schemaRecordsOpt) {
        case null {
            return #err("Schema not found or no records exist!");
        };
        case (?schemaRecords) {
            var sizes: [Text] = [];
            for ((recordId, record) in schemaRecords.entries()) {
                // Calculate the size of the record using foldLeft
                let size = Array.foldLeft<(Text, Text), Int>(
                    record.fields,
                    0,
                    func(acc: Int, field: (Text, Text)): Int {
                        let (fieldName, fieldValue) = field;
                        acc + fieldName.size() + fieldValue.size();
                    }
                );
                // Convert size to Text and append to sizes array
                sizes := Array.append(sizes, [recordId # ": " # Int.toText(size) # " bytes"]);
            };
            let result = sizes;
            return #ok(result);
        };
    };
  };
  public query func getRecord(schemaName: Text, recordId: Text): async Result<Text, Text> {
      // Retrieve the records for the schema
      let schemaRecordsOpt = records.get(schemaName);
      switch (schemaRecordsOpt) {
          case null {
              return #err("Schema not found or no records exist!");
          };
          case (?schemaRecords) {
              // Check if the record exists in the schema
              switch (schemaRecords.get(recordId)) {
                  case null {
                      return #err("Record not found!");
                  };
                  case (?record) {
                      // Calculate the size of the record and collect field details
                      var fieldDetails: [Text] = [];
                      let size = Array.foldLeft<(Text, Text), Int>(
                          record.fields,
                          0,
                          func(acc: Int, field: (Text, Text)): Int {
                              let (fieldName, fieldValue) = field;
                              // Collect field details in a human-readable format
                              fieldDetails := Array.append(fieldDetails, [fieldName # ": " # fieldValue ]);
                              acc + fieldName.size() + fieldValue.size();
                          }
                      );
                      // Join the field details into a single Text string
                      let fieldDetailsStr = Text.join("\n", Iter.fromArray(fieldDetails));
                      // Return the size and field details
                      let details = "Record ID: " # recordId # "\n" #
                                    "Size: " # Int.toText(size) # " bytes\n" #
                                    "Fields:\n" # fieldDetailsStr;
                      return #ok(details);
                  };
              };
          };
      };
  };
  // List all schemas created
  public query func listSchemas(): async [Text] {
    Iter.toArray(schemas.keys())
  };
  // Return the total number of schemas
  public shared func noOfSchema(): async Int {
      let schemaList = Iter.toArray(schemas.keys());
      return Array.size(schemaList); // Return the size of the schema list
  };
  public query func getSchema(schemaName: Text) : async ?Schema {
    schemas.get(schemaName);
  };
  public query func getAllRecords(schemaName: Text): async Result<[Record], Text> {
    // Retrieve the records for the specified schema
    let schemaRecordsOpt = records.get(schemaName);
    switch (schemaRecordsOpt) {
        case null {
            return #err("Schema not found or no records exist!");
        };
        case (?schemaRecords) {
            // Convert the schema records to an array of `Record`
            let recordsArray = Array.map<(Text, { fields: [(Text, Text)] }), Record>(
                Iter.toArray(schemaRecords.entries()),
                func(entry: (Text, { fields: [(Text, Text)] })): Record {
                    let (recordId, recordData) = entry;
                    {
                        id = recordId;
                        fields = recordData.fields;
                    };
                }
            );
            return #ok(recordsArray);
        };
    };
  };
 //Helper function:: Query data using an index
  private  func queryByIndex(schemaName: Text, indexName: Text, value: Text) : async ?[Text] {
      let indexKey = schemaName # "." # indexName;
      Debug.print("🔍 Querying index key: " # indexKey # " for value: " # value);

      let indexMap = indexes.get(indexKey);
      switch (indexMap) {
        case null {
          Debug.print("❌ Index not found for key: " # indexKey);
          return null;
        };
        case (?indexMap) {
          let result = indexMap.get(value);
          Debug.print("✅ Query result for value " # value # ": " # debug_show(result));
          return result;
        };
      };
  };
   // Helper function to get record by ID
  private  func getRecordById(schemaName: Text, recordId: Text) : async ?Record {
    let schemaRecords = records.get(schemaName);
    switch (schemaRecords) {
      case null {
        return null;
      };
      case (?schemaRecords) {
        return schemaRecords.get(recordId);
      };
    };
  };
};