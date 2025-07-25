FROM golang:1.19-alpine AS builder

WORKDIR /app

# Copia os arquivos de dependências
COPY go.mod go.sum ./
RUN go mod download

# Copia o restante do código fonte
COPY . .

# Compila a aplicação
# -o /app/main: define o output do binário
# CGO_ENABLED=0: desabilita CGO para criar um binário estático
# GOOS=linux GOARCH=amd64: especifica o sistema operacional e arquitetura
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/main ./cmd/api

# Estágio 2: Imagem final
FROM alpine:latest

WORKDIR /app

# Copia o binário compilado do estágio de build
COPY --from=builder /app/main .

# Copia os arquivos de banco de dados e configuração
COPY db ./db
COPY .env .

# Expõe a porta que a aplicação vai rodar
EXPOSE 8080

# Comando para rodar a aplicação
CMD ["/app/main"]