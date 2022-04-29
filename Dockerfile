# Start from the code-server Debian base image
FROM codercom/code-server:4.3.0

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below

# Install Nodejs & Yarn & Hugo & Gibo
RUN sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - && \
    sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    sudo apt-get update && \
    sudo apt-get install -y nodejs yarn jq && \
    hugolatest=$(curl https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r .assets[].browser_download_url | grep 'hugo_[1234567890.].*_Linux-64bit.deb') && \
    sudo curl -L $hugolatest  -o hugo.deb && \
    sudo apt-get install ./hugo.deb && \
    sudo rm hugo.deb && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo curl -L https://raw.github.com/simonwhitaker/gibo/master/gibo -o /usr/local/bin/gibo && \
    sudo chmod +x /usr/local/bin/gibo
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
