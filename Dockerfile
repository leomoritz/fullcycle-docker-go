## ETAPA 1 (Multistage Building) ##

# Define a imagem base para esta nova imagem a ser gerada
FROM golang:alpine3.21 AS builder

# Instala o upx e strip para compreensão e redução do binário
RUN apk add --no-cache upx binutils

# Cria um novo diretório chamado app para manter os códigos fontes
WORKDIR /app

# Copia todos os arquivos do diretório atual para /app
COPY . .

# Executar comandos para buildar a aplicação
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags "-s -w" -o godocker main.go

# Strip binário para remover informações desnecessárias
RUN strip godocker

# Comprime o binário gerado
RUN upx --ultra-brute godocker

## ETAPA 2 (Multistage Building)##
FROM scratch

# Cria um novo diretório chamado app para manter a aplicação
WORKDIR /app

# Copia os arquivos da etapa 1 que estão em /app para dentro da etapa 2 na pasta com mesmo nome /app
COPY --from=builder /app/godocker ./

# Cria um usuário não-root e grupo
#RUN addgroup -S godockergroup && adduser -S godockeruser -G godockergroup

# Ajusta permissões do diretório /app e binário godocker
#RUN chown -R godockeruser:godockergroup /app && chmod +x /app/godocker

# Por segurança, definimos um usuário sem privilégios root para a imagem
#USER godockeruser:godockergroup

# Libera a porta para execução no container
EXPOSE 8080

# Define comandos padrão imutável para executar o binário
ENTRYPOINT ["./godocker"]
