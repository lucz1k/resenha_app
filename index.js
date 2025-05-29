require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/chat', async (req, res) => {
  try {
    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      req.body,
      {
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        }
      }
    );
    res.json(response.data);
  } catch (error) {
    console.error("Erro no proxy:", error.response?.data || error.message);
    res.status(500).json({ error: "Erro na comunicação com a OpenAI." });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`✅ Proxy rodando em http://localhost:${port}`));