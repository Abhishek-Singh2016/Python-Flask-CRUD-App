FROM python:latest

#RUN pip install --no-cache-dir newrelic

#ENTRYPOINT ["newrelic-admin", "run-program"]

#FROM python:latest

# with k8s, when u exec into the python pod, with  -- /bin/bash , u the main.py and all other files in the folder are in /usr/app/src
WORKDIR /usr/app/src

# take all files located in the current dir and copy them into the image
COPY . .

RUN pip install --upgrade pip
# install modules into the image
RUN pip install -r requirements.txt
ENV NEW_RELIC_CONFIG_FILE=newrelic.ini
ENV NEW_RELIC_ENVIRONMENT=production

ENTRYPOINT ["newrelic-admin", "run-program", "python", "main.py"]
# executed when a container is run based on this image
#CMD ["python", "main.py"]