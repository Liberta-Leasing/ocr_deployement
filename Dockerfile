
ARG FUNCTION_DIR="/function"

FROM public.ecr.aws/docker/library/python:buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

WORKDIR /function

RUN apt-get update && apt-get install -y

RUN apt-get install -y apt-utils

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe/Paris

RUN apt-get install python3 python3-pip tesseract-ocr git -y && \
mkdir -p ${FUNCTION_DIR}

# TO GET YOUR REQUIREMENTS FILES

COPY ./requirements.txt .
COPY ./lambda_function.py .
RUN pip install -r requirements.txt --target ${FUNCTION_DIR} && \
pip install awslambdaric --target ${FUNCTION_DIR}  

# FROM public.ecr.aws/docker/library/python:buster

# Include global arg in this stage of the build
# ARG FUNCTION_DIR
# Set working directory to function root directory
# WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
# COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

# THIS IS THE AWS RUNTIME SIMULATOR
# JAY/STEPHANE: IT ALLOWS LOCAL DEBUG
COPY ./entry_script.sh /entry_script.sh
ADD aws-lambda-rie /usr/local/bin/aws-lambda-rie
ENTRYPOINT [ "/entry_script.sh" ]

# YOU MUST UNCOMMENT THAT PART
# TO RUN THE ORIGINAL CODE
# ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]

CMD ["lambda_function.lambda_handler"]
