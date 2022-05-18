########################################################################################################################
# Builder image
########################################################################################################################
FROM ubuntu:20.04 as builder-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y python3.9 python3.9-dev python3.9-venv python3-pip python3-wheel wget build-essential automake autoconf libtool && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# create and activate virtual environment
# using final folder name to avoid path issues with packages
RUN python3.9 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# install requirements
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir gcovr

# Download and extract the CPPUTEST files
RUN mkdir -p /cpputest
RUN wget https://github.com/cpputest/cpputest/releases/download/v4.0/cpputest-4.0.tar.gz \
    && tar -xvf cpputest-4.0.tar.gz --strip-components=1 -C /cpputest \
    && rm cpputest-4.0.tar.gz

# Build CPPUTEST
WORKDIR /cpputest
RUN autoreconf . -i
RUN ./configure
RUN make tdd

########################################################################################################################
# Runner image image
########################################################################################################################
FROM ubuntu:20.04 as runner-image

# avoid stuck build due to user prompt
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y python3.9 python3.9-venv build-essential git astyle locales && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locales. Needed by Astyle.
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY --from=builder-image /cpputest /cpputest

# Set up the CPPUTEST path
ENV PATH="/cpputest:$PATH"
ENV CPPUTEST_HOME=/cpputest

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED 1

# Create user
RUN useradd --create-home myuser
COPY --from=builder-image /venv /venv

USER myuser
RUN mkdir /home/myuser/code
WORKDIR /home/myuser/code

# make sure all messages always reach console
ENV PYTHONUNBUFFERED=1

# activate virtual environment
ENV VIRTUAL_ENV=/venv
ENV PATH="/venv/bin:$PATH"

# Set the bash shell
ENV SHELL=/bin/bash
