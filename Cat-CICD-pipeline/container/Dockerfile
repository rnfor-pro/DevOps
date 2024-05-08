
FROM public.ecr.aws/nginx/nginx:latest

LABEL maintainer="Animals4life" 

COPY index.html /usr/share/nginx/html

COPY containerandcat*.jpg /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

