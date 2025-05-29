# 📱 ResenhaApp

**ResenhaApp** é um aplicativo mobile desenvolvido em Flutter com o objetivo de facilitar e padronizar o preenchimento de resenhas operacionais no turno de serviço policial.

> 🚔 De policial para policial, sem vínculos institucionais.

---

## 🎯 Objetivo

Criado para otimizar o tempo dos profissionais da segurança pública, o ResenhaApp simplifica o processo de registro de ocorrências, organização de dados e envio da resenha final formatada por WhatsApp.

---

## 🛠 Funcionalidades

- ✅ Tela de dados iniciais (data, hora, local, natureza)
- 👮 Cadastro da equipe e apoios
- 👤 Inserção de envolvidos (PMs, vítimas, autores, testemunhas)
- 🚗 Cadastro de veículos e objetos
- 📝 Geração automática de resenha com correção ortográfica
- 📤 Envio direto pelo WhatsApp

---

## 🔒 Segurança

- As requisições à OpenAI são feitas via **servidor intermediário (proxy)**, protegendo a chave de API.
- O arquivo `.env` **não é incluído** no repositório.
- Nenhuma informação pessoal ou sensível é armazenada.

---

## 📦 Instalação

### 📱 Instalar via APK (Android)

1. [Clique aqui para baixar o APK](https://github.com/lucz1k/resenha_app/raw/refs/heads/main/ResenhaApp%20(v.1.0%20BETA).apk) ou escaneie o QR Code abaixo:

   ![QR Code para Download](https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=https://github.com/lucz1k/resenha_app/raw/refs/heads/main/ResenhaApp%20(v.1.0%20BETA).apk)

2. Após o download:
    - Se aparecer “Instalação bloqueada”, vá em **Configurações > Segurança** e ative **Permitir desta fonte**
    - Instale normalmente
    - O ícone do app aparecerá na sua tela inicial

---

## 🔄 Atualizações

O app não possui atualizações automáticas por enquanto. Recomenda-se acompanhar novas versões via WhatsApp ou GitHub.

---

## 🧑‍💻 Desenvolvimento

- Desenvolvido em [Flutter](https://flutter.dev)
- Publicado via [Codemagic CI/CD](https://codemagic.io/)
- Backend intermediário em [Node.js + Express](https://expressjs.com/) para proteção da API

---

## ✅ Como compilar

Para desenvolvedores que desejam contribuir:

```bash
git clone https://github.com/lucz1k/resenha_app.git
cd resenha_app
flutter pub get
flutter run

🤝 Contribuição
Sugestões, correções ou ideias são sempre bem-vindas. Entre em contato via WhatsApp ou abra uma issue.
