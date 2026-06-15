# PYTHON_VERSION set by build.sh based on .tool-versions file
ARG PYTHON_VERSION=3.12

# Download and extract the secrets-lambda-extension
FROM public.ecr.aws/docker/library/alpine:latest AS extension
RUN mkdir -p /opt/secrets-lambda-extension && \
    wget https://github.com/CruGlobal/secrets-lambda-extension/releases/latest/download/secrets-lambda-extension-linux-amd64.tar.gz -q -O - |tar -xzC /opt/secrets-lambda-extension/

# PYTHON_VERSION set by build.sh based on .tool-versions file
ARG PYTHON_VERSION=3.12
# Use AWS Lambda Python base image for the final image
FROM public.ecr.aws/lambda/python:${PYTHON_VERSION}

# DataDog logs source
LABEL com.datadoghq.ad.logs='[{"source": "python"}]'

# Define GitHub Action Build Args
ARG PROJECT_NAME
ARG ENVIRONMENT
ARG BUILD_NUMBER

# Set environment variables for the Lambda function
ENV PROJECT_NAME=${PROJECT_NAME}
ENV ENVIRONMENT=${ENVIRONMENT}
ENV BUILD_NUMBER=${BUILD_NUMBER}

# Set the Lambda task root directory
WORKDIR ${LAMBDA_TASK_ROOT}

# Copy the secrets-lambda-extension from the extension stage and setup wrapper
COPY --from=extension /opt/secrets-lambda-extension /opt/secrets-lambda-extension
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/secrets-lambda-extension/secrets-wrapper

# Install application + DataDog dependencies (datadog-lambda, ddtrace).
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Setup DataDog metrics/logs: copy the lambda-extension layer, then have the
# DataDog handler wrap our handler. CMD points at DataDog's wrapper, and
# DD_LAMBDA_HANDLER names our actual handler (handler.py -> def handler()).
COPY --from=public.ecr.aws/datadog/lambda-extension:latest /opt/. /opt/
ENV DD_LAMBDA_HANDLER=handler.handler
CMD ["datadog_lambda.handler.handler"]

# Copy the application code
COPY . ${LAMBDA_TASK_ROOT}
