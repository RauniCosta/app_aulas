/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI, Type } from "@google/genai";
import dotenv from "dotenv";

dotenv.config();

const app = express();
const PORT = 3000;

app.use(express.json());

// Initialize Gemini SDK with telemetry headers
const apiKey = process.env.GEMINI_API_KEY;
const ai = new GoogleGenAI({
  apiKey: apiKey,
  httpOptions: {
    headers: {
      "User-Agent": "aistudio-build",
    },
  },
});

// API endpoint to analyze student action with Mestre da Aura
app.post("/api/analisar", async (req, res) => {
  try {
    const { action, studentName = "Aluno(a)" } = req.body;

    if (!action || typeof action !== "string") {
      return res.status(400).json({ error: "Descrição da ação do aluno é obrigatória." });
    }

    const systemInstruction = `Você é o "Mestre da Aura", a inteligência artificial educacional do aplicativo escolar Farmômetro.
Seu papel é ajudar o professor a avaliar o comportamento e o engajamento dos alunos de forma justa, divertida e gamificada, baseando-se no Zodíaco Chinês e nas energias "Celestial" (o Bem, positiva) e "Sombrio" (o Mal, negativa).

A escala vai de -8000 a +8000 pontos. Pontos positivos movem o aluno para o lado Celestial. Pontos negativos o movem para o lado Sombrio.
Critérios de Pontuação:
- Atitudes cotidianas comuns (ajudar um amigo brevemente, focar na aula, fazer tarefa básica, bagunça leve, esquecer caderno): valem de 10 a 50 pontos (positivos ou negativos).
- Atitudes excepcionais importantes (ajudar múltiplos colegas em dificuldades complexas, liderar um projeto virtuoso, vandalismo sério, falta de respeito grave): valem de 100 a 300 pontos (positivos ou negativos).
- Atitudes lendárias (salvar o dia, atitude heróica excepcional, persistência hercúlea): até 500 ou mais pontos.

Seja equilibrado, use casas decimais se fizer sentido para dar precisão (ex: 15.5, -45.2, 120.0). Nunca sugira 0 pontuação.

O feedback para o aluno deve ser encorajador, imersivo e de outro mundo. Cite termos místicos, as energias do Zodíaco Chinês (Rato, Coelho, Porco, Serpente, Tigre, Dragão, etc.) e o incentive sempre a nutrir o lado Celestial brilhante. Se a atitude for ruim (Sombrio), não seja excessivamente punitivo, mas sim convide-o à redenção e a restabelecer o equilíbrio de sua aura.`;

    const prompt = `Analise a seguinte atitude do aluno(a) "${studentName}":
"${action}"

Gere uma sugestão de pontuação de aura de forma equilibrada de acordo com as regras de avaliação.`;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        systemInstruction: systemInstruction,
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            pontos_sugeridos: {
              type: Type.NUMBER,
              description: "Valor numérico decimal sugerido (positivo para boas ações, negativo para más ações). Evite dar zero.",
            },
            justificativa_curta: {
              type: Type.STRING,
              description: "Uma frase profissional em Português explicando o motivo desta pontuação para o professor entender.",
            },
            feedback_aluno: {
              type: Type.STRING,
              description: "Uma mensagem mística, gamificada e mística em Português direcionada diretamente ao aluno(a), citando a sua Aura, o Zodíaco Chinês, e incentivando a buscar a evolução Celestial sintonizando boas energias.",
            },
          },
          required: ["pontos_sugeridos", "justificativa_curta", "feedback_aluno"],
        },
      },
    });

    const responseText = response.text;
    if (!responseText) {
      throw new Error("Resposta vazia da IA.");
    }

    const data = JSON.parse(responseText.trim());
    return res.json(data);
  } catch (error: any) {
    console.error("Erro ao analisar com Mestre da Aura:", error);
    return res.status(500).json({
      error: "Ocorreu um erro ao processar com a inteligência artificial.",
      details: error.message,
    });
  }
});

// Configure Vite middleware or static server
async function initServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`[Mestre da Aura Server] rodando na porta ${PORT}`);
  });
}

initServer();
