# Self-Hosted Secrets Manager - Backend

### Core Context

This backend server is built to enable a zero-knowledge, multi-user secrets management system through client-side encryption and self-hosting.

### Core Principles

* **Zero-Knowledge Server:** The server has no cryptographic ability to access user data. All sensitive information (secrets, keys) is encrypted on the client before transmission. The server stores only ciphertext.
* **Client-Driven Cryptography:** All cryptographic operations—encryption, decryption, key generation, and the cryptographic steps for sharing and revoking access—are the exclusive responsibility of the client application.
* **Self-Hosting:** The entire system is designed for deployment on user-controlled infrastructure.

### Server Role & Boundaries

The server acts as a trusted API for authentication and an untrusted storage medium for encrypted data blobs. Its responsibilities are strictly limited.

* **User Authentication:** Manages user registration (username, password hash) and authenticates users to grant API access.
* **Encrypted Data Persistence:** Provides API endpoints for the storage and retrieval of opaque, encrypted data blobs (secrets, items, and encrypted keys).
* **Authorization & Policy Enforcement:** Manages a permissions model (`SecretAccess` records) to enforce access policies. The server checks *if* a user has permission (e.g., `admin`) to perform an action (like adding another user to a secret), but it does not perform the cryptographic operations of sharing. It stores the access control data that is created and provided by authorized clients.

### Client-Side Cryptographic Workflow

To maintain the zero-knowledge principle, clients must perform the following cryptographic operations.

1.  **Secret Creation:**
    * The client generates a unique, random Data Encryption Key (DEK) for a new secret.
    * The client encrypts the secret's items with this plaintext DEK.
    * The client encrypts the DEK with the user's public key.
    * The client sends the encrypted items and the encrypted DEK to the server for storage.

2.  **Sharing (Granting Access):**
    * To share a secret with a new user, the owner's client downloads its own encrypted DEK and decrypts it with the owner's private key.
    * The client fetches the new user's public key from the server.
    * The client re-encrypts the plaintext DEK with the new user's public key.
    * The client sends this new encrypted DEK to the server to create an additional `SecretAccess` record. The server validates that the original user has `admin` permission before accepting this new record.

3.  **Access Revocation:**
    * Revoking access requires re-keying the secret to ensure the revoked user cannot access future changes.
    * The owner's client downloads and decrypts the secret's items using the current DEK.
    * The client generates a **new** random DEK.
    * The client re-encrypts all items with the new DEK.
    * The client creates new encrypted DEKs for all remaining users who should still have access.
    * The client updates the secret's items and replaces the existing `SecretAccess` records with the new set.
