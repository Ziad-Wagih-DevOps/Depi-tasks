# Go to root directory
cd /

# List contents of root
ls

# Go to /home directory
cd home

# Add a new user called ziad
adduser ziad

# Delete the user ziad (after creating)
userdel ziad

# Create an empty file named ziad
touch ziad

# Set file permissions to 644 (rw-r--r--)
chmod 644 ziad
chmod u=rw,g=r,o=r ziad

# Create and remove a folder named ziadfolder
mkdir ziadfolder
rmdir ziadfolder

# Search for file/folder named ziad in the system
find / -name "ziad"

# Create ziadfolder again
mkdir ziadfolder

# Search again in current directory
find . -name "ziadfolder"

# Edit file ziad using vim
vim ziad

# Edit file ahmed using vim
vim ahmed

# View contents of ahmed
cat ahmed

# Display current date and time
date

# Create alias for date command
alias d=date

# Use the alias
d

# Create a file named ali using nano
nano ali

# Print current working directory
pwd

# Try to add existing user khaled
adduser khaled

# Add new user samy
adduser samy

# Switch to samy user
su samy

# Try to run sudo as samy (will fail)
sudo su

# Exit back to root
exit

# Create rabia folder and add file dalia
mkdir rabia
cd rabia
touch dalia

# Go back to /home
cd -
cd home

# Create folder engy
mkdir engy
cd engy

# Copy file dalia from rabia to current folder
cp ../rabia/dalia .

# Create new file mazen and move it to rabia
touch mazen
mv mazen /home/rabia/

# Go to rabia folder
cd -
cd rabia

# Rename file mazen to samir
mv mazen samir
