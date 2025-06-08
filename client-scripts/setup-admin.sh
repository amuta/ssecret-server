#!/bin/bash
# This script provides a guided setup for creating the first admin user
# on a newly deployed ssecret-server instance on Fly.io via a secure SSH command.
set -e

echo "--- Create Initial Admin User via SSH ---"
echo ""

# --- Step 1: Prerequisites & Configuration ---
if ! command -v flyctl &> /dev/null; then
    echo "❌ Error: flyctl could not be found. Please install it first:"
    echo "   https://fly.io/docs/hands-on/install-flyctl/"
    exit 1
fi

APP_NAME=$(grep -Po "(?<=app = ')([^']+)" fly.toml | head -n1)
if [ -z "$APP_NAME" ]; then
    echo "❌ Error: Could not determine app name from fly.toml."; exit 1
fi
echo "--> Targeting app '$APP_NAME'."
echo ""

# --- Step 2: Gather User Info ---
read -p "--> Enter your desired username: " ADMIN_USERNAME
if [ -z "$ADMIN_USERNAME" ]; then
    echo "❌ Error: Username cannot be empty."; exit 1
fi
echo ""

# --- Step 3: Get User's Public SSH Key ---
DEFAULT_KEY_PATH="$HOME/.ssh/id_rsa_ssecret_$ADMIN_USERNAME"
read -e -p "--> Enter path for your public SSH key [${DEFAULT_KEY_PATH}.pub]: " SSH_PUB_KEY_PATH
# If input is empty, use the default path
if [ -z "$SSH_PUB_KEY_PATH" ]; then
    SSH_PUB_KEY_PATH="${DEFAULT_KEY_PATH}.pub"
fi
echo "    Using SSH public key path: $SSH_PUB_KEY_PATH"

# Check if the private key part exists to offer generation
PRIVATE_KEY_PATH="${SSH_PUB_KEY_PATH%.pub}"
if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "    No corresponding private key found for '$SSH_PUB_KEY_PATH'."
    read -p "    Generate a new SSH key pair named '${PRIVATE_KEY_PATH##*/}' now? (y/N) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$$ ]]; then
        ssh-keygen -t ed25519 -f "$PRIVATE_KEY_PATH" -C "$ADMIN_USERNAME@ssecret-server"
        echo "    ✅ New key generated. You may add a passphrase for extra security."
    else
        echo "    ❌ Aborting. Please create a key pair and run again."; exit 1
    fi
fi

if [ ! -f "$SSH_PUB_KEY_PATH" ]; then
    echo "    ❌ Error: Public key not found at '$SSH_PUB_KEY_PATH'."; exit 1
fi

# --- Step 4: Execute Remote Command to Create User ---
PUB_KEY=$(cat "$SSH_PUB_KEY_PATH")
echo ""
echo "--> Running remote command to create user '$ADMIN_USERNAME'..."

# Note: This script assumes the `user:create` Rake task exists on the server.
flyctl ssh console -a "$APP_NAME" -C "bin/rails \"user:create[$ADMIN_USERNAME,'$PUB_KEY']\""

echo " Username: $ADMIN_USERNAME"
echo " Pubkey: $PUB_KEY"

echo ""
echo "✅ Done. If no errors were reported above, your admin user has been created."