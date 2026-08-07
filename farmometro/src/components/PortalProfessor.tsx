import React, { useState } from "react";
import { 
  Plus, 
  Trash2, 
  Sparkles, 
  ShieldAlert, 
  CheckCircle, 
  Clock, 
  Search,
  Settings,
  X,
  RefreshCw,
  Award,
  Sun,
  Moon
} from "lucide-react";
import { Student, ActionRecord, getZodiacTier } from "../types";
import AnimeAvatar from "./AnimeAvatar";
import { QUICK_ACTIONS, QuickAction } from "../mockData";

interface PortalProfessorProps {
  students: Student[];
  selectedStudentId: string | null;
  setSelectedStudentId: (id: string | null) => void;
  actionText: string;
  setActionText: (text: string) => void;
  isAnalyzing: boolean;
  analysisError: string | null;
  stagingEvaluation: {
    points: number;
    justification: string;
    feedback: string;
  } | null;
  setStagingEvaluation: (evalObj: any) => void;
  handleApplyEvaluation: () => void;
  handleDeleteHistoryEntry: (studentId: string, entryId: string, entryPoints: number) => void;
  getAlignmentColors: (alignment: string) => any;
  handleAnalyzeAction: (e: React.FormEvent) => void;
  selectQuickAction: (action: QuickAction) => void;
  setShowAddStudent: (show: boolean) => void;
  setShowAddTurma: (show: boolean) => void;
}

