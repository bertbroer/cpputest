
FROM gcc

LABEL \
 Description="CPPUTEST v3.8 and gcovr" 

RUN apt-get update && apt-get install -y --no-install-recommends git python-pip locales
  
#  
# Download and extract the CPPUTEST files
#
RUN mkdir -p /cpputest
RUN wget https://github.com/cpputest/cpputest/releases/download/v3.8/cpputest-3.8.tar.gz \
    && tar -xvf cpputest-3.8.tar.gz --strip-components=1 -C /cpputest \
    && rm cpputest-3.8.tar.gz

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
