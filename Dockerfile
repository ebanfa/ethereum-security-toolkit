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

RUN npm install -g npm@latest
RUN npm install -g typescript

RUN node --version
RUN npm --version

# Install Solidity compiler
RUN curl -o /usr/bin/solc -fL https://github.com/ethereum/solidity/releases/download/v0.8.17/solc-static-linux \
    && chmod u+x /usr/bin/solc
RUN solc --version

# Get Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup default nightly

# Python packages 
WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# Install Haskell
ENV PATH="/root/.local/bin:${PATH}"
RUN curl -sSL https://get.haskellstack.org/ | sh

# Install Echidna
ENV ECHIDNA_VERSION=2.0.3
RUN wget https://github.com/crytic/echidna/archive/refs/tags/v${ECHIDNA_VERSION}.zip
RUN unzip v${ECHIDNA_VERSION}.zip
WORKDIR /usr/src/app/echidna-${ECHIDNA_VERSION}
RUN /usr/local/bin/stack install

COPY . .

# CMD [ "python", "./your-daemon-or-script.py" ]