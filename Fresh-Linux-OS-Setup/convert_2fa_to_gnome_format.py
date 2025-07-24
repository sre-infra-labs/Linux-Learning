import json
import sys
from pathlib import Path

def convert_to_gnome_format(input_file):
    input_path = Path(input_file).resolve()

    # Output filename logic
    output_filename = f"{input_path.stem}--converted-4-gnome-authenticator.json"
    output_path = input_path.parent / output_filename

    # Load input data
    with open(input_path, "r") as f:
        raw_data = json.load(f)

    # Convert entries
    converted = []
    for entry in raw_data:
        converted.append({
            "secret": entry["secret"],
            "label": entry["name"],
            "period": 30,
            "digits": 6,
            "type": "OTP",
            "algorithm": "SHA1",
            "thumbnail": "Default",
            "last_used": 0,
            "tags": [entry["issuer"]] if entry.get("issuer") else []
        })

    # Write output
    with open(output_path, "w") as f:
        json.dump(converted, f, indent=2)

    print(f"✅ Converted file saved to: {output_path}")

# Usage
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("❌ Usage: python convert_2fa_to_gnome_format.py <input_json_path>")
        sys.exit(1)

    convert_to_gnome_format(sys.argv[1])

# python convert_2fa_to_gnome_format.py poc__extracted_secrets.json
