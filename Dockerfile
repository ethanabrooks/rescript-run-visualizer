FROM node:latest as build-deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn
COPY . ./
ARG NODE_GRAPHQL_ENDPOINT
ARG NODE_MAX_LOGS
ARG NODE_MAX_SWEEPS
ENV NODE_GRAPHQL_ENDPOINT=${NODE_GRAPHQL_ENDPOINT}
ENV NODE_MAX_SWEEPS=${NODE_MAX_SWEEPS}
ENV NODE_MAX_LOGS=${NODE_MAX_LOGS}
RUN yarn prod:build && mv ./static/* dist/

FROM nginx:latest
COPY --from=build-deps /app/dist /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
