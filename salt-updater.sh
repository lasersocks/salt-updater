#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install it first."
    exit 1
fi

process_directory() {
    DIR="$1"
    WP_CONFIG="$DIR/wp-config.php"
    BACKUP_NAME="wp-config.$(date '+%Y%m%d').php"
    TEMP_FILE=$(mktemp)

    # Check if wp-config.php exists in the given directory
    if [ ! -f "$WP_CONFIG" ]; then
        echo "wp-config.php not found in $DIR."
        return
    fi

    # Fetch new salts
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ > $TEMP_FILE

    # Check if the curl request was successful
    if [ ! $? -eq 0 ]; then
        echo "Failed to fetch new salts for $DIR. Continuing to next directory."
        rm -f $TEMP_FILE
        return
    fi

    # Create a backup
    cp "$WP_CONFIG" "$DIR/$BACKUP_NAME"

    # Replace salt section using awk
    awk -v saltfile="$TEMP_FILE" '
      /define\('"'"'AUTH_KEY'"'"',/ { while ((getline line < saltfile) > 0) { print line }; f=1; next }
      /define\('"'"'NONCE_SALT'"'"',/ { f=0; next }
      !f
    ' "$WP_CONFIG" > "${WP_CONFIG}.tmp"

    # Move the temp file back to the original config
    mv "${WP_CONFIG}.tmp" "$WP_CONFIG"

    # Clean up
    rm -f $TEMP_FILE

    echo "Salts updated successfully for $DIR!"
}

# Parse arguments
while getopts ":i:t:" opt; do
    case $opt in
        i) process_directory "$OPTARG"
        ;;
        t) while IFS= read -r line; do
               if [ ! -z "$line" ]; then
                   process_directory "$line"
               fi
           done < "$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done
