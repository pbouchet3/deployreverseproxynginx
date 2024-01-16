#!/bin/bash

url=""
if [ ! -f .env ]; then
	read -p "Enter your default URL here : " tmp
	echo "URL=$tmp" > .env
	read -p "Enter your email : " tmp
	echo "MAIL=$tmp" >> .env
fi

url=$(cat .env | grep "URL=")
url="${url/URL=/""}"

mail=$(cat .env | grep "MAIL=")
mail="${url/MAIL=/""}"


read -p "Do you want to deploy front & backend? [N/y]" deployType

deployType=$(echo "$deployType" | tr '[:upper:]' '[:lower:]')
if [ "$deployType" = "y" || "$deployType" = "yes" ]; then
	read -p "Final subdomain name (ex:react to do 'react.$url) : " subdomain
	read -p "File name (ex : react) : " file
	read -p "Front end's port (ex:3000) : " portfront
	read -p "Back end's port (ex:3001) : " portapi
	
	cp defaultDualWeb.conf $file".conf"
	
	sed -i "s/subdomainName/$subdomain/" $file".conf"
	sed -i "s/internalPortFront/$portfront/" $file".conf"
	sed -i "s/internalPorApit/$portapi/" $file".conf"
	
	cat $file.conf >> /etc/nginx/sites-available/$file.conf
	
	ln -s /etc/nginx/sites-available/$file".conf" /etc/nginx/sites-enabled/$file".conf"
	
	nginx -t
	
	if [ $? -ne 0 ]; then
	  echo "Bad configuration of nginx"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  exit 1
	fi
	
	systemctl restart nginx.service
	
	if [ $? -ne 0 ]; then
	  echo "Nginx can't restart"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  rm $file".conf"
	  exit 1
	fi
	
	sudo certbot --nginx --redirect -d $subdomain".aynline.fr" --preferred-challenges http --agree-tos -n -m $mail --keep-until-expiring
	
	if [ $? -ne 0 ]; then
	  echo "Can't certificate url"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  rm $file".conf"
	  exit 1
	fi
	
	rm $file".conf"
	
	echo "------"
	echo Success ! you website is published at "$subdomain.$url" with https.
	echo "Check if everythings works. Else, contact paul.bouchet3@gmail.com"

elif [ "$deployType" = "n" || "$deployType" = "no" || "$deployType" = "" ]; then
	echo "Final subdomain name (ex:react to do 'react.$url)"
	read -p "If you want to deploy default domain, keep empty : " subdomain
	read -p "File name (ex : react) : " file
	read -p "App's port (ex:3000) : " port
	
	cp default.conf $file".conf"
	
	sed -i "s/subdomainName/$subdomain/" $file".conf"
	sed -i "s/internalPort/$port/" $file".conf"
	
	cat $file.conf >> /etc/nginx/sites-available/$file.conf
	
	ln -s /etc/nginx/sites-available/$file".conf" /etc/nginx/sites-enabled/$file".conf"
	
	nginx -t
	
	if [ $? -ne 0 ]; then
	  echo "Bad configuration of nginx"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  exit 1
	fi
	
	systemctl restart nginx.service
	
	if [ $? -ne 0 ]; then
	  echo "Nginx can't restart"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  rm $file".conf"
	  exit 1
	fi
	
	sudo certbot --nginx --redirect -d "$subdomain.$url" --preferred-challenges http --agree-tos -n -m $mail --keep-until-expiring
	
	if [ $? -ne 0 ]; then
	  echo "Can't certificate url"
	  rm /etc/nginx/sites-available/$file.conf
	  rm /etc/nginx/sites-enabled/$file.conf
	  rm $file".conf"
	  exit 1
	fi
	
	rm $file".conf"
	
	echo "------"
	echo Success ! you website is published at "$subdomain.$url" with https.
	echo "Check if everythings works. Else, contact paul.bouchet3@gmail.com"
fi
