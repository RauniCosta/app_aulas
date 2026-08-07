import React, { useState } from "react";
import { 
  TrendingUp, 
  TrendingDown, 
  Award, 
  Search, 
  Sparkles,
  Sun,
  Moon,
  X,
  Users,
  Target,
  Flame,
  CalendarDays
} from "lucide-react";
import { Student, Turma, getZodiacTier } from "../types";
import AnimeAvatar from "./AnimeAvatar";

interface TurmaDashboardProps {
  activeTurma: Turma | null;
  students: Student[];
  averageAura: number;
  professorAura: number;
  professorZodiac: any;
  getAlignmentColors: (alignment: string) => any;
  setShowZodiacChart: (show: boolean) => void;
  ppPoints: number;
  handleUpdatePP: (val: number) => void;
}

export default function TurmaDashboard({
  activeTurma,
  students,
  averageAura,
  professorAura,
  professorZodiac,
  getAlignmentColors,
  setShowZodiacChart,
  ppPoints,
  handleUpdatePP
}: TurmaDashboardProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [alignmentFilter, setAlignmentFilter] = useState<"all" | "Celestial" | "Sombrio" | "Neutro">("all");
  const [selectedReviewStudent, setSelectedReviewStudent] = useState<Student | null>(null);

  const totalStudents = students.length;
  const celestiaisCount = students.filter((s) => getZodiacTier(s.points).alignment === "Celestial").length;
  const sombriosCount = students.filter((s) => getZodiacTier(s.points).alignment === "Sombrio").length;
  const neutrosCount = students.filter((s) => getZodiacTier(s.points).alignment === "Neutro").length;

  const sortedStudents = [...students].sort((a, b) => b.points - a.points);

  const filteredStudents = sortedStudents.filter((student) => {
    const matchesSearch = student.name.toLowerCase().includes(searchQuery.toLowerCase());
    const tier = getZodiacTier(student.points);
    const matchesAlignment = alignmentFilter === "all" || tier.alignment === alignmentFilter;
    return matchesSearch && matchesAlignment;
  });

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300">
      
      {/* COMPACT & MODERN OVERVIEW HUD */}
      <section className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        {/* PROFESSOR CARD */}
        <div className="lg:col-span-2 bg-gradient-to-r from-slate-950 to-slate-900/90 rounded-2xl border border-slate-800/80 p-5 shadow-lg relative overflow-hidden flex flex-col justify-between">
          <div className={`absolute -right-12 -bottom-12 h-32 w-32 rounded-full blur-3xl opacity-10 bg-gradient-to-tr ${
            professorZodiac.alignment === "Celestial" ? "from-amber-400 to-yellow-500" : professorZodiac.alignment === "Sombrio" ? "from-purple-500 to-violet-600" : "from-slate-500 to-slate-400"
          }`} />

          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative z-10 mb-4">
            <div className="flex items-center gap-3">
              <div className={`h-12 w-12 rounded-xl flex items-center justify-center text-2xl shrink-0 ${
                professorZodiac.alignment === "Celestial" 
                  ? "bg-amber-950/50 border border-amber-500/20 text-amber-400 text-shadow-glow" 
                  : professorZodiac.alignment === "Sombrio" 
                    ? "bg-purple-950/50 border border-purple-500/20 text-purple-400"
                    : "bg-slate-800 border border-slate-700 text-slate-300"
              }`}>
                {professorZodiac.emoji}
              </div>
              <div>
                <span className="text-[10px] font-bold uppercase tracking-widest text-amber-400 font-mono block">Mestre do Alinhamento</span>
                <h2 className="text-base font-black text-white leading-tight">Turma {activeTurma?.nome}</h2>
              </div>
            </div>

            <span className={`px-2.5 py-1 rounded-lg text-[10px] font-black uppercase tracking-wider ${
              professorZodiac.alignment === "Celestial" ? "bg-amber-950/85 text-amber-400 border border-amber-500/25 shadow-sm shadow-amber-500/5" : professorZodiac.alignment === "Sombrio" ? "bg-purple-950/85 text-purple-400 border border-purple-500/25 shadow-sm shadow-purple-500/5" : "bg-slate-800 text-slate-300"
            }`}>
              {professorZodiac.fullName}
            </span>
          </div>

          <div className="grid grid-cols-3 gap-3 bg-slate-950/60 p-3 rounded-xl border border-slate-900 relative z-10">
            <div className="text-center sm:text-left">
              <span className="text-[8px] sm:text-[9px] uppercase font-bold tracking-wider text-slate-500 font-mono block">Pontos Alunos (PP)</span>
              <span className="text-xs sm:text-sm font-black text-amber-400 font-mono leading-none mt-1 block">
                {ppPoints > 0 ? `+${ppPoints}` : ppPoints} pts
              </span>
            </div>
            <div className="text-center sm:text-left border-l border-slate-800/80 px-2 sm:px-3">
              <span className="text-[8px] sm:text-[9px] uppercase font-bold tracking-wider text-slate-500 font-mono block">Média Aura (MA)</span>
              <span className="text-xs sm:text-sm font-black text-slate-300 font-mono leading-none mt-1 block">
                {averageAura > 0 ? `+${averageAura}` : averageAura} pts
              </span>
            </div>
            <div className="text-center border-l border-slate-800/80 pl-2 sm:pl-3 bg-slate-950/40 rounded-r-lg">
              <span className="text-[8px] uppercase font-black tracking-widest text-slate-400 block font-mono">Aura do Professor</span>
              <span className={`text-xs sm:text-sm font-black font-mono leading-none mt-1 block ${professorAura >= 0 ? "text-amber-400" : "text-purple-400"}`}>
                {professorAura >= 0 ? `+${professorAura}` : professorAura}
              </span>
            </div>
          </div>
        </div>

        {/* METRICS SUMMARY IN ONE BIG BENTO */}
        <div className="bg-slate-900/40 rounded-2xl border border-slate-800/80 p-5 flex flex-col justify-between">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-1.5">
              <Users className="h-4 w-4 text-amber-500" />
              <span className="text-xs font-black uppercase text-slate-300">Sumário da Ressonância</span>
            </div>
            <span className="text-[10px] font-mono text-slate-500 bg-slate-950 px-2 py-0.5 rounded border border-slate-850">
              {totalStudents} Registros
            </span>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="bg-slate-950/50 p-2.5 rounded-xl border border-slate-900 flex items-center justify-between">
              <div>
                <span className="text-[8px] uppercase font-bold text-slate-500 font-mono block">Média da Sala</span>
                <span className={`text-sm font-black font-mono ${averageAura >= 0 ? "text-amber-400" : "text-purple-400 animate-pulse"}`}>
                  {averageAura > 0 ? `+${averageAura}` : averageAura}
                </span>
              </div>
              {averageAura >= 0 ? (
                <TrendingUp className="h-3.5 w-3.5 text-amber-500 shrink-0" />
              ) : (
                <TrendingDown className="h-3.5 w-3.5 text-purple-500 shrink-0" />
              )}
            </div>

            <div className="bg-slate-950/50 p-2.5 rounded-xl border border-slate-900 flex items-center justify-between">
              <div>
                <span className="text-[8px] uppercase font-bold text-slate-500 font-mono block">Celestiais 🌟</span>
                <span className="text-sm font-black text-amber-400 font-mono">{celestiaisCount}</span>
              </div>
              <Sun className="h-3.5 w-3.5 text-amber-500 shrink-0" />
            </div>

            <div className="bg-slate-950/50 p-2.5 rounded-xl border border-slate-900 flex items-center justify-between">
              <div>
                <span className="text-[8px] uppercase font-bold text-slate-500 font-mono block">Sombrios ☄️</span>
                <span className="text-sm font-black text-purple-400 font-mono">{sombriosCount}</span>
              </div>
              <Moon className="h-3.5 w-3.5 text-purple-400 shrink-0" />
            </div>

            <div className="bg-slate-950/50 p-2.5 rounded-xl border border-slate-900 flex items-center justify-between">
              <div>
                <span className="text-[8px] uppercase font-bold text-slate-500 font-mono block">Neutros 🌾</span>
                <span className="text-sm font-black text-slate-300 font-mono">{neutrosCount}</span>
              </div>
              <span className="text-xs shrink-0 select-none">🌾</span>
            </div>
          </div>
        </div>

      </section>

      {/* COMPREHENSIVE SINGLE-SCREEN STUDENTS GRID */}
      <div className="bg-slate-950 p-5 md:p-6 rounded-2xl border border-slate-800 shadow-xl">
        
        {/* FILTERS HEADER */}
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6 pb-4 border-b border-slate-900">
          <div>
            <h3 className="font-sans font-black text-white text-base flex items-center gap-2">
              <Award className="h-5 w-5 text-amber-500" />
              Alunos Registrados na Classe
            </h3>
            <p className="text-xs text-slate-400">Visão unificada em tela de todos os estudantes, suas auras correspondentes e níveis</p>
          </div>

          <div className="flex flex-wrap sm:flex-nowrap items-center gap-3 w-full md:w-auto">
            {/* Search Input */}
            <div className="relative w-full sm:w-52 shrink-0">
              <input
                id="search-dashboard-students"
                type="text"
                placeholder="Buscar por nome..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full bg-slate-900 border border-slate-800 focus:border-slate-705 rounded-xl py-1.5 pl-8 pr-3 text-xs text-slate-100 placeholder-slate-500 focus:outline-none"
              />
              <Search className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-slate-500" />
            </div>

            {/* Alignment Filters Selector */}
            <div className="flex bg-slate-900 p-1 rounded-xl border border-slate-800 shrink-0 gap-1 w-full sm:w-auto overflow-x-auto">
              <button
                onClick={() => setAlignmentFilter("all")}
                className={`flex-1 sm:flex-none px-3 py-1 text-[10px] uppercase font-bold tracking-wider rounded-lg transition duration-200 ${
                  alignmentFilter === "all" 
                    ? "bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 shadow font-black" 
                    : "text-slate-400 hover:text-slate-200"
                }`}
              >
                Todos
              </button>
              
              <button
                onClick={() => setAlignmentFilter("Celestial")}
                className={`flex-1 sm:flex-none px-3 py-1 text-[10px] uppercase font-bold tracking-wider rounded-lg transition duration-200 flex items-center justify-center gap-1 ${
                  alignmentFilter === "Celestial" 
                    ? "bg-amber-400 text-slate-950 font-black shadow" 
                    : "text-amber-400 hover:text-amber-300"
                }`}
              >
                <Sun className="h-2.5 w-2.5" /> Celestiais
              </button>
              
              <button
                onClick={() => setAlignmentFilter("Sombrio")}
                className={`flex-1 sm:flex-none px-3 py-1 text-[10px] uppercase font-bold tracking-wider rounded-lg transition duration-200 flex items-center justify-center gap-1 ${
                  alignmentFilter === "Sombrio" 
                    ? "bg-purple-600 text-white font-black shadow" 
                    : "text-purple-400 hover:text-purple-300"
                }`}
              >
                <Moon className="h-2.5 w-2.5" /> Sombrios
              </button>
            </div>
          </div>
        </div>

        {/* THE SINGLE SCREEN VISUALLY RICH CARD GRID (No Cramped Artificial Box!) */}
        {filteredStudents.length === 0 ? (
          <div className="text-center py-16 text-xs text-slate-500 bg-slate-900/10 border border-dashed border-slate-850 rounded-2xl">
            Nenhum aluno atende aos critérios deste filtro de alinhamento.
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 gap-4">
            {filteredStudents.map((stud) => {
              const info = getZodiacTier(stud.points);
              const rank = sortedStudents.findIndex(s => s.id === stud.id) + 1;
              const alignmentColors = getAlignmentColors(info.alignment);
              
              let rankMedal = "";
              if (rank === 1) rankMedal = "🥇";
              else if (rank === 2) rankMedal = "🥈";
              else if (rank === 3) rankMedal = "🥉";

              const borderGlowClass = info.alignment === "Celestial" 
                ? "hover:border-amber-500/40 hover:shadow-amber-500/5 duration-300" 
                : info.alignment === "Sombrio" 
                  ? "hover:border-purple-500/40 hover:shadow-purple-500/5 duration-300" 
                  : "hover:border-slate-600/40 duration-300";

              return (
                <div
                  id={`student-card-${stud.id}`}
                  key={stud.id}
                  onClick={() => setSelectedReviewStudent(stud)}
                  className={`bg-slate-900/30 hover:bg-slate-900/70 p-4.5 rounded-2xl border border-slate-800/80 hover:scale-[1.02] active:scale-[0.98] transition-all cursor-pointer flex flex-col justify-between ${borderGlowClass} group relative overflow-hidden`}
                >
                  {/* Subtle Background Radial Align Light */}
                  <div className={`absolute top-0 right-0 w-24 h-24 rounded-full blur-2xl opacity-5 pointer-events-none bg-gradient-to-tr ${
                    info.alignment === "Celestial" ? "from-amber-400" : info.alignment === "Sombrio" ? "from-purple-500" : "from-slate-400"
                  }`} />

                  <div>
                    {/* Level Meta info */}
                    <div className="flex items-center justify-between gap-2 mb-3">
                      <span className={`px-2 py-0.5 rounded-md text-[8px] font-black uppercase tracking-wider font-mono ${alignmentColors.badge}`}>
                        {info.fullName}
                      </span>
                      <span className="text-[10px] font-mono font-black text-slate-400 bg-slate-950 px-2 py-0.5 rounded-lg border border-slate-850">
                        {rankMedal ? `${rankMedal} #${rank}` : `#${rank}`}
                      </span>
                    </div>

                    {/* Emoji, name & aura details */}
                    <div className="flex items-center gap-3 mb-4">
                      <div className="h-11 w-11 shrink-0 relative flex items-center justify-center group-hover:scale-110 transition duration-300">
                        <AnimeAvatar student={stud} size="sm" />
                        <span className="absolute -bottom-1 -right-1 text-[10px] bg-slate-950/80 border border-slate-850 h-5 w-5 rounded-full flex items-center justify-center leading-none shadow-md">
                          {info.emoji}
                        </span>
                      </div>
                      <div className="overflow-hidden">
                        <h4 className="text-xs font-black text-white hover:text-amber-400 transition truncate">{stud.name}</h4>
                        <span className="text-[9px] text-slate-400 font-medium block truncate mt-0.5">Zodíaco: {info.level.name}</span>
                      </div>
                    </div>
                  </div>

                  {/* Rating Points Footer bar with interactive stats count */}
                  <div className="mt-2 border-t border-slate-950 pt-3 flex items-center justify-between">
                    <span className="text-[9px] text-slate-500 flex items-center gap-1 font-semibold">
                      <CalendarDays className="h-3 w-3 text-slate-500" />
                      {stud.history.length === 1 ? "1 atitude" : `${stud.history.length} atitudes`}
                    </span>
                    <span className={`text-sm font-black font-mono tracking-tight ${stud.points >= 0 ? "text-amber-400" : "text-purple-400"}`}>
                      {stud.points >= 0 ? `+${stud.points}` : stud.points} pts
                    </span>
                  </div>

                  {/* Progress Indicator line */}
                  <div className="w-full bg-slate-950 h-1.5 rounded-full overflow-hidden mt-3 p-[1px]">
                    <div 
                      className={`h-full rounded-full transition-all duration-500 ${info.alignment === "Celestial" ? "bg-amber-400" : info.alignment === "Sombrio" ? "bg-purple-500" : "bg-slate-600"}`}
                      style={{ width: `${info.progressPercent}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* QUICK POPUP FOR ACTIONS VIEWING */}
      {selectedReviewStudent && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-slate-900 border border-slate-800 max-w-lg w-full rounded-2xl p-6 shadow-2xl relative max-h-[80vh] overflow-y-auto">
            <button
              onClick={() => setSelectedReviewStudent(null)}
              className="absolute right-5 top-5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 p-1.5 rounded-lg transition"
            >
              <X className="h-5 w-5" />
            </button>

            {(() => {
              const info = getZodiacTier(selectedReviewStudent.points);
              const colors = getAlignmentColors(info.alignment);
              return (
                <div>
                  <div className="flex items-center gap-3.5 mb-5 border-b border-slate-800 pb-4">
                    <span className="text-3xl bg-slate-950 p-2.5 rounded-xl border border-slate-850">{info.emoji}</span>
                    <div>
                      <h3 className="text-base font-black text-white">{selectedReviewStudent.name}</h3>
                      <div className="flex items-center gap-1.5 mt-1">
                        <span className={`px-1.5 rounded text-[9px] font-bold uppercase tracking-wider ${colors.badge}`}>
                          {info.fullName}
                        </span>
                        <span className="text-sm text-amber-500 font-bold font-mono">{selectedReviewStudent.points >= 0 ? `+${selectedReviewStudent.points}` : selectedReviewStudent.points} pts</span>
                      </div>
                    </div>
                  </div>

                  <div className="mb-5">
                    <h4 className="text-[10px] font-black uppercase text-slate-400 mb-1.5">Alinhamento Cósmico</h4>
                    <p className="text-xs text-slate-300 leading-relaxed bg-slate-950 p-3 rounded-xl border border-slate-850">
                      {info.level.description}
                    </p>
                  </div>

                  <div className="mb-5">
                    <div className="flex justify-between items-center text-[10px] text-slate-400 mb-1.5">
                      <span>Nível: {info.level.name}</span>
                      <span>Progresso: {info.progressPercent}%</span>
                    </div>
                    <div className="w-full bg-slate-950 border border-slate-850 h-2.5 rounded-full p-0.5">
                      <div 
                        className={`h-full rounded-full ${info.alignment === "Celestial" ? "bg-amber-400" : info.alignment === "Sombrio" ? "bg-purple-50" : "bg-slate-600"}`}
                        style={{ width: `${info.progressPercent}%` }}
                      />
                    </div>
                  </div>

                  <div>
                    <h4 className="text-[10px] font-black uppercase text-slate-400 mb-2.5">Histórico Recente de Atitudes</h4>
                    {selectedReviewStudent.history.length === 0 ? (
                      <p className="text-center py-4 text-xs text-slate-500 bg-slate-950/30 rounded-lg">Coração vazio. Nenhuma atitude registrada.</p>
                    ) : (
                      <div className="flex flex-col gap-2 max-h-48 overflow-y-auto pr-1">
                        {selectedReviewStudent.history.map((rec) => (
                          <div key={rec.id} className="bg-slate-950 p-3 rounded-xl border border-slate-850 text-left">
                            <div className="flex justify-between text-[9px] text-slate-500 mb-1">
                              <span>📅 {rec.date}</span>
                              <span className={`font-black font-mono ${rec.points >= 0 ? "text-amber-500" : "text-purple-400"}`}>
                                {rec.points >= 0 ? `+${rec.points}` : rec.points} pts
                              </span>
                            </div>
                            <p className="text-xs text-slate-200 line-clamp-2 italic">"{rec.description}"</p>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              );
            })()}

            <button
              onClick={() => setSelectedReviewStudent(null)}
              className="w-full mt-6 bg-slate-800 hover:bg-slate-700 font-sans text-xs font-bold text-white uppercase tracking-wider py-2.5 rounded-xl transition"
            >
              Fechar Visualização
            </button>
          </div>
        </div>
      )}

    </div>
  );
}
