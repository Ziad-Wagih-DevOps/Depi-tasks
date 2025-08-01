#configuration file to make nginx listen in port 85 , caching , edit in page of unknown path
```bash
nano /etc/nginx/conf.d/two-routes.conf
```
![Image 1](./screenshots/1-open-two-routes.conf.png)
![Image 2](./screenshots/2-editor-two-routes.conf.png)

#html code for image path
```bash
nano /var/www/images/image/index.html
```
![Image 3](./screenshots/3-open-html-code-image.png)
![Image 4](./screenshots/4-editor-html-code-image.png)
#html code for hello path
```bash
nano /var/www/hellopage/hello/index.html
```
![Image 5](./screenshots/5-open-html-code-hello.png)
![Image 6](./screenshots/6-editor-html-code-hello.png)
#html code for unknown path
```bash
nano /var/www/errors/custom_404.html
```
![Image 7](./screenshots/7-open-error-html-code.png)
![Image 8](./screenshots/8-editor-error-html-code.png)
#browse image path
![Image 9](./screenshots/9-browse-image-page.png)
#browse hello path
![Image 10](./screenshots/10-browse-hello-page.png)
#browse unknown path
![Image 11](./screenshots/11-browse-error-page.png)
