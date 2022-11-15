FROM python:3.9

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

# Install ganache-cli globally
RUN npm install -g npm@latest
RUN npm install -g ganache truffle

# Install some apt dependencies
RUN apt update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    software-properties-common

# Install Solidity compiler
RUN add-apt-repository ppa:ethereum/ethereum && \ 
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends install solc

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default nightly

# Install Manticore, Mythril and Slither 
WORKDIR /usr/src/workspace
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Install Echidna 
COPY --from=trailofbits/echidna /usr/local/bin/echidna-test /usr/local/bin/echidna-test

RUN git clone --depth 1 https://github.com/trailofbits/not-so-smart-contracts.git && \
    git clone --depth 1 https://github.com/trailofbits/rattle.git && \
    git clone --depth 1 https://github.com/crytic/building-secure-contracts

# Set the default command for the image
# CMD ["ganache-cli", "-h", "0.0.0.0"]
ENTRYPOINT ["/bin/bash"]