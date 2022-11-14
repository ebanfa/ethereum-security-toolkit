FROM python:3.10.6

RUN python3 --version

# Install node uising NVM
ENV NODE_VERSION=19.0.1
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Install latest NPM
RUN npm install -g npm@latest

# Install ganache-cli globally
RUN npm install -g ganache truffle

# # Install Solidity compiler
# RUN curl -o /usr/bin/solc -fL https://github.com/ethereum/solidity/releases/download/v0.8.17/solc-static-linux \
#     && chmod u+x /usr/bin/solc

# # Get Rust
# RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

# ENV PATH="/root/.cargo/bin:${PATH}"

# RUN rustup default nightly

# # Install Manticore, Mythril and Slither 
# WORKDIR /usr/src/app
# COPY requirements.txt ./
# RUN pip3 install --no-cache-dir -r requirements.txt

# Install all and select the latest version of solc as the default
# SOLC_VERSION is defined to a valid version to avoid a warning message on the output
RUN pip3 --no-cache-dir install solc-select
RUN solc-select install all && SOLC_VERSION=0.8.0 solc-select versions | head -n1 | xargs solc-select use

RUN pip3 --no-cache-dir install slither-analyzer pyevmasm
RUN pip3 --no-cache-dir install --upgrade manticore

RUN git clone --depth 1 https://github.com/trailofbits/not-so-smart-contracts.git && \
    git clone --depth 1 https://github.com/trailofbits/rattle.git && \
    git clone --depth 1 https://github.com/crytic/building-secure-contracts
# Install Echidna 
COPY --from=trailofbits/echidna /usr/local/bin/echidna-test /usr/local/bin/echidna-test

# CMD [ "python", "./your-daemon-or-script.py" ]