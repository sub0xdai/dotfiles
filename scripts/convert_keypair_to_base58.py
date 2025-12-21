#!/usr/bin/env -S uv run

# /// script
# dependencies = [
#   "solders",
# ]
# ///
"""
Convert Solana keypair from JSON array format to Base58 string format.

Usage:
    # From file
    python convert_keypair_to_base58.py wallet.json

    # From clipboard/paste (interactive)
    python convert_keypair_to_base58.py

    # Pipe from stdin
    cat wallet.json | python convert_keypair_to_base58.py
"""
import sys
import json
from solders.keypair import Keypair


def convert_keypair(json_data: str) -> str:
    """
    Convert JSON array keypair to Base58 string.

    Args:
        json_data: JSON string containing byte array [123, 45, 67, ...]

    Returns:
        Base58 encoded private key string
    """
    try:
        # Parse JSON array
        secret_key_bytes = json.loads(json_data)

        # Validate it's a list of integers
        if not isinstance(secret_key_bytes, list):
            raise ValueError("Expected JSON array, got: " + type(secret_key_bytes).__name__)

        if len(secret_key_bytes) != 64:
            raise ValueError(f"Expected 64 bytes, got {len(secret_key_bytes)}")

        # Create keypair from bytes
        keypair = Keypair.from_bytes(bytes(secret_key_bytes))

        # Return Base58 string
        return str(keypair)

    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON format: {e}")
    except Exception as e:
        raise ValueError(f"Conversion failed: {e}")


def main():
    """Main entry point."""
    print("=" * 60)
    print("Solana Keypair Converter: JSON Array → Base58 String")
    print("=" * 60)
    print()

    # Determine input source
    if len(sys.argv) > 1:
        # Read from file
        filepath = sys.argv[1]
        print(f"📂 Reading keypair from: {filepath}")
        try:
            with open(filepath, 'r') as f:
                json_data = f.read()
        except FileNotFoundError:
            print(f"❌ Error: File not found: {filepath}")
            sys.exit(1)
        except Exception as e:
            print(f"❌ Error reading file: {e}")
            sys.exit(1)

    elif not sys.stdin.isatty():
        # Read from pipe/stdin
        print("📋 Reading keypair from stdin...")
        json_data = sys.stdin.read()

    else:
        # Interactive mode - prompt user
        print("🔑 Paste your JSON keypair array and press Enter:")
        print("    (Format: [123, 45, 67, ...])")
        print()
        json_data = input("> ").strip()

    # Convert
    try:
        base58_key = convert_keypair(json_data)

        # Display results
        print()
        print("✅ Conversion successful!")
        print("=" * 60)
        print()
        print("📝 Add this to your .env file:")
        print()
        print(f"SOLANA_PRIVATE_KEY={base58_key}")
        print()
        print("=" * 60)
        print()
        print("⚠️  SECURITY REMINDER:")
        print("   • NEVER commit this key to git")
        print("   • NEVER share this key publicly")
        print("   • Add .env to .gitignore")
        print()
        print("🔍 Public key (safe to share):")
        keypair = Keypair.from_base58_string(base58_key)
        print(f"   {keypair.pubkey()}")
        print()

    except ValueError as e:
        print()
        print(f"❌ Error: {e}")
        print()
        print("Expected format: [123, 45, 67, 89, ...]")
        print("Example: [174,47,154,16,202,193,206,113,...]")
        sys.exit(1)


if __name__ == "__main__":
    main()
