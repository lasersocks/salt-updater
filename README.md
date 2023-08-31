# Wordpress salt-updater
salt-updater is a bash script to update the salt section in wordpress wp-config files<br>

salt-updater will look for wp-config.php files in either a specific location or from a list of folders in a text file.<br>
The script will make a backup copy of the existing wp-config.php file, load a new set of salt data from https://api.wordpress.org/secret-key/1.1/salt/ and then update the wp-config.php file the new salt data. <br>

# How to use
Download the script<br>
Provide execute permissions: chmod +x salt-updater.sh.<br>
Run the script: ./salt-updater.sh -i /var/www/website.com/public/. <br>
For bulk updates run ./salt-updater.sh -t list-of-folders.txt <br>

# Use at your own risk!
Remember to test on a non-production setup first to ensure that everything is functioning correctly.<br>
