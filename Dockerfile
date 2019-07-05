FROM httpd

# TODO: 
# 	DONE - Add support for Nether and End
#	DONE - Run the generate map every hour

# For testing purposes only
# docker build -t papyruscs .
# docker run -d -p 8080:80 -v /your/minecraft/world/directory:/MyWorld -v /your/http/root/directory:/usr/local/apache2/htdocs/  papyruscs
# check http://localhost:8080/

# IMPORTANT NOTE: 
# /usr/local/apache2/htdocs/ must be pre-seeded with an existing generated map
# 	for any container failure, this can be a volume mounted as /usr/local/apache2/htdocs/

# Set environment variables
ENV LevelNether = 0
ENV LevelEnd = 0

# The WorldName should be mounted as data (/MyWorld, ie /mnt/minecraft-bedrock/worlds/Bedrock)
# Copy the sample map into the image
#COPY MyWorld /MyWorld 

RUN apt-get update -y
RUN apt-get install -y zlib1g-dev unzip libgdiplus libc6-dev wget cron nano

# Set the work directory
WORKDIR /papyruscs

# Get PapyrusCs
RUN wget https://github.com/mjungnickel18/papyruscs/releases/download/v0.3.5/papyruscs-dotnetcore-0.3.5-linux64.zip
RUN unzip papyruscs-dotnetcore-0.3.5-linux64.zip -d /papyruscs
RUN chmod +x /papyruscs/PapyrusCs

# Lets copy the script to the target location
COPY generate_map.sh /usr/local/bin/generate_map.sh 
RUN chmod +x /usr/local/bin/generate_map.sh

# Copy the entrypoint.sh script 
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Add cront job to root and start the service
#RUN echo "0 * * * * /bin/bash -c \"/usr/local/bin/generate_map.sh\"" >> /var/spool/cron/crontabs/root 
#CMD service cron start (add this to the entrypoint script) 
# Transferred the cron to a file and installs it via this command 
# 	from https://stackoverflow.com/questions/35722003/cron-job-not-auto-runs-inside-a-docker-container
COPY cronjob_file /etc/cron.d/cronjob_file
RUN crontab /etc/cron.d/cronjob_file

# This would be under site.tld/map/index.html 
EXPOSE 80
ENTRYPOINT ["entrypoint.sh"]

# Moved entrypoint so that the http would run first
# Apparently this would not work as it is run on a separate container 
#CMD ["generate_map.sh"] (add this to the entrypoint script)