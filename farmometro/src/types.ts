/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export interface ActionRecord {
  id: string;
  date: string;
  description: string;
  points: number;
  justification: string;
  feedback: string;
}

export interface AvatarConfig {
  archetype: string;     // 'saiyan' | 'ninja' | 'pirate' | 'shinigami' | 'cyborg'
  hairStyle: string;     // 'spiky' | 'long' | 'bald' | 'short' | 'curly'
  hairColor: string;     // 'yellow' | 'blue' | 'white' | 'red' | 'black' | 'green' | 'purple' | 'cyan'
  accessory: string;     // 'none' | 'sword' | 'headband' | 'scarf' | 'energy_ball' | 'eye_patch'
  outfitColor: string;   // 'orange' | 'dark' | 'red' | 'blue' | 'white' | 'gold'
  backgroundAura: string;// 'auto' | 'ki' | 'lightning' | 'flames' | 'none'
}

export interface Student {
  id: string;
  name: string;
  points: number;
  history: ActionRecord[];
  avatarSeed: string; // for consistent zodiac or simple avatar rendering
  avatarConfig?: AvatarConfig;
}

export interface Turma {
  id: string;
  nome: string;
  criadoEm: string;
  pontosProfessor: number; // PP (Pontos do Professor dados pelos alunos nesta turma)
  students: Student[];
}

export interface ZodiacLevel {
  name: string;
  emoji: string;
  minPoints: number;
  maxPoints: number;
  description: string;
}

export const ZODIAC_LEVELS: ZodiacLevel[] = [
  { name: "Aura Neutra", emoji: "⚪", minPoints: 0, maxPoints: 100, description: "A aura está em perfeito equilíbrio e serenidade, pronta para se inclinar ao caminho brilhante." },
  { name: "Rato", emoji: "🐭", minPoints: 100, maxPoints: 200, description: "O Rato traz inteligência, adaptabilidade e os primeiros passos de astúcia no caminho da virtude." },
  { name: "Galo", emoji: "🐓", minPoints: 200, maxPoints: 350, description: "O Galo representa o despertar, a honestidade, pontualidade e o brilho do sol nascente." },
  { name: "Coelho", emoji: "🐰", minPoints: 350, maxPoints: 550, description: "O Coelho simboliza a gentileza, a paciência extra-sensorial e a diplomacia pacífica." },
  { name: "Cabra", emoji: "🐐", minPoints: 550, maxPoints: 800, description: "A Cabra evoca a arte, a sensibilidade, a harmonia coletiva e a compaixão pura." },
  { name: "Porco", emoji: "🐷", minPoints: 800, maxPoints: 1100, description: "O Porco traz generosidade sem limites, honestidade imbatível e alegria de viver." },
  { name: "Cavalo", emoji: "🐴", minPoints: 1100, maxPoints: 1500, description: "O Cavalo representa determinação indomável, espírito livre, vivacidade e avanço rápido." },
  { name: "Boi", emoji: "🐂", minPoints: 1500, maxPoints: 2000, description: "O Boi simboliza a resiliência inquebrável, força silenciosa, confiabilidade e trabalho árduo." },
  { name: "Macaco", emoji: "🐒", minPoints: 2000, maxPoints: 3000, description: "O Macaco evoca a genialidade, versatilidade brilhante, curiosidade livre e diversão saudável." },
  { name: "Cão", emoji: "🐶", minPoints: 3000, maxPoints: 5999, description: "O Cão emana lealdade inabalável, senso de justiça aguçado, proteção e empatia verdadeira." },
  { name: "Serpente", emoji: "🐍", minPoints: 6000, maxPoints: 6999, description: "A Serpente representa sabedoria profunda, intuição misteriosa, elegância e graça celestial." },
  { name: "Tigre", emoji: "🐯", minPoints: 7000, maxPoints: 7999, description: "O Tigre irradia bravura heroica, liderança natural, paixão viva e poder inspirador." },
  { name: "Dragão", emoji: "🐉", minPoints: 8000, maxPoints: Infinity, description: "O Dragão é a manifestação suprema do poder espiritual. Aura lendária, nobreza infinita e sabedoria cósmica!" }
];

export function getZodiacTier(points: number) {
  const absPoints = Math.abs(points);
  const alignment = points > 100 ? "Celestial" : points < -100 ? "Sombrio" : "Neutro";

  // Find matching level
  const levelIndex = ZODIAC_LEVELS.findIndex(
    (lvl) => absPoints >= lvl.minPoints && absPoints < lvl.maxPoints
  );

  const currentLevel = levelIndex !== -1 ? ZODIAC_LEVELS[levelIndex] : ZODIAC_LEVELS[ZODIAC_LEVELS.length - 1];
  const nextLevel = levelIndex !== -1 && levelIndex < ZODIAC_LEVELS.length - 1 ? ZODIAC_LEVELS[levelIndex + 1] : null;

  // Calculate progress percent to next level
  let progressPercent = 100;
  if (nextLevel) {
    const range = currentLevel.maxPoints - currentLevel.minPoints;
    const currentProgress = absPoints - currentLevel.minPoints;
    progressPercent = Math.min(Math.floor((currentProgress / range) * 100), 100);
  }

  // Generate localized titles
  let label = currentLevel.name;
  if (alignment === "Celestial") {
    label += " Celestial";
  } else if (alignment === "Sombrio") {
    label += " Sombrio";
  }

  return {
    level: currentLevel,
    nextLevel,
    progressPercent,
    alignment,
    fullName: label,
    emoji: currentLevel.emoji,
    index: levelIndex !== -1 ? levelIndex : ZODIAC_LEVELS.length - 1
  };
}
