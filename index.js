require("dotenv").config();
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

app.post("/corrigir", async (req, res) => {
  const { texto } = req.body;

  if (!texto || texto.trim().length < 20) {
    return res.status(400).json({ error: "Texto muito curto ou ausente." });
  }

  try {
    const resposta = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Corrija o português do texto policial mantendo a estrutura original e a capitalização natural das palavras. Não utilize caixa alta, exceto quando gramaticalmente necessário (como nomes próprios, inícios de frase ou siglas). Não remova nenhuma informação do texto, se houver palavras proibidas pelos termos de uso troque por -palavra bloqueada-.",
          },
          {
            role: "user",
            content: texto,
          },
        ],
        temperature: 0.5,
        max_tokens: 1000,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    res.json({ textoCorrigido: resposta.data.choices[0].message.content.trim() });
  } catch (error) {
    console.error(error.response?.data || error.message);
    res.status(500).json({ error: "Erro ao processar texto." });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`✅ Servidor rodando na porta ${PORT}`));
