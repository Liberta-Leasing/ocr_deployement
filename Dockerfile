ARG FUNCTION_DIR="/function"

FROM public.ecr.aws/docker/library/python:buster as build-image

# Include global arg in this stage of the build
ARG FUNCTION_DIR

WORKDIR /home/ubuntu

RUN apt-get update && pt-get install -y

RUN apt-get utils

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe/Paris

RUN apt-get install python3 python3-pip -y

RUN mkdir -p ${FUNCTION_DIR}

RUN apt-get tesseract-ocr --target ${FUNCTION_DIR}

RUN git clone https://github.com/Liberta-Leasing/ocr_deployement.git

RUN pip install -r ocr_deployement/requirements.txt --target ${FUNCTION_DIR}

RUN rm ocr_deployement/requirements.txt

FROM public.ecr.aws/docker/library/python:buster

# Include global arg in this stage of the build
ARG FUNCTION_DIR
# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

# Copy in the built dependencies
COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]

CMD ["ocr_deployement/lambda_function.lambda_handler"]