FROM jenkins/jenkins:lts-jdk17

# Copy plugin list
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Install CLI tool and plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt