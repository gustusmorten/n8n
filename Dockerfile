FROM node:16 as Custome-Nodes-Builder

WORKDIR /app

COPY n8n .

RUN echo $(ls -1 /tmp/dir)

RUN npm install

RUN npm run build

FROM n8nio/n8n

ARG PGHOST
ARG PGDATABASE
ARG PGPORT
ARG PGUSER
ARG PGPASSWORD


ARG USERNAME
ARG PASSWORD

ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_DATABASE=$PGDATABASE
ENV DB_POSTGRESDB_HOST=$PGHOST
ENV DB_POSTGRESDB_PORT=$PGPORT
ENV DB_POSTGRESDB_USER=$PGUSER
ENV DB_POSTGRESDB_PASSWORD=$PGPASSWORD

ENV N8N_BASIC_AUTH_ACTIVE=false
ENV N8N_BASIC_AUTH_USER=$USERNAME
ENV N8N_BASIC_AUTH_PASSWORD=$PASSWORD

COPY --from=Custome-Nodes-Builder app/dist /home/node/.n8n/custom/

CMD ["n8n", "start"]
