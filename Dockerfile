
FROM gcc

LABEL \
 Description="CPPUTEST v4.0 and gcovr" 

RUN apt-get update && apt-get install -y --no-install-recommends git python-pip python-setuptools
  
#  
# Download and extract the CPPUTEST files
#
RUN mkdir -p /cpputest
RUN wget https://github.com/cpputest/cpputest/releases/download/v4.0/cpputest-4.0.tar.gz \
    && tar -xvf cpputest-4.0.tar.gz --strip-components=1 -C /cpputest \
    && rm cpputest-4.0.tar.gz

#
# Set up the CPPUTEST path
#
ENV PATH PATH=${PATH}:/cpputest
ENV CPPUTEST_HOME=/cpputest
  
#  
# Build CPPUTEST
#
WORKDIR /cpputest
RUN autoreconf . -i
RUN ./configure
RUN make tdd

#
#Install GCOVR
#
RUN pip install gcovr

RUN mkdir /project
WORKDIR /project
