# Self-Hosted Password Manager - Backend

**Core Context:** This backend server is built to enable secure and private password management through client-side encryption and self-hosting.

**Key Objectives:**

* **Client-Side Encryption:** Implement encryption of all passwords and sensitive information within the user's application *before* transmission to the server, ensuring the server stores only ciphertext.
* **Self-Hosting:** Enable deployment and operation on user-controlled infrastructure.
* **Ease of Use (Backend):** Design for straightforward deployment and configuration by individuals managing their own server instance.
* **Quick Onboarding and Setup:** Provide a simple and efficient initial setup process.
* **Client-Driven Configuration:** Offer APIs for client interfaces (especially a terminal interface) to manage backend configurations.

**Core Principles:**

* **Client-Side Data Protection:** Achieve data confidentiality through encryption performed on the user's device.
* **Easy and Quick Setup:** Focus on a simple and efficient initial setup process.
* **Server Data Obfuscation:** Ensure the server stores only encrypted data, preventing access to plaintext information.

**Server Role:**

* **Authentication:** Handle user registration and authentication.
* **API Gateway:** Provide API endpoints for client interfaces (including terminal) to manage authentication, data storage (of ciphertext), and configuration.
* **Account Management:** Manage user accounts and associated credentials required for authentication.
* **Access Control:** Manage authorization, determining which users are permitted to create, edit, delete, and share secrets, as well as grant or revoke access to shared secrets.
* **Secrets Management:** Handle the storage, organization, and retrieval of encrypted secret data.