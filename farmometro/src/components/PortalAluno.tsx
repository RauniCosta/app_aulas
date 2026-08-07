import React, { useState } from "react";
import { 
  Compass, 
  Send, 
  Award, 
  Clock, 
  Sparkles,
  Check, 
  Flame,
  UserCheck,
  Sun,
  Moon,
  Zap,
  Sword,
  Shirt,
  Scissors
} from "lucide-react";
import { Student, getZodiacTier, ZODIAC_LEVELS, AvatarConfig } from "../types";
import AnimeAvatar, { getDefaultAvatarConfig } from "./AnimeAvatar";
import { UserSession } from "./Gatekeeper";

interface PortalAlunoProps {
  students: Student[];
  studentActiveViewerId: string | null;
  setStudentActiveViewerId: (id: string | null) => void;
  customStudentPoints: number;
  setCustomStudentPoints: (v: number) => void;
  customStudentFeedbackText: string;
  setCustomStudentFeedbackText: (v: string) => void;
  ratingSuccessMessage: string | null;
  handleStudentChannelEnergy: (pointsAmount: number, description?: string) => void;
  getAlignmentColors: (alignment: string) => any;
  ppPoints: number;
  onUpdateStudentAvatarConfig: (studentId: string, config: AvatarConfig) => void;
  currentUserSession?: UserSession;
  onLogoutStudent?: () => void;
}

export default function PortalAluno({
  students,
  studentActiveViewerId,
  setStudentActiveViewerId,
  customStudentPoints,
  setCustomStudentPoints,
  customStudentFeedbackText,
  setCustomStudentFeedbackText,
  ratingSuccessMessage,
  handleStudentChannelEnergy,
  getAlignmentColors,
  ppPoints,
  onUpdateStudentAvatarConfig,
  currentUserSession,
  onLogoutStudent
}: PortalAlunoProps) {
  const [useCustomSlider, setUseCustomSlider] = useState(false);
  const [customizerTab, setCustomizerTab] = useState<"visual" | "cores" | "energia">("visual");

  const activeViewer = students.find((s) => s.id === studentActiveViewerId) || null;
  const isLockedStudent = currentUserSession?.role === "aluno";

  // Predefined channels
  const PRESETS_ENERGY = [
    { points: 100, label: "Bênção Solar 🌟", effect: "Elogio místico ao professor pelas aulas fascinantes.", bg: "from-amber-500 to-yellow-400 hover:opacity-95 text-slate-900" },
    { points: 50, label: "Sintonia Diária ✨", effect: "Agradecimento respeitoso por paciência e ajuda.", bg: "bg-amber-950/60 border border-amber-500/30 text-amber-400 hover:bg-amber-950" },
    { points: 0, label: "Sopro de Equilíbrio 🌾", effect: "Feedback neutro - rotina equilibrada e estável.", bg: "bg-slate-900 border border-slate-750 text-slate-300 hover:bg-slate-850" },
    { points: -50, label: "Vento de Alerta 🍂", effect: "Sinalizar sutilmente que as lições estão rápidas.", bg: "bg-purple-950/40 border border-purple-500/20 text-purple-400 hover:bg-purple-950/60" },
    { points: -100, label: "Temporal Sombrio ☄️", effect: "Reclamação anônima sobre rigor excessivo.", bg: "bg-purple-900 hover:bg-purple-800 text-purple-200" },
  ];

  // Helper to change customizer configs
  const handleUpdateConfigValue = (key: keyof AvatarConfig, val: string) => {
    if (!activeViewer) return;
    const currentConfig = activeViewer.avatarConfig || getDefaultAvatarConfig(activeViewer.name, activeViewer.id);
    const updated = {
      ...currentConfig,
      [key]: val,
    };
    onUpdateStudentAvatarConfig(activeViewer.id, updated);
  };

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300">
      
      {/* SELETOR DE IDENTIDADE DO ESTUDANTE */}
      <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800 text-left flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <span className="text-[10px] uppercase tracking-widest font-mono font-bold text-amber-500 flex items-center gap-1">
            <UserCheck className="h-3.5 w-3.5" /> {isLockedStudent ? "Conexão de Aluno Estabelecida" : "Canal Cósmico Estudantil (Modo ADM)"}
          </span>
          <h3 className="text-base font-black text-white mt-1">
            {isLockedStudent ? "Seu Portal de Aura Pessoal" : "Visão de Administrador Supremo"}
          </h3>
          <p className="text-xs text-slate-400 max-w-sm mt-0.5 leading-relaxed">
            {isLockedStudent 
              ? "Você está logado com sua credencial pessoal. Customize seu avatar e pontue as aulas do professor mestre."
              : "Selecione qualquer aluno da classe para inspecionar, personalizar ou emitir notas simuladas em nome dele."}
          </p>
        </div>

        {isLockedStudent ? (
          <div className="flex items-center gap-3 bg-emerald-950/30 border border-emerald-500/20 px-4 py-2.5 rounded-xl shrink-0">
            <div className="h-2 w-2 rounded-full bg-emerald-400 animate-pulse" />
            <div className="text-xs">
              <span className="text-slate-400 block text-[9px] uppercase tracking-wider font-mono font-bold">Autenticado como</span>
              <span className="font-black text-emerald-400 truncate max-w-[170px] block">{activeViewer?.name}</span>
            </div>
          </div>
        ) : (
          <div className="bg-slate-900 px-4 py-2 border border-slate-800 rounded-xl w-full sm:w-auto flex items-center gap-2">
            <span className="text-xs font-mono text-purple-400 font-bold shrink-0">ADMIN 👑 :</span>
            <select
              value={studentActiveViewerId || ""}
              onChange={(e) => setStudentActiveViewerId(e.target.value)}
              className="w-full bg-transparent text-xs font-black text-amber-400 focus:outline-none cursor-pointer pr-1"
            >
              {students.length === 0 ? (
                <option value="">Nenhum Aluno Cadastrado</option>
              ) : (
                students.map((s) => (
                  <option key={s.id} value={s.id} className="bg-slate-900 text-slate-100 text-xs">
                    {s.name}
                  </option>
                ))
              )}
            </select>
          </div>
        )}
      </div>

      {ratingSuccessMessage && (
        <div className="bg-emerald-950/80 border border-emerald-500/30 p-4 rounded-xl text-emerald-300 text-xs font-medium flex items-center gap-3 animate-bounce">
          <Sparkles className="h-5 w-5 text-emerald-400 shrink-0 animate-pulse" />
          <span>{ratingSuccessMessage}</span>
        </div>
      )}

      {activeViewer ? (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          
          {/* PROFILE COLUMN LEFT (col 5) */}
          <div className="lg:col-span-5 flex flex-col gap-6">
            
            {(() => {
              const info = getZodiacTier(activeViewer.points);
              const colors = getAlignmentColors(info.alignment);
              
              return (
                <div className={`p-6 rounded-2xl border ${colors.bg} ${colors.border} ${colors.pulse} transition relative overflow-hidden`}>
                  <div className="absolute top-0 right-0 p-3 text-[10px] font-black uppercase text-slate-500 font-mono tracking-widest opacity-20">
                    Sua Aura
                  </div>

                  <div className="flex flex-col items-center text-center mt-3">
                    {/* ENHANCED ANIME AVATAR WITH FLOATING ZODIAC EMBLEM */}
                    <div className="relative mb-2">
                      <AnimeAvatar student={activeViewer} size="lg" />
                      <span className="absolute -bottom-1 -right-1 text-2xl bg-slate-950 border border-slate-850 h-9 w-9 rounded-full flex items-center justify-center leading-none shadow-xl">
                        {info.emoji}
                      </span>
                    </div>

                    <h3 className="text-lg font-black text-white mt-4">{activeViewer.name}</h3>
                    <p className="text-xs font-bold text-amber-500 mt-1">{info.level.name}</p>
                    
                    <span className={`px-2.5 py-0.5 rounded-full text-[10px] uppercase font-bold tracking-wider mt-3 ${colors.badge}`}>
                      {info.fullName}
                    </span>

                    <p className="text-xs text-slate-300 leading-relaxed mt-4 bg-slate-950/50 p-3 rounded-xl border border-slate-900 max-w-sm font-normal">
                      "{info.level.description}"
                    </p>
                  </div>

                  {/* LEVEL GAUGES PROGRESS BAR */}
                  <div className="mt-6 pt-5 border-t border-slate-800/40">
                    <div className="flex justify-between text-[10px] text-slate-400 font-mono mb-1.5">
                      <span>Progresso da Aura</span>
                      <span>{info.progressPercent}%</span>
                    </div>
                    <div className="w-full bg-slate-950 border border-slate-850 h-3 rounded-full p-0.5">
                      <div 
                        className={`h-full rounded-full transition-all duration-500 ${info.alignment === "Celestial" ? "bg-amber-400" : info.alignment === "Sombrio" ? "bg-purple-500" : "bg-slate-600"}`}
                        style={{ width: `${info.progressPercent}%` }}
                      />
                    </div>
                    <div className="flex justify-between text-[9px] text-slate-500 mt-1 font-mono">
                      <span>{activeViewer.points} pts</span>
                      <span>Próximo nível</span>
                    </div>
                  </div>
                </div>
              );
            })()}

            {/* INTERACTIVE AVATAR CUSTOMIZER FORGE */}
            {(() => {
              const currentConfig = activeViewer.avatarConfig || getDefaultAvatarConfig(activeViewer.name, activeViewer.id);
              const info = getZodiacTier(activeViewer.points);
              const isEvolved = info.index > 0;

              return (
                <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800 text-left">
                  <div className="flex items-center gap-2 mb-3">
                    <Sparkles className="h-4 w-4 text-amber-500" />
                    <h3 className="font-sans font-black text-sm text-white">Forja da Alma & Customização</h3>
                  </div>
                  <p className="text-[11px] text-slate-400 leading-relaxed mb-4">
                    Ajuste seus materiais místicos para moldar seu avatar.
                    {!isEvolved && (
                      <span className="text-amber-500 font-medium block mt-1">
                        🔒 Evolua sua Aura (+100 pts) para ativar transformações DBZ/One Piece!
                      </span>
                    )}
                  </p>

                  {/* Customizing Tabs */}
                  <div className="flex bg-slate-900 p-1 rounded-lg border border-slate-850 gap-1 mb-4 text-xs font-bold">
                    <button
                      onClick={() => setCustomizerTab("visual")}
                      className={`flex-1 py-1 rounded-md transition ${customizerTab === "visual" ? "bg-amber-500 text-slate-950" : "text-slate-400 hover:text-slate-200"}`}
                    >
                      Classe & Cabelo
                    </button>
                    <button
                      onClick={() => setCustomizerTab("cores")}
                      className={`flex-1 py-1 rounded-md transition ${customizerTab === "cores" ? "bg-amber-500 text-slate-950" : "text-slate-400 hover:text-slate-200"}`}
                    >
                      Paleta de Cores
                    </button>
                    <button
                      onClick={() => setCustomizerTab("energia")}
                      className={`flex-1 py-1 rounded-md transition ${customizerTab === "energia" ? "bg-amber-500 text-slate-950" : "text-slate-400 hover:text-slate-200"}`}
                    >
                      Armamento & Aura
                    </button>
                  </div>

                  {/* Core Attribute Controls */}
                  <div className="space-y-4">
                    {customizerTab === "visual" && (
                      <>
                        {/* Archetype */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Arquétipo Espiritual</label>
                          <div className="grid grid-cols-2 gap-1.5">
                            {[
                              { id: "saiyan", label: "Saiyajin 🥋" },
                              { id: "ninja", label: "Shinobi 🥷" },
                              { id: "pirate", label: "Pirata 🏴‍☠️" },
                              { id: "shinigami", label: "Ceifador ⚔️" },
                              { id: "cyborg", label: "Androide 🤖" }
                            ].map((a) => (
                              <button
                                key={a.id}
                                onClick={() => handleUpdateConfigValue("archetype", a.id)}
                                className={`py-1 px-2.5 rounded-lg text-left text-[11px] font-bold transition flex items-center justify-between ${currentConfig.archetype === a.id ? "bg-amber-500/10 text-amber-400 border border-amber-500/30 font-black" : "bg-slate-900 border border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span>{a.label}</span>
                                {currentConfig.archetype === a.id && <Check className="h-3 w-3 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* HairStyle */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Estilo de Cabelo</label>
                          <div className="grid grid-cols-2 gap-1.5">
                            {[
                              { id: "spiky", label: "Extremo (SSJ) ⚡" },
                              { id: "long", label: "Longo Divino 🌊" },
                              { id: "curly", label: "Ondulado Sol 🌀" },
                              { id: "short", label: "Guerreiro Clássico ✂" },
                              { id: "bald", label: "Sshiny Careca ☀️" }
                            ].map((h) => (
                              <button
                                key={h.id}
                                onClick={() => handleUpdateConfigValue("hairStyle", h.id)}
                                className={`py-1 px-2.5 rounded-lg text-left text-[11px] font-bold transition flex items-center justify-between ${currentConfig.hairStyle === h.id ? "bg-amber-500/10 text-amber-400 border border-amber-500/30 font-black" : "bg-slate-900 border border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span>{h.label}</span>
                                {currentConfig.hairStyle === h.id && <Check className="h-3 w-3 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        </div>
                      </>
                    )}

                    {customizerTab === "cores" && (
                      <>
                        {/* HairColor */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Poder do Cabelo (Cromaticidade)</label>
                          <div className="grid grid-cols-4 gap-1.5">
                            {[
                              { id: "yellow", label: "SSJ", hex: "#fbbf24" },
                              { id: "blue", label: "Blue", hex: "#06b6d4" },
                              { id: "white", label: "UIT", hex: "#e2e8f0" },
                              { id: "red", label: "God", hex: "#ef4444" },
                              { id: "black", label: "Base", hex: "#1e293b" },
                              { id: "green", label: "Zoro", hex: "#10b981" },
                              { id: "purple", label: "Hakai", hex: "#a855f7" },
                              { id: "cyan", label: "Vite", hex: "#22d3ee" }
                            ].map((c) => (
                              <button
                                key={c.id}
                                onClick={() => handleUpdateConfigValue("hairColor", c.id)}
                                className={`p-1.5 rounded-lg border text-center transition flex flex-col items-center justify-center gap-1 ${currentConfig.hairColor === c.id ? "border-amber-400 bg-amber-500/10 text-amber-400" : "bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span className="h-4.5 w-4.5 rounded-full block border border-slate-755/50" style={{ backgroundColor: c.hex }} />
                                <span className="text-[9px] font-black uppercase font-mono">{c.label}</span>
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* OutfitColor */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Cor do Kimono / Manto</label>
                          <div className="grid grid-cols-3 gap-1.5">
                            {[
                              { id: "orange", label: "Hermit 🧡", hex: "#f97316" },
                              { id: "dark", label: "Robe 🖤", hex: "#1e1b4b" },
                              { id: "red", label: "Crimson ❤️", hex: "#991b1b" },
                              { id: "blue", label: "Classic 💙", hex: "#1d4ed8" },
                              { id: "white", label: "Spiritual 🤍", hex: "#f8fafc" },
                              { id: "gold", label: "Divine 💛", hex: "#d97706" }
                            ].map((o) => (
                              <button
                                key={o.id}
                                onClick={() => handleUpdateConfigValue("outfitColor", o.id)}
                                className={`py-1 px-2 rounded-lg text-[10px] font-bold border transition flex items-center gap-1.5 ${currentConfig.outfitColor === o.id ? "border-amber-400 bg-amber-500/10 text-amber-400" : "bg-slate-900 border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span className="h-3 w-3 rounded-full shrink-0 block border border-slate-700" style={{ backgroundColor: o.hex }} />
                                <span className="truncate">{o.label}</span>
                              </button>
                            ))}
                          </div>
                        </div>
                      </>
                    )}

                    {customizerTab === "energia" && (
                      <>
                        {/* Weapon / Accessory */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Armamento Místico</label>
                          <div className="grid grid-cols-2 gap-1.5">
                            {[
                              { id: "none", label: "Nenhum 📦" },
                              { id: "sword", label: "Espada Ceifadora 🗡️" },
                              { id: "headband", label: "Protetor da Vila 🍥" },
                              { id: "scarf", label: "Cachecol Rubro 🧣" },
                              { id: "energy_ball", label: "Esfera de Chakra 🔮" },
                              { id: "eye_patch", label: "Tapa-Olho Pirata 👁️" }
                            ].map((ac) => (
                              <button
                                key={ac.id}
                                onClick={() => handleUpdateConfigValue("accessory", ac.id)}
                                className={`py-1 px-2.5 rounded-lg text-left text-[11px] font-bold transition flex items-center justify-between ${currentConfig.accessory === ac.id ? "bg-amber-500/10 text-amber-400 border border-amber-500/30 font-black" : "bg-slate-900 border border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span>{ac.label}</span>
                                {currentConfig.accessory === ac.id && <Check className="h-3 w-3 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        </div>

                        {/* Background Aura Preference */}
                        <div>
                          <label className="text-[9px] font-black uppercase tracking-wider text-slate-400 font-mono block mb-1.5">Preciência da Aura Cósmica</label>
                          <div className="grid grid-cols-2 gap-1.5">
                            {[
                              { id: "auto", label: "Variação de Sintonia ⚛️" },
                              { id: "flames", label: "Chamas Flamejantes 🔥" },
                              { id: "lightning", label: "Raios Tempestuosos ⚡" },
                              { id: "ki", label: "Chakra Concentrado ☄️" },
                              { id: "none", label: "Ocultar Efeitos 🔇" }
                            ].map((au) => (
                              <button
                                key={au.id}
                                onClick={() => handleUpdateConfigValue("backgroundAura", au.id)}
                                className={`py-1 px-2.5 rounded-lg text-left text-[11px] font-bold transition flex items-center justify-between ${currentConfig.backgroundAura === au.id ? "bg-amber-500/10 text-amber-400 border border-amber-500/30 font-black" : "bg-slate-900 border border-slate-800 text-slate-400 hover:bg-slate-850"}`}
                              >
                                <span className="truncate">{au.label}</span>
                                {currentConfig.backgroundAura === au.id && <Check className="h-3 w-3 shrink-0" />}
                              </button>
                            ))}
                          </div>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              );
            })()}

            {/* MY CHRONOLOGICAL DIARY timelline */}
            <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800">
              <h3 className="font-sans font-black text-sm text-white mb-4 flex items-center gap-1.5">
                <Clock className="h-4 w-4 text-amber-500" />
                Seu Diário Cósmico de Feedbacks
              </h3>

              {activeViewer.history.length === 0 ? (
                <p className="text-center py-8 text-xs text-slate-500 bg-slate-900/15 rounded-xl border border-dashed border-slate-900">
                  Aura em estado puro. Solicite orientações ao professor para preencher o diário!
                </p>
              ) : (
                <div className="border-l border-slate-900 pl-4 flex flex-col gap-4">
                  {activeViewer.history.map((h) => {
                    const isPos = h.points >= 0;
                    return (
                      <div key={h.id} className="relative text-left">
                        <span className={`absolute -left-[21px] top-1 w-2 h-2 rounded-full border border-slate-950 ${isPos ? "bg-amber-500" : "bg-purple-600"}`} />
                        <div className="bg-slate-900/50 p-3 rounded-lg border border-slate-900">
                          <div className="flex justify-between items-center text-[9px] text-slate-500 font-mono mb-1.5">
                            <span>📅 {h.date}</span>
                            <span className={isPos ? "text-amber-400 font-bold" : "text-purple-400 font-bold"}>
                              {isPos ? `+${h.points}` : h.points} pts
                            </span>
                          </div>
                          <blockquote className="text-xs text-slate-300 italic">"{h.description}"</blockquote>
                          {h.feedback && (
                            <p className="text-[10px] text-amber-400/90 leading-relaxed font-normal bg-slate-950/60 p-2 rounded mt-2 border border-slate-850">
                              💌 Conselho: {h.feedback}
                            </p>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

          </div>

          {/* RATING MODULE RIGHT (col 7) */}
          <div className="lg:col-span-7 flex flex-col gap-6">
            
            <div className="bg-slate-950 p-6 rounded-2xl border border-slate-800 shadow-xl">
              <span className="text-[10px] uppercase tracking-widest font-mono font-black text-amber-500 flex items-center gap-1">
                <Compass className="h-3.5 w-3.5 animate-spin-slow" /> Canal de Sopro de Ressonância
              </span>
              <h3 className="text-lg font-black text-white mt-1">Pontuar o Professor (Seu Efeito no Mestre)</h3>
              <p className="text-xs text-slate-400 max-w-xl leading-relaxed mt-1">
                Seus professores buscam guiar as aulas em perfeito equilíbrio acadêmico. Você, como estudante cósmico, possui o dom de canalizar vibrações para orientar o selo místico de Aura deles!
              </p>

              {/* CURRENT PROFESSOR RATING INDICATION */}
              <div className="bg-slate-900 p-4 rounded-xl border border-slate-800/80 my-5 text-center sm:text-left flex flex-col sm:flex-row items-center justify-between gap-4">
                <div>
                  <h4 className="text-xs font-black text-white">Pontos Atuais de Avaliação (PP)</h4>
                  <p className="text-[10px] text-slate-400 leading-snug mt-0.5">Influenciado coletivamente pelas notas dos alunos da turma.</p>
                </div>
                <div className="bg-slate-950 px-4.5 py-2 rounded-lg border border-amber-500/10 font-mono text-center shrink-0">
                  <span className={`text-xl font-black ${ppPoints >= 0 ? "text-amber-400" : "text-purple-400"}`}>
                    {ppPoints > 0 ? `+${ppPoints}` : ppPoints} pts
                  </span>
                </div>
              </div>

              {/* CHANNEL PRESETS BULLETS */}
              <div className="flex flex-col gap-3">
                <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500 font-mono block">Escolha uma Vibração de Energia</span>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  {PRESETS_ENERGY.map((preset, i) => (
                    <button
                      key={i}
                      onClick={() => handleStudentChannelEnergy(preset.points, preset.effect)}
                      className={`p-3.5 rounded-xl text-left transition flex flex-col justify-between h-28 ${preset.bg}`}
                    >
                      <div>
                        <span className="text-[11px] font-black uppercase tracking-wider block">{preset.label}</span>
                        <p className="text-[9px] mt-1 leading-normal opacity-85">{preset.effect}</p>
                      </div>
                      <span className="text-xs font-black font-mono block text-right mt-2">
                        {preset.points > 0 ? `+${preset.points}` : preset.points} pts
                      </span>
                    </button>
                  ))}
                </div>
              </div>

              {/* CUSTOM CRITIQUE FIELD */}
              <div className="mt-6 pt-5 border-t border-slate-900 text-left">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-slate-500 font-mono block">Canalizar Orientação Customizada</span>
                  <button 
                    onClick={() => setUseCustomSlider(!useCustomSlider)}
                    className="text-[9px] text-amber-400 uppercase font-black tracking-wider border border-amber-500/20 px-2 py-0.5 rounded-md hover:bg-amber-950/20"
                  >
                    {useCustomSlider ? "Voltar Presets" : "Usar Escala Livre"}
                  </button>
                </div>

                {useCustomSlider && (
                  <div className="bg-slate-900 p-4.5 rounded-xl border border-slate-850/80 mb-4 animate-in slide-in-from-top duration-200">
                    <div className="flex justify-between items-center text-xs font-mono mb-2">
                      <span className="text-slate-400">Pontos a Canalizar:</span>
                      <span className={`font-black ${customStudentPoints >= 0 ? "text-amber-400" : "text-purple-400"}`}>
                        {customStudentPoints > 0 ? `+${customStudentPoints}` : customStudentPoints} pts
                      </span>
                    </div>
                    <input
                      type="range"
                      min="-200"
                      max="200"
                      value={customStudentPoints}
                      onChange={(e) => setCustomStudentPoints(Number(e.target.value))}
                      className="w-full h-1 bg-slate-950 rounded-lg appearance-none cursor-pointer accent-amber-500 mb-2"
                    />
                    <div className="flex justify-between text-[9px] text-slate-500 font-mono">
                      <span>-200 (Crítica)</span>
                      <span>0 (Neutro)</span>
                      <span>+200 (Bênção)</span>
                    </div>
                  </div>
                )}

                <div className="flex gap-2">
                  <input
                    type="text"
                    placeholder="Mensagem de feedback ao professor (Opcional)..."
                    value={customStudentFeedbackText}
                    onChange={(e) => setCustomStudentFeedbackText(e.target.value)}
                    className="flex-1 bg-slate-900 border border-slate-800 focus:border-slate-750 p-2.5 rounded-lg text-xs placeholder-slate-500 text-slate-100 focus:outline-none"
                  />
                  <button
                    onClick={() => {
                      const finalPts = useCustomSlider ? customStudentPoints : 100;
                      handleStudentChannelEnergy(finalPts, customStudentFeedbackText || "Elogio de sintonia cósmica.");
                    }}
                    className="px-4.5 bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 rounded-lg text-xs font-bold uppercase tracking-wider shadow shadow-amber-500/10 flex items-center justify-center.5 shrink-0 hover:opacity-95"
                  >
                    <Send className="h-3.5 w-3.5" />
                  </button>
                </div>
              </div>

            </div>

          </div>

        </div>
      ) : (
        <div className="bg-slate-950 rounded-2xl border border-slate-800 p-12 text-center h-48 flex flex-col justify-center items-center">
          <Flame className="h-8 w-8 text-amber-500 animate-bounce mb-2" />
          <h4 className="text-white text-sm font-bold">Nenhum Estudante Ativo Conectado</h4>
          <p className="text-slate-400 text-xs mt-1">Selecione seu nome de perfil no cabeçalho acima para carregar sua árvore mística.</p>
        </div>
      )}

    </div>
  );
}
