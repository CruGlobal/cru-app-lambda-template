# RUBY_VERSION set by build.sh based on .tool-versions file
ARG RUBY_VERSION=3.4

# Download and extract the secrets-lambda-extension
FROM public.ecr.aws/docker/library/alpine:latest AS extension
RUN mkdir -p /opt/secrets-lambda-extension && \
    wget https://github.com/CruGlobal/secrets-lambda-extension/releases/latest/download/secrets-lambda-extension-linux-amd64.tar.gz -q -O - |tar -xzC /opt/secrets-lambda-extension/

# RUBY_VERSION set by build.sh based on .tool-versions file
ARG RUBY_VERSION=3.4
# Use AWS Lambda Ruby base image for the final image
FROM public.ecr.aws/lambda/ruby:${RUBY_VERSION}

# DataDog logs source
LABEL com.datadoghq.ad.logs='[{"source": "ruby"}]'

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

# DataDog's ddtrace (pulled in by datadog-lambda) has native extensions that
# must be compiled, so install the build toolchain before `bundle install`.
RUN dnf install -y gcc gcc-c++ gmp-devel make && dnf clean all

# Install gems (datadog-lambda + ddtrace). There's no Gemfile.lock in a fresh
# template, so bundler resolves and writes one here.
COPY Gemfile ./
RUN bundle install --jobs 4 --retry 2

# Setup DataDog metrics/logs: copy the lambda-extension layer.
COPY --from=public.ecr.aws/datadog/lambda-extension:latest /opt/. /opt/

# Copy the application code
COPY . ${LAMBDA_TASK_ROOT}

# Boot the AWS Ruby runtime at handler.rb -> def handler(event:, context:).
# DataDog instrumentation is applied in code via Datadog::Lambda.wrap inside
# handler.rb (the gem's documented Ruby approach), so the standard AWS CMD
# below is correct and DataDog still captures traces/metrics.
#
# Alternatively, to let DataDog's wrapper drive the handler instead of the
# in-code wrap, drop the Datadog::Lambda.wrap block from handler.rb and use:
#   ENV DD_LAMBDA_HANDLER=handler.handler
#   CMD ["datadog_lambda/handler.handler"]
CMD ["handler.handler"]
