FROM node:16 as Custome-Nodes-Builder

WORKDIR /app

COPY n8n-render ./

RUN echo $(ls )

RUN npm install -g npm@6

RUN npm install -g pnpm

RUN pnpm install --frozen-lockfile

RUN pnpm build

RUN echo $(ls )

FROM n8nio/n8n

ARG DB_POSTGRESDB_HOST
ARG DB_POSTGRESDB_DATABASE
ARG DB_POSTGRESDB_USER
ARG DB_POSTGRESDB_PASSWORD


ARG USERNAME
ARG PASSWORD

ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_DATABASE=$DB_POSTGRESDB_DATABASE
ENV DB_POSTGRESDB_HOST=$DB_POSTGRESDB_HOST
ENV DB_POSTGRESDB_USER=$DB_POSTGRESDB_USER
ENV DB_POSTGRESDB_PASSWORD=$DB_POSTGRESDB_PASSWORD

ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_BASIC_AUTH_USER=$USERNAME
ENV N8N_BASIC_AUTH_PASSWORD=$PASSWORD

COPY --from=Custome-Nodes-Builder app/packages /home/node/.n8n/custom/

COPY --from=Custome-Nodes-Builder /home/node /usr/local/lib/node_modules/n8n

# RUN ln -s /usr/local/lib/node_modules/n8n/packages/cli/bin/n8n /usr/local/bin/n8n

# COPY docker/images/n8n-custom/docker-entrypoint.sh /

ENV NODE_ENV=production
# ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
COPY n8n-render/docker/images/n8n-custom/docker-entrypoint.sh /
USER node
ENV NODE_ENV=production
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
EXPOSE 5678
