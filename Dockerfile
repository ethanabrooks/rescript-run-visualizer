FROM node:latest as build-deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn
COPY . ./
ARG ENDPOINT
ARG MAX_LOGS
ARG MAX_SWEEPS
ENV NODE_GRAPHQL_ENDPOINT=${ENDPOINT}
ENV NODE_MAX_SWEEPS=${MAX_SWEEPS}
ENV NODE_MAX_LOGS=${MAX_LOGS}
RUN yarn prod:build && mv ./static/* dist/

FROM nginx:latest
COPY --from=build-deps /app/dist /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
