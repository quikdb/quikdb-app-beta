Certainly! Enhancing your **QuikDB** TypeScript client with logging and organizing the functions into a class will make it more robust, maintainable, and versatile for both CLI and SDK usage. Below, I'll guide you through:

1. **Adding Logging for Easy Debugging**
2. **Refactoring Functions into a `QuikDBClient` Class**
3. **Setting Up CLI Integration**
4. **Using the `QuikDBClient` as an SDK**

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Adding Logging](#adding-logging)
3. [Creating the `QuikDBClient` Class](#creating-the-quikdbclient-class)
4. [Setting Up CLI Integration](#setting-up-cli-integration)
5. [Using `QuikDBClient` as an SDK](#using-quikdbclient-as-an-sdk)
6. [Project Structure](#project-structure)
7. [Conclusion](#conclusion)

---

## Prerequisites

Ensure you have completed the initial setup as described in the previous documentation:

- **Node.js** installed (preferably the latest LTS version).
- **TypeScript** installed globally.
- **@dfinity/agent** and **@dfinity/candid** libraries installed in your project.
- **Canister ID** of your deployed QuikDB canister.
- **Candid Interface (`quikdb.d.ts`)** defined based on the Motoko canister.

---

## Adding Logging

To facilitate easy debugging, we'll integrate a logging mechanism. For flexibility and scalability, it's recommended to use a logging library like [**winston**](https://github.com/winstonjs/winston), which provides various logging levels and transports.

### 1. Install Winston

Navigate to your project directory and install `winston` along with its TypeScript types:

```bash
npm install winston
npm install --save-dev @types/winston
```

### 2. Configure Winston

Create a dedicated logger configuration to centralize logging settings.

```typescript
// src/logger.ts

import { createLogger, format, transports } from 'winston';

const { combine, timestamp, printf, colorize } = format;

// Define a custom log format
const logFormat = printf(({ level, message, timestamp }) => {
  return `${timestamp} [${level}]: ${message}`;
});

// Create the logger instance
const logger = createLogger({
  level: 'debug', // Adjust the log level as needed ('error', 'warn', 'info', 'verbose', 'debug', 'silly')
  format: combine(
    colorize(),
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    logFormat
  ),
  transports: [
    new transports.Console(),
    // You can add more transports here (e.g., File transport)
  ],
});

export default logger;
```

**Explanation:**

- **Levels**: Controls the verbosity of logs. Common levels include `error`, `warn`, `info`, `debug`.
- **Formats**: Combines colorization, timestamping, and a custom format for clarity.
- **Transports**: Determines where logs are sent. Here, logs are output to the console, but you can also configure file logging or other destinations.

---

## Creating the `QuikDBClient` Class

Refactoring the TypeScript functions into a class structure will encapsulate the functionality, making it easier to manage state and reuse in different contexts (CLI, SDK).

### 1. Define the `QuikDBClient` Class

```typescript
// src/QuikDBClient.ts

import { Actor, HttpAgent } from '@dfinity/agent';
import { QuikDB } from './quikdb';
import { Principal } from '@dfinity/principal';
import logger from './logger';

export class QuikDBClient {
  private actor: QuikDB;
  private canisterId: string;

  /**
   * Initializes the QuikDBClient with the specified canister ID and agent configuration.
   * @param canisterId - The Canister ID of the deployed QuikDB canister.
   * @param agentOptions - Optional HttpAgent configuration options.
   */
  constructor(canisterId: string, agentOptions?: { host?: string }) {
    this.canisterId = canisterId;
    const agent = new HttpAgent(agentOptions || { host: 'https://ic0.app' });

    // For local development, uncomment the following lines:
    // if (process.env.LOCAL_DEV === 'true') {
    //   agent.fetchRootKey().catch((err) => {
    //     logger.warn('Unable to fetch root key. Check if you are in a local environment.');
    //   });
    // }

    this.actor = Actor.createActor<QuikDB>(
      // Since we don't have the actual Candid interface file, pass an empty interface.
      // In a real scenario, import the Candid interface.
      {} as any,
      {
        agent,
        canisterId: this.canisterId,
      }
    );

    logger.info(`QuikDBClient initialized with Canister ID: ${this.canisterId}`);
  }

  // --------------------
  // Initialization & Ownership
  // --------------------

  /**
   * Initializes the owner of the canister. Can only be set once.
   * @param initOwner - Principal of the new owner.
   * @returns True if successful, false otherwise.
   */
  async initOwner(initOwner: Principal): Promise<boolean> {
    logger.debug(`initOwner called with Principal: ${initOwner.toText()}`);
    try {
      const result = await this.actor.initOwner(initOwner);
      logger.info(`initOwner result: ${result}`);
      return result;
    } catch (error) {
      logger.error(`Error in initOwner: ${error}`);
      throw error;
    }
  }

  /**
   * Retrieves the current owner of the canister.
   * @returns Principal of the current owner.
   */
  async getOwner(): Promise<Principal> {
    logger.debug('getOwner called');
    try {
      const owner = await this.actor.getOwner();
      logger.info(`Current owner: ${owner.toText()}`);
      return owner;
    } catch (error) {
      logger.error(`Error in getOwner: ${error}`);
      throw error;
    }
  }

  // --------------------
  // Schema Management
  // --------------------

  /**
   * Creates a new schema in QuikDB.
   * @param schemaName - Unique name for the schema.
   * @param customFields - Array of custom fields.
   * @param userDefinedIndexes - Array of field names to be used as indexes (up to 2).
   * @returns Result indicating success or error message.
   */
  async createSchema(
    schemaName: string,
    customFields: Array<{ name: string; fieldType: string }>,
    userDefinedIndexes: Array<string>
  ): Promise<{ ok: boolean } | { err: string }> {
    logger.debug(`createSchema called with schemaName: ${schemaName}`);
    try {
      const result = await this.actor.createSchema(schemaName, customFields, userDefinedIndexes);
      if ('ok' in result) {
        logger.info(`Schema '${schemaName}' created successfully.`);
      } else {
        logger.warn(`Failed to create schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in createSchema: ${error}`);
      throw error;
    }
  }

  /**
   * Lists all schema names in QuikDB.
   * @returns Array of schema names.
   */
  async listSchemas(): Promise<Array<string>> {
    logger.debug('listSchemas called');
    try {
      const schemas = await this.actor.listSchemas();
      logger.info(`Schemas retrieved: ${schemas.join(', ')}`);
      return schemas;
    } catch (error) {
      logger.error(`Error in listSchemas: ${error}`);
      throw error;
    }
  }

  /**
   * Retrieves the total number of schemas in QuikDB.
   * @returns Number of schemas.
   */
  async noOfSchema(): Promise<number> {
    logger.debug('noOfSchema called');
    try {
      const count = await this.actor.noOfSchema();
      logger.info(`Total number of schemas: ${count}`);
      return count;
    } catch (error) {
      logger.error(`Error in noOfSchema: ${error}`);
      throw error;
    }
  }

  /**
   * Fetches a schema by its name.
   * @param schemaName - Name of the schema.
   * @returns Schema object or null if not found.
   */
  async getSchema(schemaName: string): Promise<Schema | null> {
    logger.debug(`getSchema called with schemaName: ${schemaName}`);
    try {
      const schema = await this.actor.getSchema(schemaName);
      if (schema) {
        logger.info(`Schema '${schemaName}' retrieved.`);
      } else {
        logger.warn(`Schema '${schemaName}' not found.`);
      }
      return schema;
    } catch (error) {
      logger.error(`Error in getSchema: ${error}`);
      throw error;
    }
  }

  /**
   * Deletes a schema along with its records and indexes.
   * @param schemaName - Name of the schema to delete.
   * @returns Result indicating success or error message.
   */
  async deleteSchema(schemaName: string): Promise<{ ok: boolean } | { err: string }> {
    logger.debug(`deleteSchema called with schemaName: ${schemaName}`);
    try {
      const result = await this.actor.deleteSchema(schemaName);
      if ('ok' in result) {
        logger.info(`Schema '${schemaName}' deleted successfully.`);
      } else {
        logger.warn(`Failed to delete schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in deleteSchema: ${error}`);
      throw error;
    }
  }

  // --------------------
  // Record Management
  // --------------------

  /**
   * Inserts a new record into a specified schema.
   * @param schemaName - Name of the schema.
   * @param record - Record to insert.
   * @returns Result indicating success or error message.
   */
  async insertData(schemaName: string, record: { id: string; fields: Array<[string, string]> }): Promise<{ ok: boolean } | { err: string }> {
    logger.debug(`insertData called with schemaName: ${schemaName}, recordId: ${record.id}`);
    try {
      const result = await this.actor.insertData(schemaName, record);
      if ('ok' in result) {
        logger.info(`Record '${record.id}' inserted into schema '${schemaName}'.`);
      } else {
        logger.warn(`Failed to insert record '${record.id}' into schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in insertData: ${error}`);
      throw error;
    }
  }

  /**
   * Updates fields of an existing record in a schema.
   * @param schemaName - Name of the schema.
   * @param recordId - ID of the record to update.
   * @param updatedFields - Array of field updates.
   * @returns Result indicating success or error message.
   */
  async updateData(
    schemaName: string,
    recordId: string,
    updatedFields: Array<[string, string]>
  ): Promise<{ ok: boolean } | { err: string }> {
    logger.debug(`updateData called with schemaName: ${schemaName}, recordId: ${recordId}`);
    try {
      const result = await this.actor.updateData(schemaName, recordId, updatedFields);
      if ('ok' in result) {
        logger.info(`Record '${recordId}' in schema '${schemaName}' updated successfully.`);
      } else {
        logger.warn(`Failed to update record '${recordId}' in schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in updateData: ${error}`);
      throw error;
    }
  }

  /**
   * Deletes a record from a specified schema.
   * @param schemaName - Name of the schema.
   * @param recordId - ID of the record to delete.
   * @returns Result indicating success or error message.
   */
  async deleteData(schemaName: string, recordId: string): Promise<{ ok: boolean } | { err: string }> {
    logger.debug(`deleteData called with schemaName: ${schemaName}, recordId: ${recordId}`);
    try {
      const result = await this.actor.deleteData(schemaName, recordId);
      if ('ok' in result) {
        logger.info(`Record '${recordId}' deleted from schema '${schemaName}'.`);
      } else {
        logger.warn(`Failed to delete record '${recordId}' from schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in deleteData: ${error}`);
      throw error;
    }
  }

  // --------------------
  // Querying & Metrics
  // --------------------

  /**
   * Retrieves a human-readable summary of a record.
   * @param schemaName - Name of the schema.
   * @param recordId - ID of the record.
   * @returns Result containing the summary text or error message.
   */
  async getRecord(schemaName: string, recordId: string): Promise<{ ok: string } | { err: string }> {
    logger.debug(`getRecord called with schemaName: ${schemaName}, recordId: ${recordId}`);
    try {
      const result = await this.actor.getRecord(schemaName, recordId);
      if ('ok' in result) {
        logger.info(`Record '${recordId}' retrieved from schema '${schemaName}'.`);
      } else {
        logger.warn(`Failed to retrieve record '${recordId}' from schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in getRecord: ${error}`);
      throw error;
    }
  }

  /**
   * Retrieves all records from a specified schema.
   * @param schemaName - Name of the schema.
   * @returns Result containing an array of records or error message.
   */
  async getAllRecords(schemaName: string): Promise<{ ok: Array<Record> } | { err: string }> {
    logger.debug(`getAllRecords called with schemaName: ${schemaName}`);
    try {
      const result = await this.actor.getAllRecords(schemaName);
      if ('ok' in result) {
        logger.info(`All records retrieved from schema '${schemaName}'.`);
      } else {
        logger.warn(`Failed to retrieve records from schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in getAllRecords: ${error}`);
      throw error;
    }
  }

  /**
   * Retrieves metrics for a specified schema.
   * @param schemaName - Name of the schema.
   * @returns Result containing a tuple of total size and number of schemas, or error message.
   */
  async getMetrics(schemaName: string): Promise<{ ok: [number, number] } | { err: string }> {
    logger.debug(`getMetrics called with schemaName: ${schemaName}`);
    try {
      const result = await this.actor.getMetrics(schemaName);
      if ('ok' in result) {
        const [totalSize, schemaCount] = result.ok;
        logger.info(`Metrics for schema '${schemaName}': Total Size = ${totalSize} bytes, Total Schemas = ${schemaCount}`);
        return { ok: [Number(totalSize), schemaCount] };
      } else {
        logger.warn(`Failed to retrieve metrics for schema '${schemaName}': ${result.err}`);
        return result;
      }
    } catch (error) {
      logger.error(`Error in getMetrics: ${error}`);
      throw error;
    }
  }

  /**
   * Retrieves the sizes of all records in a specified schema.
   * @param schemaName - Name of the schema.
   * @returns Result containing an array of size descriptions or error message.
   */
  async getRecordSizes(schemaName: string): Promise<{ ok: Array<string> } | { err: string }> {
    logger.debug(`getRecordSizes called with schemaName: ${schemaName}`);
    try {
      const result = await this.actor.getRecordSizes(schemaName);
      if ('ok' in result) {
        logger.info(`Record sizes retrieved for schema '${schemaName}'.`);
      } else {
        logger.warn(`Failed to retrieve record sizes for schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in getRecordSizes: ${error}`);
      throw error;
    }
  }

  // --------------------
  // Indexing & Search
  // --------------------

  /**
   * Queries record IDs by a specific index and value.
   * @param schemaName - Name of the schema.
   * @param indexName - Name of the index field.
   * @param value - Value to query.
   * @returns Array of record IDs or null if no matches.
   */
  async queryByIndex(schemaName: string, indexName: string, value: string): Promise<Array<string> | null> {
    logger.debug(`queryByIndex called with schemaName: ${schemaName}, indexName: ${indexName}, value: ${value}`);
    try {
      const result = await this.actor.queryByIndex(schemaName, indexName, value);
      if (result) {
        logger.info(`queryByIndex found ${result.length} records for ${indexName} = ${value} in schema '${schemaName}'.`);
      } else {
        logger.info(`queryByIndex found no records for ${indexName} = ${value} in schema '${schemaName}'.`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in queryByIndex: ${error}`);
      throw error;
    }
  }

  /**
   * Searches for records by a specific index and value.
   * @param schemaName - Name of the schema.
   * @param indexName - Name of the index field.
   * @param value - Value to search.
   * @returns Result containing an array of records or error message.
   */
  async searchByIndex(
    schemaName: string,
    indexName: string,
    value: string
  ): Promise<{ ok: Array<Record> } | { err: string }> {
    logger.debug(`searchByIndex called with schemaName: ${schemaName}, indexName: ${indexName}, value: ${value}`);
    try {
      const result = await this.actor.searchByIndex(schemaName, indexName, value);
      if ('ok' in result) {
        logger.info(`searchByIndex found ${result.ok.length} records for ${indexName} = ${value} in schema '${schemaName}'.`);
      } else {
        logger.warn(`searchByIndex failed for ${indexName} = ${value} in schema '${schemaName}': ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in searchByIndex: ${error}`);
      throw error;
    }
  }

  /**
   * Searches for records matching multiple indexed fields.
   * @param schemaName - Name of the schema.
   * @param filters - Array of [fieldName, value] pairs.
   * @returns Result containing an array of records or error message.
   */
  async searchByMultipleFields(
    schemaName: string,
    filters: Array<[string, string]>
  ): Promise<{ ok: Array<Record> } | { err: string }> {
    logger.debug(`searchByMultipleFields called with schemaName: ${schemaName}, filters: ${JSON.stringify(filters)}`);
    try {
      const result = await this.actor.searchByMultipleFields(schemaName, filters);
      if ('ok' in result) {
        logger.info(`searchByMultipleFields found ${result.ok.length} records matching filters in schema '${schemaName}'.`);
      } else {
        logger.warn(`searchByMultipleFields failed: ${result.err}`);
      }
      return result;
    } catch (error) {
      logger.error(`Error in searchByMultipleFields: ${error}`);
      throw error;
    }
  }

  // --------------------
  // Helper Functions
  // --------------------

  /**
   * Fetches a record by its ID.
   * @param schemaName - Name of the schema.
   * @param recordId - ID of the record.
   * @returns Record object or null if not found.
   */
  async getRecordById(schemaName: string, recordId: string): Promise<Record | null> {
    logger.debug(`getRecordById called with schemaName: ${schemaName}, recordId: ${recordId}`);
    try {
      const record = await this.actor.getRecordById(schemaName, recordId);
      if (record) {
        logger.info(`Record '${recordId}' retrieved from schema '${schemaName}'.`);
      } else {
        logger.warn(`Record '${recordId}' not found in schema '${schemaName}'.`);
      }
      return record;
    } catch (error) {
      logger.error(`Error in getRecordById: ${error}`);
      throw error;
    }
  }
}
```

**Explanation:**

- **Class Initialization (`constructor`)**:
  - Accepts `canisterId` and optional `agentOptions`.
  - Configures the `HttpAgent` with the specified host.
  - Creates the `actor` instance to interact with the canister.
  - Logs the initialization process.

- **Method Structure**:
  - Each method corresponds to a canister function.
  - Logging is added at various levels (`debug`, `info`, `warn`, `error`) to trace execution and capture important events and errors.
  - Methods return the same `Result` types as defined in the Candid interface.

- **Helper Functions**:
  - `getRecordById` is included as a helper, directly mapping to the canister's method.

**Note:** Replace the empty object `{}` in `Actor.createActor` with the actual Candid interface or use a generated interface for better type safety.

---

## Setting Up CLI Integration

To make the `QuikDBClient` usable as a CLI, we'll create a command-line interface using the [**Commander.js**](https://github.com/tj/commander.js/) library, which simplifies the creation of CLI applications.

### 1. Install Commander

```bash
npm install commander
npm install --save-dev @types/commander
```

### 2. Create the CLI Script

```typescript
// src/cli.ts

#!/usr/bin/env node

import { Command } from 'commander';
import { QuikDBClient } from './QuikDBClient';
import { Principal } from '@dfinity/principal';
import logger from './logger';
import * as readline from 'readline';

const program = new Command();

// Replace with your actual canister ID or set via environment variable
const CANISTER_ID = process.env.QUIKDB_CANISTER_ID || 'your-canister-id-here';

// Initialize QuikDBClient
const quikdb = new QuikDBClient(CANISTER_ID);

// Define CLI commands

program
  .name('quikdb-cli')
  .description('CLI to interact with QuikDB Motoko Canister')
  .version('1.0.0');

// Init Owner Command
program
  .command('init-owner <principal>')
  .description('Initialize the owner of the canister')
  .action(async (principal) => {
    try {
      const initOwnerPrincipal = Principal.fromText(principal);
      const result = await quikdb.initOwner(initOwnerPrincipal);
      console.log(`initOwner result: ${result}`);
    } catch (error) {
      logger.error(`Error in init-owner command: ${error}`);
    }
  });

// Get Owner Command
program
  .command('get-owner')
  .description('Get the current owner of the canister')
  .action(async () => {
    try {
      const owner = await quikdb.getOwner();
      console.log(`Current Owner: ${owner.toText()}`);
    } catch (error) {
      logger.error(`Error in get-owner command: ${error}`);
    }
  });

// Create Schema Command
program
  .command('create-schema <schemaName>')
  .description('Create a new schema')
  .requiredOption('-f, --fields <fields...>', 'Custom fields in name:type format, e.g., name:string email:string')
  .option('-i, --indexes <indexes...>', 'Fields to index (up to 2)')
  .action(async (schemaName, options) => {
    try {
      const customFields = options.fields.map((fieldStr: string) => {
        const [name, fieldType] = fieldStr.split(':');
        return { name, fieldType };
      });
      const userDefinedIndexes = options.indexes || [];
      const result = await quikdb.createSchema(schemaName, customFields, userDefinedIndexes);
      if ('ok' in result) {
        console.log(`Schema '${schemaName}' created successfully.`);
      } else {
        console.error(`Failed to create schema: ${result.err}`);
      }
    } catch (error) {
      logger.error(`Error in create-schema command: ${error}`);
    }
  });

// List Schemas Command
program
  .command('list-schemas')
  .description('List all schemas')
  .action(async () => {
    try {
      const schemas = await quikdb.listSchemas();
      console.log('Schemas:', schemas.join(', '));
    } catch (error) {
      logger.error(`Error in list-schemas command: ${error}`);
    }
  });

// Insert Data Command
program
  .command('insert <schemaName> <recordId>')
  .description('Insert a new record into a schema')
  .requiredOption('-f, --fields <fields...>', 'Fields in name=value format, e.g., name=Alice email=alice@example.com')
  .action(async (schemaName, recordId, options) => {
    try {
      const fields = options.fields.map((fieldStr: string) => {
        const [name, value] = fieldStr.split('=');
        return [name, value] as [string, string];
      });
      const record = { id: recordId, fields };
      const result = await quikdb.insertData(schemaName, record);
      if ('ok' in result) {
        console.log(`Record '${recordId}' inserted successfully into schema '${schemaName}'.`);
      } else {
        console.error(`Failed to insert record: ${result.err}`);
      }
    } catch (error) {
      logger.error(`Error in insert command: ${error}`);
    }
  });

// Get Record Command
program
  .command('get-record <schemaName> <recordId>')
  .description('Get a record by ID')
  .action(async (schemaName, recordId) => {
    try {
      const result = await quikdb.getRecord(schemaName, recordId);
      if ('ok' in result) {
        console.log(`Record Details:\n${result.ok}`);
      } else {
        console.error(`Failed to get record: ${result.err}`);
      }
    } catch (error) {
      logger.error(`Error in get-record command: ${error}`);
    }
  });

// Search by Index Command
program
  .command('search <schemaName> <indexName> <value>')
  .description('Search records by index')
  .action(async (schemaName, indexName, value) => {
    try {
      const result = await quikdb.searchByIndex(schemaName, indexName, value);
      if ('ok' in result) {
        console.log('Search Results:', JSON.stringify(result.ok, null, 2));
      } else {
        console.error(`Search failed: ${result.err}`);
      }
    } catch (error) {
      logger.error(`Error in search command: ${error}`);
    }
  });

// Parse the CLI arguments
program.parse(process.argv);
```

**Explanation:**

- **Shebang (`#!/usr/bin/env node`)**: Allows the script to be executed directly from the command line.
- **Commands**:
  - **init-owner**: Initializes the canister owner.
  - **get-owner**: Retrieves the current owner.
  - **create-schema**: Creates a new schema with specified fields and optional indexes.
  - **list-schemas**: Lists all available schemas.
  - **insert**: Inserts a new record into a specified schema.
  - **get-record**: Retrieves a specific record by ID.
  - **search**: Searches records based on an index and value.
- **Options**:
  - **Fields Parsing**: For commands like `create-schema` and `insert`, fields are parsed from strings like `name:string` or `name=Alice`.
- **Error Handling**: Logs errors using the `logger` and displays user-friendly messages.

### 3. Make the CLI Executable

To run the CLI commands directly, you need to set the script as executable and add a shebang line (already included above).

1. **Update `package.json`**: Add a `bin` field to map the CLI command.

    ```json
    // package.json

    {
      // ... existing fields
      "bin": {
        "quikdb-cli": "./dist/cli.js"
      },
      // ... rest of the file
    }
    ```

2. **Compile TypeScript to JavaScript**

    ```bash
    npx tsc
    ```

3. **Link the CLI Locally for Testing**

    ```bash
    npm link
    ```

    This allows you to use `quikdb-cli` as a global command in your terminal.

4. **Usage Example**

    ```bash
    # Initialize Owner
    quikdb-cli init-owner your-owner-principal-here

    # Get Current Owner
    quikdb-cli get-owner

    # Create a New Schema
    quikdb-cli create-schema User -f name:string email:string age:int -i email age

    # List All Schemas
    quikdb-cli list-schemas

    # Insert a Record
    quikdb-cli insert User user123 -f name=Alice email=alice@example.com age=30 creation_timestamp=1638316800000000000 update_timestamp=1638316800000000000

    # Get a Record
    quikdb-cli get-record User user123

    # Search by Index
    quikdb-cli search User email alice@example.com
    ```

---

## Using `QuikDBClient` as an SDK

The `QuikDBClient` class can also be imported and used within other TypeScript projects, enabling seamless integration into your applications.

### 1. Export the Class

Ensure that the `QuikDBClient` class is exported properly. If you followed the previous steps, it's already exported.

```typescript
// src/QuikDBClient.ts

export class QuikDBClient {
  // ... class definition
}
```

### 2. Import and Use in Another Module

```typescript
// src/sdkExample.ts

import { QuikDBClient } from './QuikDBClient';
import { Principal } from '@dfinity/principal';
import logger from './logger';

async function sdkUsageExample() {
  const CANISTER_ID = 'your-canister-id-here'; // Replace with actual Canister ID
  const quikdb = new QuikDBClient(CANISTER_ID);

  // Initialize Owner
  const newOwner = Principal.fromText('your-owner-principal-here');
  try {
    const initResult = await quikdb.initOwner(newOwner);
    console.log(`Owner Initialized: ${initResult}`);
  } catch (error) {
    console.error('Error initializing owner:', error);
  }

  // Create a Schema
  try {
    const schemaResult = await quikdb.createSchema('Product', [
      { name: 'name', fieldType: 'string' },
      { name: 'price', fieldType: 'int' },
      { name: 'stock', fieldType: 'int' },
    ], ['name', 'price']);

    if ('ok' in schemaResult && schemaResult.ok) {
      console.log('Schema "Product" created successfully.');
    } else {
      console.error(`Failed to create schema: ${schemaResult.err}`);
    }
  } catch (error) {
    console.error('Error creating schema:', error);
  }

  // Insert a Record
  try {
    const insertResult = await quikdb.insertData('Product', {
      id: 'prod001',
      fields: [
        ['name', 'Laptop'],
        ['price', '1500'],
        ['stock', '30'],
        ['creation_timestamp', '1638316800000000000'],
        ['update_timestamp', '1638316800000000000'],
      ],
    });

    if ('ok' in insertResult && insertResult.ok) {
      console.log('Product record inserted successfully.');
    } else {
      console.error(`Failed to insert record: ${insertResult.err}`);
    }
  } catch (error) {
    console.error('Error inserting record:', error);
  }

  // Retrieve a Record
  try {
    const recordResult = await quikdb.getRecord('Product', 'prod001');
    if ('ok' in recordResult) {
      console.log('Record Details:\n', recordResult.ok);
    } else {
      console.error(`Error fetching record: ${recordResult.err}`);
    }
  } catch (error) {
    console.error('Error retrieving record:', error);
  }

  // Search Records
  try {
    const searchResult = await quikdb.searchByIndex('Product', 'price', '1500');
    if ('ok' in searchResult) {
      console.log('Search Results:', searchResult.ok);
    } else {
      console.error(`Search failed: ${searchResult.err}`);
    }
  } catch (error) {
    console.error('Error searching records:', error);
  }
}

sdkUsageExample().catch((err) => {
  logger.error(`SDK Usage Example Error: ${err}`);
});
```

**Explanation:**

- **Initialization**: Creates an instance of `QuikDBClient` with the specified Canister ID.
- **CRUD Operations**: Demonstrates initializing the owner, creating a schema, inserting a record, retrieving a record, and searching records.
- **Error Handling**: Catches and logs errors appropriately.

### 3. Running the SDK Example

1. **Compile TypeScript**

    ```bash
    npx tsc
    ```

2. **Execute the Example**

    ```bash
    node dist/sdkExample.js
    ```

---

## Project Structure

Here's an overview of the updated project structure incorporating the class and CLI:

```plaintext
quikdb-client/
├── src/
│   ├── QuikDBClient.ts        # The QuikDBClient class with logging
│   ├── cli.ts                 # CLI script using QuikDBClient
│   ├── index.ts               # (Optional) Exports QuikDBClient for SDK usage
│   ├── logger.ts              # Logger configuration
│   ├── quikdb.d.ts            # Candid interface definitions
│   ├── sdkExample.ts          # SDK usage example
│   └── ... (other modules)
├── dist/                      # Compiled JavaScript files
│   ├── QuikDBClient.js
│   ├── cli.js
│   ├── index.js
│   ├── logger.js
│   ├── sdkExample.js
│   └── ...
├── package.json
├── tsconfig.json
└── ... (other config files)
```

**Note:** Ensure that your `tsconfig.json` is set up to compile all necessary files and that the output directory (`dist/`) is specified correctly.

---

## Conclusion

By integrating logging and organizing your TypeScript functions into a `QuikDBClient` class, you've significantly enhanced the usability and maintainability of your QuikDB client. This setup allows for:

- **Easy Debugging**: Detailed logs at various levels (`debug`, `info`, `warn`, `error`) provide insights into the application's behavior and facilitate troubleshooting.
- **CLI Integration**: A robust CLI built with Commander.js enables direct interaction with the QuikDB canister from the terminal.
- **SDK Usage**: Encapsulated class methods allow seamless integration into other TypeScript applications, promoting code reuse and modularity.

### **Next Steps:**

1. **Enhance the Candid Interface**: If available, use the actual `.did` file to generate accurate TypeScript bindings for better type safety.
2. **Expand CLI Functionality**: Add more commands as needed (e.g., update record, delete schema) to cover all canister functions.
3. **Implement Authentication**: Integrate user authentication using **@dfinity/identity** to perform operations as different principals securely.
4. **Improve Error Handling**: Develop more granular error handling based on specific error messages and scenarios.
5. **Add Tests**: Implement unit and integration tests to ensure the reliability and correctness of your client and CLI.
6. **Package as an NPM Module**: If intended for broader use, consider packaging the `QuikDBClient` as an NPM module for easy distribution and installation.

Feel free to customize and extend the `QuikDBClient` class and CLI to fit your specific project requirements. Happy coding!