export default function PortalProfessor({
  students,
  selectedStudentId,
  setSelectedStudentId,
  actionText,
  setActionText,
  isAnalyzing,
  analysisError,
  stagingEvaluation,
  setStagingEvaluation,
  handleApplyEvaluation,
  handleDeleteHistoryEntry,
  getAlignmentColors,
  handleAnalyzeAction,
  selectQuickAction,
  setShowAddStudent,
  setShowAddTurma
}: PortalProfessorProps) {
  const [professorSearch, setProfessorSearch] = useState("");
  const [professorFilter, setProfessorFilter] = useState<"all" | "Celestial" | "Sombrio" | "Neutro">("all");

  const filteredStudents = students.filter((student) => {
    const matchesSearch = student.name.toLowerCase().includes(professorSearch.toLowerCase());
    const tier = getZodiacTier(student.points);
    const matchesAlignment = professorFilter === "all" || tier.alignment === professorFilter;
    return matchesSearch && matchesAlignment;
  });

  const selectedStudent = students.find((s) => s.id === selectedStudentId) || null;

  return (
    <div className="flex flex-col gap-6 animate-in fade-in duration-300">
      
      {/* EXPLANATORY HERO SUMMARY */}
      <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800 flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-base font-black text-white flex items-center gap-1.5 leading-snug">
            <Settings className="h-5 w-5 text-amber-500 animate-spin-slow" />
            Central de Moderação do Professor
          </h3>
          <p className="text-xs text-slate-400 max-w-xl leading-relaxed mt-1">
            Selecione um aluno na lista lateral para avaliar seu comportamento através da inteligência artificial Celestial/Sombria do Mestre da Aura. Você também pode excluir diários incorretos de pontuações.
          </p>
        </div>
        <div className="flex gap-2 shrink-0">
          <button
            onClick={() => setShowAddTurma(true)}
            className="px-3.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white rounded-lg text-xs font-bold transition flex items-center gap-1.5 border border-slate-700"
          >
            <Plus className="h-3.5 w-3.5" /> Nova Turma
          </button>
          <button
            onClick={() => setShowAddStudent(true)}
            className="px-3.5 py-1.5 bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 rounded-lg text-xs font-bold shadow-md shadow-amber-500/10 transition flex items-center gap-1.5"
          >
            <Plus className="h-3.5 w-3.5" /> Novo Aluno
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        
        {/* LEFT LIST PANEL FOR SELECTION (col 4) */}
        <div className="lg:col-span-4 flex flex-col gap-4">
          <div className="bg-slate-950 p-4 rounded-xl border border-slate-800">
            <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-2 font-mono">Buscar Estudante</label>
            <div className="relative mb-3">
              <input
                type="text"
                placeholder="Aluno..."
                value={professorSearch}
                onChange={(e) => setProfessorSearch(e.target.value)}
                className="w-full bg-slate-900 border border-slate-800 rounded-lg py-1.5 pl-8 pr-3 text-xs text-slate-100 placeholder-slate-500 focus:outline-none focus:border-amber-500"
              />
              <Search className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-slate-500" />
            </div>

            <div className="flex gap-1.5">
              <button
                onClick={() => setProfessorFilter("all")}
                className={`flex-1 py-1 text-[9px] uppercase font-bold rounded ${professorFilter === "all" ? "bg-amber-500 text-slate-900" : "bg-slate-900 text-slate-400 hover:bg-slate-850"}`}
              >
                Todos
              </button>
              <button
                onClick={() => setProfessorFilter("Celestial")}
                className={`flex-1 py-1 text-[9px] uppercase font-bold rounded flex items-center justify-center gap-0.5 ${professorFilter === "Celestial" ? "bg-amber-400 text-slate-950" : "bg-slate-900 text-amber-400 hover:bg-slate-850"}`}
              >
                <Sun className="h-2.5 w-2.5" /> Lus
              </button>
              <button
                onClick={() => setProfessorFilter("Sombrio")}
                className={`flex-1 py-1 text-[9px] uppercase font-bold rounded flex items-center justify-center gap-0.5 ${professorFilter === "Sombrio" ? "bg-purple-600 text-white" : "bg-slate-900 text-purple-400 hover:bg-slate-850"}`}
              >
                <Moon className="h-2.5 w-2.5" /> Som
              </button>
            </div>
          </div>

          <div className="flex flex-col gap-2 max-h-[460px] overflow-y-auto pr-1">
            {filteredStudents.length === 0 ? (
              <p className="text-center text-[11px] text-slate-500 py-6 bg-slate-950/40 rounded-xl border border-slate-900">Nenhum aluno.</p>
            ) : (
              filteredStudents.map((stud) => {
                const info = getZodiacTier(stud.points);
                const colors = getAlignmentColors(info.alignment);
                const isSelected = selectedStudentId === stud.id;

                return (
                  <button
                    key={stud.id}
                    onClick={() => {
                      setSelectedStudentId(stud.id);
                      setStagingEvaluation(null);
                    }}
                    className={`text-left p-3 rounded-xl border flex items-center justify-between gap-3 transition ${
                      isSelected 
                        ? "bg-slate-850 border-amber-500" 
                        : "bg-slate-950 hover:bg-slate-900 border-slate-900 hover:border-slate-800"
                    }`}
                  >
                    <div className="flex items-center gap-2.5">
                      <div className="h-9 w-9 shrink-0 relative flex items-center justify-center">
                        <AnimeAvatar student={stud} size="sm" />
                      </div>
                      <div>
                        <h4 className="text-xs font-black text-slate-200 line-clamp-1">{stud.name}</h4>
                        <span className={`text-[8px] font-bold uppercase tracking-wider ${colors.accentText}`}>
                          {info.fullName}
                        </span>
                      </div>
                    </div>
                    <span className="text-xs font-bold font-mono text-slate-300">
                      {stud.points >= 0 ? `+${stud.points}` : stud.points} pts
                    </span>
                  </button>
                );
              })
            )}
          </div>
        </div>

        {/* RIGHT WORKBENCH PANEL FOR ACTION (col 8) */}
        <div className="lg:col-span-8">
          {selectedStudent ? (
            <div className="flex flex-col gap-6">
              
              {/* SELECTED STUDENT HEADER INTRO */}
              <div className="bg-slate-950 p-5 rounded-2xl border border-slate-880/85 bg-gradient-to-r from-slate-950 to-slate-900 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <AnimeAvatar student={selectedStudent} size="md" />
                  <div>
                    <span className="text-[10px] uppercase font-mono font-bold text-amber-500">Avaliação do Mestre</span>
                    <h3 className="text-lg font-black text-white">{selectedStudent.name}</h3>
                  </div>
                </div>

                <div className="bg-slate-900 p-2 px-4 rounded-xl border border-slate-800/80 text-center">
                  <span className="text-[8px] uppercase tracking-wider font-bold text-slate-400 block font-mono">Saldo Cósmico</span>
                  <span className={`text-base font-black font-mono ${selectedStudent.points >= 0 ? "text-amber-400" : "text-purple-400"}`}>
                    {selectedStudent.points >= 0 ? `+${selectedStudent.points}` : selectedStudent.points} pts
                  </span>
                </div>
              </div>

              {/* GENERATOR WORKBENCH BOX */}
              <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800 shadow-xl">
                <div className="flex items-center gap-2 mb-4">
                  <Sparkles className="h-4 w-4 text-amber-500 animate-pulse" />
                  <h4 className="text-xs font-black uppercase tracking-wider text-white">Analisador Místico da Aura</h4>
                </div>

                <form onSubmit={handleAnalyzeAction} className="flex flex-col gap-4">
                  <textarea
                    rows={2.5}
                    placeholder={`Descreva a atitude de ${selectedStudent.name.split(" ")[0]} (Ex: respondeu perguntas difíceis no quadro e compartilhou o chocolate)...`}
                    value={actionText}
                    onChange={(e) => setActionText(e.target.value)}
                    className="w-full bg-slate-900 border border-slate-800 focus:border-slate-700 rounded-xl p-3.5 text-xs text-slate-100 placeholder-slate-500 focus:outline-none"
                  />

                  {/* PRESETS BUTTON INDESTRUCTIBLE */}
                  <div className="bg-slate-900/60 p-3 rounded-xl border border-slate-900">
                    <span className="text-[9px] uppercase font-mono font-bold text-slate-400 block mb-2">Comportamentos Comuns</span>
                    <div className="flex flex-wrap gap-1.5">
                      {QUICK_ACTIONS.map(qa => (
                        <button
                          key={qa.id}
                          type="button"
                          onClick={() => selectQuickAction(qa)}
                          className={`px-2 py-1.5 text-[10px] font-semibold rounded-lg border text-left flex items-center gap-1.5 transition ${
                            actionText === qa.description 
                              ? "bg-amber-950/40 text-amber-400 border-amber-500" 
                              : "bg-slate-950 hover:bg-slate-900 border-slate-850 text-slate-300"
                          }`}
                        >
                          <span className={qa.category === "positivo" ? "text-amber-400" : "text-purple-400"}>
                            {qa.category === "positivo" ? "🌟" : "☄️"}
                          </span>
                          <span>{qa.title}</span>
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="flex gap-2 justify-end">
                    <button
                      type="button"
                      onClick={() => {
                        setActionText("");
                        setStagingEvaluation(null);
                      }}
                      className="px-3.5 py-1.5 text-xs text-slate-400 hover:text-slate-200 transition"
                    >
                      Limpar
                    </button>
                    <button
                      type="submit"
                      disabled={isAnalyzing || !actionText.trim()}
                      className={`px-4.5 py-2 rounded-lg text-xs font-bold uppercase tracking-wider transition flex items-center gap-1.5 ${
                        !actionText.trim() 
                          ? "bg-slate-800 text-slate-500 cursor-not-allowed border border-slate-700" 
                          : "bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 shadow-md shadow-amber-500/10"
                      }`}
                    >
                      {isAnalyzing ? (
                        <>
                          <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                          Consultando...
                        </>
                      ) : (
                        <>
                          <Sparkles className="h-3.5 w-3.5" />
                          Gerar Pontos IA
                        </>
                      )}
                    </button>
                  </div>
                </form>

                {analysisError && (
                  <div className="mt-4 p-3 bg-red-950/40 border border-red-900 rounded-lg text-xs text-red-300 flex items-center gap-2">
                    <ShieldAlert className="h-4 w-4 text-red-500 shrink-0" />
                    <span>{analysisError}</span>
                  </div>
                )}

                {/* STAGING PANEL IF DATA TO CONFIRM */}
                {stagingEvaluation && (
                  <div className="mt-5 pt-5 border-t border-slate-900 animate-in fade-in slide-in-from-bottom duration-200">
                    <div className="bg-slate-900 p-4.5 rounded-xl border border-slate-800 relative">
                      <span className="absolute -top-3 left-3 px-2 py-0.5 bg-slate-900 border border-slate-800 rounded text-[9px] font-bold text-amber-400">PONTOS PROPOSTOS PELO MESTRE</span>
                      
                      <div className="grid grid-cols-1 md:grid-cols-12 gap-5 mt-2">
                        <div className="md:col-span-3 flex flex-col items-center justify-center p-3.5 bg-slate-950 border border-slate-850 rounded-lg text-center">
                          <label className="text-[9px] font-bold text-slate-500 uppercase tracking-wider font-mono">Calibrar Valor</label>
                          <input
                            type="number"
                            step="0.5"
                            value={stagingEvaluation.points}
                            onChange={(e) => setStagingEvaluation({ ...stagingEvaluation, points: Number(e.target.value) })}
                            className="bg-slate-900 border border-slate-700 rounded text-center w-20 text-lg font-black font-mono text-amber-400 mt-2 p-1 focus:outline-none"
                          />
                        </div>

                        <div className="md:col-span-9 flex flex-col gap-3">
                          <div>
                            <span className="text-[8px] uppercase tracking-wider font-bold text-slate-400 font-mono">Justificativa Diária</span>
                            <input
                              type="text"
                              value={stagingEvaluation.justification}
                              onChange={(e) => setStagingEvaluation({ ...stagingEvaluation, justification: e.target.value })}
                              className="w-full bg-slate-950 border border-slate-850 rounded p-2 text-xs text-slate-200 mt-1"
                            />
                          </div>

                          <div>
                            <span className="text-[8px] uppercase tracking-wider font-bold text-slate-400 font-mono">Feedback Imersivo (Zodíaco)</span>
                            <textarea
                              rows={2.5}
                              value={stagingEvaluation.feedback}
                              onChange={(e) => setStagingEvaluation({ ...stagingEvaluation, feedback: e.target.value })}
                              className="w-full bg-slate-950 border border-slate-850 rounded p-2 text-xs text-slate-200 leading-relaxed mt-1"
                            />
                          </div>
                        </div>
                      </div>

                      <div className="flex gap-2 justify-end mt-4 pt-3.5 border-t border-slate-900">
                        <button
                          type="button"
                          onClick={() => setStagingEvaluation(null)}
                          className="px-3.5 py-1.5 bg-slate-950 text-slate-400 text-xs font-semibold rounded hover:text-slate-200"
                        >
                          Ignorar
                        </button>
                        <button
                          onClick={handleApplyEvaluation}
                          className="px-4 py-1.5 bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 font-bold text-xs uppercase tracking-wider rounded flex items-center gap-1.5"
                        >
                          <CheckCircle className="h-3.5 w-3.5" /> Aplicar na Aura
                        </button>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* TIMELINE ARCHIVE FOR THE SELECTION */}
              <div className="bg-slate-950 p-5 rounded-2xl border border-slate-800">
                <div className="flex items-center gap-2 mb-4">
                  <Clock className="h-4 w-4 text-amber-500" />
                  <h4 className="text-xs font-black uppercase tracking-wider text-white">Diário Recente de Comportamentos</h4>
                </div>

                {selectedStudent.history.length === 0 ? (
                  <p className="text-center py-8 text-xs text-slate-500 bg-slate-900/10 rounded-xl border border-dashed border-slate-900">Coração limpo. Nenhuma atitude registrada para o moderar.</p>
                ) : (
                  <div className="border-l border-slate-900 ml-3 pl-5 flex flex-col gap-4">
                    {selectedStudent.history.map((rec) => {
                      const isPositive = rec.points >= 0;
                      return (
                        <div key={rec.id} className="relative">
                          <span className={`absolute -left-[27px] top-1.5 w-2.5 h-2.5 rounded-full border border-slate-900 ${isPositive ? "bg-amber-500" : "bg-purple-600"}`} />
                          
                          <div className="bg-slate-900/50 p-3 rounded-lg border border-slate-900">
                            <div className="flex justify-between items-center text-[10px] text-slate-400 mb-2 font-mono">
                              <span>📅 {rec.date}</span>
                              <div className="flex items-center gap-2">
                                <span className={`font-black ${isPositive ? "text-amber-400" : "text-purple-400"}`}>
                                  {isPositive ? `+${rec.points}` : rec.points} pts
                                </span>
                                <button
                                  onClick={() => handleDeleteHistoryEntry(selectedStudent.id, rec.id, rec.points)}
                                  className="text-slate-500 hover:text-red-400 p-0.5 rounded transition"
                                >
                                  <Trash2 className="h-3 w-3" />
                                </button>
                              </div>
                            </div>

                            <p className="text-xs text-slate-100 italic">"{rec.description}"</p>
                            <p className="text-[10px] text-slate-400 leading-relaxed mt-1 font-semibold">Razão: {rec.justification}</p>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>

            </div>
          ) : (
            <div className="bg-slate-950 rounded-2xl border border-slate-800 p-12 text-center h-96 flex flex-col items-center justify-center">
              <Award className="h-10 w-10 text-amber-500/60 animate-bounce mb-3" />
              <h4 className="text-white font-black text-sm">Selecione um Aluno para Calibragem</h4>
              <p className="text-slate-500 text-xs max-w-sm mt-1">Toque no nome de qualquer aluno do painel esquerdo para administrar suas atitudes míticas.</p>
            </div>
          )}
        </div>

      </div>

    </div>
  );
}
