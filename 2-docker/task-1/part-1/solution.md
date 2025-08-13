# Nginx Docker Task

1️⃣ Pull Nginx Image

docker pull nginx:latest
This downloads the latest Nginx image from Docker Hub.

2️⃣ Save Image to a Tar File

docker save nginx:latest -o nginx-image.tar
This exports the image to a local file called nginx-image.tar.

3️⃣ Load the Image Back

docker load -i nginx-image.tar
This imports the image again from the saved .tar file.

4️⃣ Run Nginx Container (First Time)

docker run -d --name mynginx -p 8080:80 nginx:latest
Now it’s running and serving HTTP on localhost:8080.

5️⃣ Edit Inside Nginx Container

Access the container’s shell:
docker exec -it mynginx /bin/bash
Example: Change HTML index page
echo "<h1>Hello from custom Nginx!</h1>" > /usr/share/nginx/html/index.html
exit

6️⃣ Commit Changes to a New Image

docker commit mynginx nginx-custom
This saves the modified container as a new image called nginx-custom.

7️⃣ Run Custom Image With Multiple Ports

docker run -d --name mynginx-multi \
  -p 8080:80 \
  -p 8081:80 \
  -p 8443:443 \
  nginx-custom
This will:

Serve HTTP on ports 8080 and 8081

Serve HTTPS on port 8443 (if configured)

✅ Summary:

Pulled and saved an Nginx image

Loaded it back from a tar file

Edited HTML inside container

Created a new image and ran it with multiple ports


