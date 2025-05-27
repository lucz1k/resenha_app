# 📱 ResenhaApp

Aplicativo desenvolvido para facilitar e padronizar o preenchimento de **resenhas operacionais policiais**, com integração de voz, salvamento automático de rascunhos e geração de texto final estruturado.

---

## ✨ Funcionalidades

- 📝 Formulários de preenchimento de dados operacionais
- 🔄 Salvamento automático de rascunhos com SharedPreferences
- 🧠 Correção gramatical via API OpenAI
- 🎙️ Ditado por voz para preenchimento do histórico
- 📋 Copiar resenha final com formatação pronta para envio por WhatsApp
- 💾 Botões de “Salvar como padrão” para dados recorrentes

---

## 🚀 Como executar

1. Clone o repositório:

```bash
git clone https://github.com/lucz1k/resenha_app.git
cd resenha_app
Instale as dependências:

bash
Copiar
Editar
flutter pub get
Crie um arquivo .env na raiz do projeto com sua chave da OpenAI:

env
Copiar
Editar
OPENAI_API_KEY=sua_chave_aqui

Execute o app:

bash
Copiar
Editar
flutter run
📦 Tecnologias utilizadas
Flutter 3.x

Dart

SharedPreferences

HTTP + dotenv

SpeechToText

OpenAI API (GPT-3.5-turbo)

🔐 Observações
O arquivo .env está no .gitignore e não é enviado para o repositório por segurança.
Nunca compartilhe sua chave da OpenAI publicamente.

🧑‍💻 Desenvolvedor
Asp Of PM Artigiani
GitHub: lucz1k

📄 Licença
Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.
