const fs = require("fs");
const path = require("path");
const { Actor, HttpAgent } = require("@dfinity/agent");

(async () => {
  const { idlFactory } = await import(
    "../.dfx/local/canisters/database/service.did.js"
  ); // Generated Candid interface
  const canisterId = "br5f7-7uaaa-aaaaa-qaaca-cai";

  // Check if using a local replica
  const isLocalReplica =
    process.env.DFX_NETWORK === "local" || !process.env.DFX_NETWORK;

  // Create the agent
  const agent = new HttpAgent({
    host: isLocalReplica ? "http://127.0.0.1:4943" : "https://icp0.io", // Local replica or IC mainnet
  });
  // Disable certificate verification for local replica
  if (isLocalReplica) {
    agent.fetchRootKey().catch((err) => {
      console.warn("Unable to fetch root key. Running locally?");
      console.error(err);
    });
  }

  const actor = Actor.createActor(idlFactory, {
    agent,
    canisterId,
  });
  // Function to upload chunks
  async function uploadChunks(chunkDataArray) {
    const chunkIDs = [];

    for (const chunk of chunkDataArray) {
      const chunkBuffer = Buffer.from(chunk, "base64"); // Convert back to Buffer
      const chunkID = await actor.uploadChunk(chunkBuffer); // Call your function
      chunkIDs.push(chunkID); // Store returned chunk ID
    }

    console.log("Uploaded Chunk IDs:", chunkIDs);
    return chunkIDs;
  }
  // Function to retrieve chunks
  async function retrieveChunks(chunkIDs) {
    const retrievedChunks = [];

    for (const id of chunkIDs) {
      const chunkBuffer = await actor.getChunk(id); // Call your function
      retrievedChunks.push(chunkBuffer);
    }

    console.log("Retrieved Chunks:", retrievedChunks);
    return retrievedChunks;
  }
  // Reconstruct file from chunks
  async function reconstructFile(outputPath) {
    try {
      const chunkData = [
        Buffer.from("The quick ").toString("base64"), // Simulating chunk_1
        Buffer.from("brown fox ").toString("base64"), // Simulating chunk_2
        Buffer.from("jumps over the lazy dog").toString("base64"), // Simulating chunk_3
      ]; // Replace with your chunk IDs
      // Call uploadChunks
      const chunkIDs = await uploadChunks(chunkData);

      const chunks = await retrieveChunks(chunkIDs);
      console.log("Chunks:", chunks);
      // Extract Uint8Array from the retrieved chunks
      const extractedChunks = chunks.map((chunk) => chunk[0]);

      // Decode chunks back into strings
      const decodedChunks = extractedChunks.map((chunk) =>
        Buffer.from(chunk).toString("utf8")
      );

      // // Decode chunks back into strings
      // const decodedChunks = chunks.map((chunk) => chunk.toString("utf8"));
      // console.log("Decoded Chunks:", decodedChunks);

      console.log("Decoded Chunks:", decodedChunks);

      const fileBuffer = Buffer.concat(extractedChunks);

      const outputDir = path.dirname(outputPath);
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }

      // Write the file to the specified output path
      fs.writeFileSync(outputPath, fileBuffer);
      console.log("File reconstructed:", outputPath);
    } catch (error) {
      console.error("Error reconstructing file:", error.message);
    }
  }

  // Run the script
  const outputPath = "./output/output-file.txt";
  await reconstructFile(outputPath);
})();
