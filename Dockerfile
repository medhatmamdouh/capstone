FROM nginx:latest


## Step 1:
COPY index.html  /usr/share/nginx/html/index.html

## Step 2:
EXPOSE 80

