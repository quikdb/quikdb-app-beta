# QuikDB Motoko Canister Documentation

## 1. Overview

QuikDB is a simple database-like canister built in Motoko, designed to store schemas and records in a structured way. It provides basic CRUD (Create, Read, Update, Delete) operations on records, as well as indexing for quick lookups and a simple multi-field search feature.

The canister is composed of the following main parts:

1. **Schema Management**: Creating, listing, and deleting schemas.
2. **Record Management**: Inserting, updating, querying, and deleting records.
3. **Indexing**: Defining up to two user-specified indexes for faster lookups.
4. **Search**: Searching by single or multiple fields through indexes.
5. **Metrics**: Retrieving basic metrics such as record sizes.

---

## 2. Data Structures

### 2.1 `Field`

```motoko
type Field = {
  name: Text;
  fieldType: Text;
};
```

2.2 Schema

```motoko
type Schema = {
  schemaName: Text;
  fields: [Field];
  indexes: [Text];
  createdAt: Int;
};
```

schemaName: Unique name for the schema.
fields: An array of Field definitions describing all fields the schema supports.
indexes: Up to two user-defined fields intended to be used as indexes.
createdAt: Timestamp (in nanoseconds) indicating when the schema was created.

2.3 Record

```motoko
type Record = {
  id: Text;
  fields: [(Text, Text)];
};
```

id: A unique identifier for the record (must be unique within the schema).
fields: An array of (fieldName, fieldValue) pairs holding the actual data.
2.4 Result<T, E>

```motoko
type Result<T, E> = {
  #ok: T;
  #err: E;
};
```

A standard success/error type:
#ok: T on successful operations.
#err: E on failure (usually a Text message). 3. State Variables

```motoko
private var owner: Principal = Principal.fromText("2vxsx-fae");
private var totalRecordSize: Int = 0;
private let schemas = TrieMap.TrieMap<Text, Schema>(Text.equal, Text.hash);
private let indexes = TrieMap.TrieMap<Text, TrieMap.TrieMap<Text, [Text]>>(Text.equal, Text.hash);
private let records = TrieMap.TrieMap<Text, TrieMap.TrieMap<Text, Record>>(Text.equal, Text.hash);
```

1. owner: The principal who owns the canister. Set to the anonymous principal by default, but can be changed once with initOwner.
2. totalRecordSize: Tracks the total size (in bytes) of records for a schema during metrics calculation.
3. schemas: A TrieMap that maps a schema name (Text) to its Schema structure.
4. indexes: A TrieMap keyed by <schemaName>.<indexName>, each containing a TrieMap that maps field values to arrays of record IDs ([Text]).
5. records: A TrieMap keyed by the schema name, which holds a TrieMap of record IDs to Record objects.
   Tip: For data persistence across upgrades, consider changing these to stable var.

6. Actor Initialization & Ownership
   4.1 initOwner(initOwner: Principal) : async Bool
   Sets the canister’s owner if the current owner is still the anonymous principal ("2vxsx-fae"). Once set, it cannot be changed again.

Usage:

```motoko
let success = await QuikDB.initOwner(newOwnerPrincipal);
```

Returns true if the owner was successfully set.
Returns false if the owner was already set.
4.2 getOwner() : async Principal
A query function returning the current owner of the canister.

Usage:

```motoko
let currentOwner = await QuikDB.getOwner();
```

5. Schema Management
   5.1 createSchema(schemaName: Text, customFields: [Field], userDefinedIndexes: [Text]) : async Result<Bool, Text>
   Creates a new schema with:

schemaName: Unique schema name.
customFields: Array of additional fields.
userDefinedIndexes: Array of field names to be used as indexes (up to 2).
The function also appends two default fields:

creation_timestamp (timestamp)
update_timestamp (timestamp)
Logic:

Checks if the schema already exists.
Validates the requested indexes.
Creates the new schema, initializes indexes, and sets up record storage.
Returns #ok(true) if successful, or #err(errorMessage) if not.
5.2 listSchemas() : async [Text]
Returns an array of all schema names.

5.3 noOfSchema() : async Int
Returns the total number of schemas in the canister.

5.4 getSchema(schemaName: Text) : async ?Schema
Fetches the schema by name. Returns:

null if the schema is missing,
?Schema otherwise.
5.5 deleteSchema(schemaName: Text) : async Result<Bool, Text>
Deletes a schema and all related records and indexes.

Steps:

Ensures the schema exists.
Removes indexes and records associated with it.
Finally, removes the schema from the schemas TrieMap.
Returns #ok(true) on success or an error if unsuccessful. 6. Record Management
6.1 insertData(schemaName: Text, record: Record) : async Result<Bool, Text>
Adds a new record to an existing schema.

Validates the schema.
Checks for required fields.
Inserts the record in records.
Updates each user-defined index.
Return: #ok(true) on success or #err(errorMessage) on failure.

6.2 updateData(schemaName: Text, recordId: Text, updatedFields: [(Text, Text)]) : async Result<Bool, Text>
Updates fields within a record.

Loads the existing record.
Updates specified fields in a TrieMap.
Refreshes the update_timestamp.
Removes the record’s old indexed values, then adds its new values to indexes.
Saves the updated record.
Return: #ok(true) if successful, otherwise an error result.

6.3 deleteData(schemaName: Text, recordId: Text) : async Result<Bool, Text>
Removes a record from a schema.

Verifies the schema and record exist.
Removes the record from storage.
Updates indexes by removing references to that record ID.
Return: #ok(true) on success or an error otherwise.

7. Querying & Metrics
   7.1 getRecord(schemaName: Text, recordId: Text) : async Result<Text, Text>
   A query function returning a human-readable summary of a record:

Record ID
Size in bytes
Field names and values
Returns #ok(summaryText) or #err(errorMessage) if not found.

7.2 getRecordById(schemaName: Text, recordId: Text) : async ?Record
A helper query that returns a Record if it exists, otherwise null.

7.3 getAllRecords(schemaName: Text) : async Result<[Record], Text>
Returns all records associated with a schema.

#err("Schema not found...") if the schema is missing.
#ok([Record]) otherwise.
7.4 getMetrics(schemaName: Text) : async Result<(Int, Int), Text>
Returns:

(Int, Int) tuple, where the first is total size (in bytes) of all records in the schema, and the second is the total number of schemas.
7.5 getRecordSizes(schemaName: Text) : async Result<[Text], Text>
Returns record sizes as an array of strings like:

```css
["recordId1: 45 bytes", "recordId2: 60 bytes", ...]
```

8. Indexing & Search
   8.1 queryByIndex(schemaName: Text, indexName: Text, value: Text) : async ?[Text]
   Fetches a list of record IDs matching indexName = value in the given schema. Returns null if no matching records or index is found.

8.2 searchByIndex(schemaName: Text, indexName: Text, value: Text) : async Result<[Record], Text>
Uses queryByIndex to find record IDs and returns the full Record objects.

Returns #err("No matching records found.") if none are found.
Otherwise, #ok([Record]).
8.3 searchByMultipleFields(schemaName: Text, filters: [(Text, Text)]) : async Result<[Record], Text>
Allows searching by multiple indexed fields. For each (fieldName, value) pair, it intersects the IDs from each filter. If at any point no matches remain, it returns an error. Otherwise, returns all matching records in an array.

9. Error Handling
   Most functions return Result<T, Text> with descriptive error strings.
   Some return ?T for nullable results.

10. Conclusion
    QuikDB is a straightforward way to store and index records on the Internet Computer. It’s ideal for small-to-medium use cases where you need a quick solution for storing data and performing queries. By understanding these components—schemas, records, indexes, and their associated CRUD operations—you can maintain and extend QuikDB to fit your particular needs.
