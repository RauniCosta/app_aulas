import React, { useState, useEffect } from "react";
import { 
  Plus, 
  Sparkles, 
  Clock, 
  Database,
  Layers,
  GraduationCap,
  Compass,
  Award,
  X,
  Info
} from "lucide-react";
import { Student, ActionRecord, getZodiacTier, ZODIAC_LEVELS, Turma, AvatarConfig } from "./types";
import { INITIAL_TURMAS, QuickAction } from "./mockData";
import TurmaDashboard from "./components/TurmaDashboard";
import PortalProfessor from "./components/PortalProfessor";
import PortalAluno from "./components/PortalAluno";
import { motion, AnimatePresence } from "motion/react";
import Gatekeeper, { UserSession } from "./components/Gatekeeper";
import UserSessionBadge from "./components/UserSessionBadge";

export default function App() {
  // Load turmas from localStorage or default to INITIAL_TURMAS
  const [turmas, setTurmas] = useState<Turma[]>(() => {
    const saved = localStorage.getItem("farmometro_turmas_v2");
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        // Automatic update migration if the brand new actual classes requested are not found
        if (Array.isArray(parsed) && parsed.some(t => t.id === "turma_2ds_pami_a" || t.id === "turma_2ds_pami_b")) {
          return parsed;
        }
      } catch (e) {
        console.error("Error loading turmas", e);
      }
    }
    return INITIAL_TURMAS;
  });

  // Load selected turma ID
  const [selectedTurmaId, setSelectedTurmaId] = useState<string>(() => {
    const saved = localStorage.getItem("farmometro_selected_turma_id_v2");
    return saved || "turma_2ds_pami_a";
  });

  // State to toggle overlays
  const [showDatabaseEmulator, setShowDatabaseEmulator] = useState(false);
  const [showAddTurma, setShowAddTurma] = useState(false);
  const [newTurmaNome, setNewTurmaNome] = useState("");

  const activeTurma = turmas.find((t) => t.id === selectedTurmaId) || turmas[0] || null;
  const students = activeTurma ? activeTurma.students : [];

  // Helper function to update students state inside the current active turma
  const setStudents = (updateFn: Student[] | ((prevStudents: Student[]) => Student[])) => {
    setTurmas((prevTurmas) =>
      prevTurmas.map((t) => {
        if (t.id === (activeTurma ? activeTurma.id : "turma_2ds_pami_a")) {
          const nextStudents = typeof updateFn === "function" ? updateFn(t.students) : updateFn;
          return { ...t, students: nextStudents };
        }
        return t;
      })
    );
  };

  // State managers
  const [currentView, setCurrentView] = useState<"dashboard" | "professor" | "aluno">("dashboard");
  const [selectedStudentId, setSelectedStudentId] = useState<string | null>(null);
  
  // Student Portal Active viewer selection
  const [studentActiveViewerId, setStudentActiveViewerId] = useState<string | null>(null);

  // Load session from localStorage or default to visitor
  const [session, setSession] = useState<UserSession>(() => {
    const saved = localStorage.getItem("farmometro_session_v3");
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error("Error loading session:", e);
      }
    }
    return { role: "visitor" };
  });

  // Save session changes
  useEffect(() => {
    localStorage.setItem("farmometro_session_v3", JSON.stringify(session));
  }, [session]);

  // If role is locked student, sync activeViewerId
  useEffect(() => {
    if (session.role === "aluno" && session.studentId) {
      if (students.some(s => s.id === session.studentId)) {
        setStudentActiveViewerId(session.studentId);
      }
    }
  }, [session, students]);

  // Student ranking states and ratings
  const [customStudentPoints, setCustomStudentPoints] = useState<number>(100);
  const [customStudentFeedbackText, setCustomStudentFeedbackText] = useState("");
  const [ratingSuccessMessage, setRatingSuccessMessage] = useState<string | null>(null);
  
  const [showZodiacChart, setShowZodiacChart] = useState(false);
  const [showAddStudent, setShowAddStudent] = useState(false);
  
  // New student form
  const [newStudentName, setNewStudentName] = useState("");
  const [newStudentPoints, setNewStudentPoints] = useState<number>(0);

  // Aura analyzer state
  const [actionText, setActionText] = useState("");
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisError, setAnalysisError] = useState<string | null>(null);

  // Evaluation staging state (before committing to student history)
  const [stagingEvaluation, setStagingEvaluation] = useState<{
    points: number;
    justification: string;
    feedback: string;
  } | null>(null);

  // Save to localStorage when turmas changes
  useEffect(() => {
    localStorage.setItem("farmometro_turmas_v2", JSON.stringify(turmas));
  }, [turmas]);

  useEffect(() => {
    localStorage.setItem("farmometro_selected_turma_id_v2", selectedTurmaId);
  }, [selectedTurmaId]);

  // Adjust selectedStudent when activeTurma changes or initially loads
  useEffect(() => {
    if (activeTurma && activeTurma.students.length > 0) {
      if (!selectedStudentId || !activeTurma.students.some((s) => s.id === selectedStudentId)) {
        setSelectedStudentId(activeTurma.students[0].id);
      }
      if (!studentActiveViewerId || !activeTurma.students.some((s) => s.id === studentActiveViewerId)) {
        setStudentActiveViewerId(activeTurma.students[0].id);
      }
    } else {
      setSelectedStudentId(null);
      setStudentActiveViewerId(null);
    }
  }, [selectedTurmaId, activeTurma]);

  // Find currently selected student
  const selectedStudent = students.find((s) => s.id === selectedStudentId) || null;

  // Helper stats for classroom metrics
  const totalStudents = students.length;
  const averageAura = totalStudents > 0 
    ? Math.round(students.reduce((acc, curr) => acc + curr.points, 0) / totalStudents)
    : 0;

  // Aura do Professor Formula: (PP + MA) / 2
  const ppPoints = activeTurma ? activeTurma.pontosProfessor : 0;
  const professorAura = activeTurma ? Math.round((ppPoints + averageAura) / 2) : 0;
  const professorZodiac = getZodiacTier(professorAura);

  // Handle preset action template clicks
  const selectQuickAction = (action: QuickAction) => {
    setActionText(action.description);
    setStagingEvaluation(null);
    setAnalysisError(null);
  };

  // Run Mestre da Aura analysis via API POST
  const handleAnalyzeAction = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!actionText.trim() || !selectedStudent) return;

    setIsAnalyzing(true);
    setAnalysisError(null);
    setStagingEvaluation(null);

    try {
      const response = await fetch("/api/analisar", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: actionText,
          studentName: selectedStudent.name,
        }),
      });

      if (!response.ok) {
        throw new Error("Falha ao comunicar com o Mestre da Aura.");
      }

      const data = await response.json();
      
      setStagingEvaluation({
        points: Number(data.pontos_sugeridos) || 0,
        justification: data.justificativa_curta || "",
        feedback: data.feedback_aluno || "",
      });
    } catch (err: any) {
      console.error(err);
      setAnalysisError(err.message || "Ocorreu um erro ao carregar a avaliação mística.");
    } finally {
      setIsAnalyzing(false);
    }
  };

  // Commit staged points & actions to the student record
  const handleApplyEvaluation = () => {
    if (!stagingEvaluation || !selectedStudent) return;

    const newRecord: ActionRecord = {
      id: "rec_" + Date.now(),
      date: new Date().toISOString().split("T")[0],
      description: actionText,
      points: stagingEvaluation.points,
      justification: stagingEvaluation.justification,
      feedback: stagingEvaluation.feedback,
    };

    setStudents((prev) =>
      prev.map((student) => {
        if (student.id === selectedStudent.id) {
          const updatedPoints = Math.max(-8000, Math.min(8000, Number((student.points + stagingEvaluation.points).toFixed(1))));
          return {
            ...student,
            points: updatedPoints,
            history: [newRecord, ...student.history],
          };
        }
        return student;
      })
    );

    // Reset evaluator controls
    setActionText("");
    setStagingEvaluation(null);
  };

  // Delete a history entry and reverse points
  const handleDeleteHistoryEntry = (studentId: string, entryId: string, entryPoints: number) => {
    if (!confirm("Tem certeza que deseja excluir este registro? A pontuação correspondente será estornada.")) {
      return;
    }

    setStudents((prev) =>
      prev.map((student) => {
        if (student.id === studentId) {
          const updatedHistory = student.history.filter((rec) => rec.id !== entryId);
          const updatedPoints = Math.max(-8000, Math.min(8000, Number((student.points - entryPoints).toFixed(1))));
          return {
            ...student,
            points: updatedPoints,
            history: updatedHistory,
          };
        }
        return student;
      })
    );
  };

  // Update professorPoints (PP) on current active turma
  const handleUpdatePP = (val: number) => {
    setTurmas((prev) =>
      prev.map((t) => (t.id === selectedTurmaId ? { ...t, pontosProfessor: val } : t))
    );
  };

  // Channel points/feedback from student portal to professor (PP)
  const handleStudentChannelEnergy = (pointsAmount: number, description?: string) => {
    const studentViewer = students.find(s => s.id === studentActiveViewerId);
    const fromName = studentViewer ? studentViewer.name : "Estudante";
    
    // Update active classroom points
    setTurmas((prev) =>
      prev.map((t) => {
        if (t.id === selectedTurmaId) {
          const nextPP = Math.max(-8000, Math.min(8000, Number((t.pontosProfessor + pointsAmount).toFixed(1))));
          return { ...t, pontosProfessor: nextPP };
        }
        return t;
      })
    );

    // Set success banner message
    const direction = pointsAmount > 0 ? "Celestial 🌟" : pointsAmount < 0 ? "Sombria ☄️" : "Neutralizada 🌾";
    const sign = pointsAmount > 0 ? "+" : "";
    setRatingSuccessMessage(
      `Conexão Cósmica Ativa! ${fromName} canalizou ${sign}${pointsAmount} de aura ${direction} diretamente para o Professor.`
    );

    // Auto dismiss after 4 seconds
    setTimeout(() => {
      setRatingSuccessMessage(null);
    }, 4500);

    // Reset student text field if any
    setCustomStudentFeedbackText("");
  };

  const handleUpdateStudentAvatarConfig = (studentId: string, avatarConfig: AvatarConfig) => {
    setTurmas((prev) =>
      prev.map((t) => {
        if (t.id === selectedTurmaId) {
          return {
            ...t,
            students: t.students.map((s) => {
              if (s.id === studentId) {
                return { ...s, avatarConfig };
              }
              return s;
            })
          };
        }
        return t;
      })
    );
  };

  // Create a new customized academic block
  const handleCreateTurma = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTurmaNome.trim()) return;

    const newTurmaObj = {
      id: "turma_" + Date.now(),
      nome: newTurmaNome.trim(),
      criadoEm: new Date().toISOString(),
      pontosProfessor: 0,
      students: []
    };

    setTurmas((prev) => [...prev, newTurmaObj]);
    setSelectedTurmaId(newTurmaObj.id);
    setNewTurmaNome("");
    setShowAddTurma(false);
  };

  // Create a brand new student
  const handleAddStudent = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newStudentName.trim()) return;

    const newStud: Student = {
      id: "stud_" + Date.now(),
      name: newStudentName.trim(),
      points: Math.max(-8000, Math.min(8000, Number(newStudentPoints))),
      avatarSeed: newStudentName.toLowerCase().replace(/\s+/g, ""),
      history: []
    };

    // If starting with points, generate history setup entry for consistency
    if (newStudentPoints !== 0) {
      const alignmentText = newStudentPoints > 100 ? "Celestial" : newStudentPoints < -100 ? "Sombrio" : "Neutro";
      newStud.history.push({
        id: "rec_init_" + Date.now(),
        date: new Date().toISOString().split("T")[0],
        description: "Pontuação inicial registrada na criação do estudante.",
        points: newStudentPoints,
        justification: `Aura inicial estabelecida em sintonia com a vibração ${alignmentText}.`,
        feedback: `Bem-vindo ao Farmômetro! Sua jornada cósmica se inicia com ${newStudentPoints} pontos de Aura. Busque sempre elevar sua essência Celestial!`
      });
    }

    setStudents((prev) => [...prev, newStud]);
    setSelectedStudentId(newStud.id);
    setNewStudentName("");
    setNewStudentPoints(0);
    setShowAddStudent(false);
  };

  // Determine alignment colors dynamically
  const getAlignmentColors = (alignment: string) => {
    switch (alignment) {
      case "Celestial":
        return {
          bg: "bg-amber-50/90 dark:bg-amber-950/20",
          border: "border-amber-200 dark:border-amber-900/40",
          text: "text-amber-800 dark:text-amber-300",
          badge: "bg-amber-100 text-amber-850 dark:bg-amber-900/50 dark:text-amber-300",
          pulse: "shadow-[0_0_15px_rgba(245,158,11,0.25)]",
          glow: "from-amber-100 to-amber-50 dark:from-amber-950/30 dark:to-slate-900",
          accentText: "text-amber-600 dark:text-amber-400"
        };
      case "Sombrio":
        return {
          bg: "bg-purple-50/90 dark:bg-purple-950/20",
          border: "border-purple-200 dark:border-purple-900/40",
          text: "text-purple-800 dark:text-purple-300",
          badge: "bg-purple-100 text-purple-850 dark:bg-purple-900/50 dark:text-purple-300",
          pulse: "shadow-[0_0_15px_rgba(168,85,247,0.25)]",
          glow: "from-purple-100 to-purple-50 dark:from-purple-950/30 dark:to-slate-900",
          accentText: "text-purple-600 dark:text-purple-400"
        };
      default:
        return {
          bg: "bg-slate-50/90 dark:bg-slate-800/50",
          border: "border-slate-200 dark:border-slate-700/60",
          text: "text-slate-850 dark:text-slate-350",
          badge: "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300",
          pulse: "shadow-none",
          glow: "from-slate-100 to-slate-50 dark:from-slate-800/30 dark:to-slate-900",
          accentText: "text-slate-550 dark:text-slate-400"
        };
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-100 font-sans selection:bg-amber-500 selection:text-slate-900 pb-16">
      
      {/* HEADER SECTION WITH NAVIGATION VIEWS */}
      <header className="border-b border-slate-800 bg-slate-900/85 backdrop-blur-md sticky top-0 z-40 px-4 md:px-8 py-4">
        <div className="max-w-[1800px] mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
          
          {/* LOGO */}
          <div className="flex items-center gap-3">
            <div className="bg-gradient-to-tr from-amber-500 via-yellow-400 to-purple-600 p-2.5 rounded-xl shadow-lg relative overflow-hidden group">
              <Sparkles className="h-6 w-6 text-slate-900 animate-pulse relative z-10" />
              <div className="absolute inset-0 bg-slate-900 opacity-0 group-hover:opacity-10 transition-opacity" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-bold tracking-widest text-amber-400 uppercase">Farmômetro Escolar</span>
                <span className="px-1.5 py-0.5 bg-purple-950/80 text-purple-300 rounded text-[9px] font-mono font-bold uppercase tracking-wider">NoSQL + AI</span>
              </div>
              <h1 id="app-title" className="text-xl font-black tracking-tight text-white flex items-center gap-1.5 leading-none mt-0.5">
                Mestre da Aura
              </h1>
            </div>
          </div>

          {/* VIEW SWITCHER TABS - THE KEY THREE VIEWS */}
          <div className="flex bg-slate-950 p-1 rounded-xl border border-slate-800 gap-1 w-full md:w-auto">
            <button
              id="tab-dashboard"
              onClick={() => setCurrentView("dashboard")}
              className={`flex-1 md:flex-none flex items-center justify-center gap-1.5 px-4.5 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider transition duration-200 ${
                currentView === "dashboard"
                  ? "bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 shadow font-black"
                  : "text-slate-400 hover:text-white hover:bg-slate-900"
              }`}
            >
              <Layers className="h-3.5 w-3.5" />
              Dashboard
            </button>
            
            <button
              id="tab-professor"
              onClick={() => setCurrentView("professor")}
              className={`flex-1 md:flex-none flex items-center justify-center gap-1.5 px-4.5 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider transition duration-200 ${
                currentView === "professor"
                  ? "bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 shadow font-black"
                  : "text-slate-400 hover:text-white hover:bg-slate-900"
              }`}
            >
              <GraduationCap className="h-3.5 w-3.5" />
              Painel Professor
            </button>
            
            <button
              id="tab-aluno"
              onClick={() => setCurrentView("aluno")}
              className={`flex-1 md:flex-none flex items-center justify-center gap-1.5 px-4.5 py-1.5 rounded-lg text-xs font-bold uppercase tracking-wider transition duration-200 ${
                currentView === "aluno"
                  ? "bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 shadow font-black"
                  : "text-slate-400 hover:text-white hover:bg-slate-900"
              }`}
            >
              <Compass className="h-3.5 w-3.5" />
              Portal Aluno
            </button>
          </div>

          {/* GLOBAL DROPDOWN & TRIGGER PANEL */}
          <div className="flex flex-wrap items-center justify-center md:justify-end gap-3 mt-4 md:mt-0">
            {/* Authenticated Identity Badge */}
            <UserSessionBadge
              currentSession={session}
              students={students}
              onLogout={() => setSession({ role: "visitor" })}
              onSelectSession={(newSess) => setSession(newSess)}
            />

            {/* Turma selection */}
            <div className="flex items-center gap-1.5 bg-slate-800/90 px-3 py-1.5 rounded-lg border border-slate-700">
              <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Turma:</span>
              <select
                id="turma-select"
                value={selectedTurmaId}
                onChange={(e) => setSelectedTurmaId(e.target.value)}
                className="bg-transparent text-xs font-black text-amber-400 focus:outline-none cursor-pointer pr-1"
              >
                {turmas.map((t) => (
                  <option key={t.id} value={t.id} className="bg-slate-900 text-slate-100 font-sans text-xs">
                    {t.nome}
                  </option>
                ))}
              </select>
            </div>

            <button
              id="btn-trigger-emulator"
              onClick={() => setShowDatabaseEmulator(true)}
              className="px-3 py-2 bg-slate-950 text-emerald-400 hover:text-emerald-300 font-bold border border-emerald-500/20 hover:border-emerald-500/40 rounded-xl text-xs flex items-center gap-1.5 transition"
              title="Abrir Emulação NoSQL Firestore"
            >
              <Database className="h-3.5 w-3.5" />
              Simular Firestore
            </button>

            <button
              id="btn-scale-trigger"
              onClick={() => setShowZodiacChart(true)}
              className="px-3 py-2 bg-slate-950 text-amber-400 hover:text-amber-300 font-bold border border-amber-500/20 hover:border-amber-500/40 rounded-xl text-xs flex items-center gap-1.5 transition"
            >
              <Award className="h-3.5 w-3.5" />
              Tabela de Aura
            </button>
          </div>
        </div>
      </header>

      {/* CORE CONTAINER BODY */}
      <main id="main-content-area" className="max-w-[1800px] mx-auto px-4 md:px-8 mt-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentView}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            transition={{ duration: 0.18 }}
          >
            {currentView === "dashboard" && (
              <TurmaDashboard
                activeTurma={activeTurma}
                students={students}
                averageAura={averageAura}
                professorAura={professorAura}
                professorZodiac={professorZodiac}
                getAlignmentColors={getAlignmentColors}
                setShowZodiacChart={setShowZodiacChart}
                ppPoints={ppPoints}
                handleUpdatePP={handleUpdatePP}
              />
            )}

            {currentView === "professor" && (
              <Gatekeeper
                students={students}
                allowedRoles={["professor", "admin"]}
                currentSession={session}
                onLogin={(newSess) => setSession(newSess)}
              >
                <PortalProfessor
                  students={students}
                  selectedStudentId={selectedStudentId}
                  setSelectedStudentId={setSelectedStudentId}
                  actionText={actionText}
                  setActionText={setActionText}
                  isAnalyzing={isAnalyzing}
                  analysisError={analysisError}
                  stagingEvaluation={stagingEvaluation}
                  setStagingEvaluation={setStagingEvaluation}
                  handleApplyEvaluation={handleApplyEvaluation}
                  handleDeleteHistoryEntry={handleDeleteHistoryEntry}
                  getAlignmentColors={getAlignmentColors}
                  handleAnalyzeAction={handleAnalyzeAction}
                  selectQuickAction={selectQuickAction}
                  setShowAddStudent={setShowAddStudent}
                  setShowAddTurma={setShowAddTurma}
                />
              </Gatekeeper>
            )}

            {currentView === "aluno" && (
              <Gatekeeper
                students={students}
                allowedRoles={["aluno", "admin"]}
                currentSession={session}
                onLogin={(newSess) => setSession(newSess)}
              >
                <PortalAluno
                  students={students}
                  studentActiveViewerId={studentActiveViewerId}
                  setStudentActiveViewerId={setStudentActiveViewerId}
                  customStudentPoints={customStudentPoints}
                  setCustomStudentPoints={setCustomStudentPoints}
                  customStudentFeedbackText={customStudentFeedbackText}
                  setCustomStudentFeedbackText={setCustomStudentFeedbackText}
                  ratingSuccessMessage={ratingSuccessMessage}
                  handleStudentChannelEnergy={handleStudentChannelEnergy}
                  getAlignmentColors={getAlignmentColors}
                  ppPoints={ppPoints}
                  onUpdateStudentAvatarConfig={handleUpdateStudentAvatarConfig}
                  currentUserSession={session}
                  onLogoutStudent={() => setSession({ role: "visitor" })}
                />
              </Gatekeeper>
            )}
          </motion.div>
        </AnimatePresence>
      </main>

      {/* OVERLAY MODAL: SHOW CHINESE ZODIAC LEVELS CHART */}
      {showZodiacChart && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-slate-900 border border-slate-800 max-w-2xl w-full rounded-2xl max-h-[85vh] overflow-y-auto p-6 md:p-8 shadow-2xl relative animate-in fade-in zoom-in duration-200">
            <button
              id="btn-close-zodiac-chart"
              onClick={() => setShowZodiacChart(false)}
              className="absolute right-5 top-5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 p-1.5 rounded-lg transition"
            >
              <X className="h-5 w-5" />
            </button>

            <div className="flex items-center gap-2.5 mb-6">
              <Award className="h-6 w-6 text-amber-500 animate-pulse animate-duration-1000" />
              <div>
                <h3 className="text-xl font-black text-white h-auto leading-none">Alinhamentos do Zodíaco da Aura</h3>
                <p className="text-xs text-slate-450 mt-1">Escala de níveis baseada na classificação mística do Farmômetro</p>
              </div>
            </div>

            <div className="flex flex-col gap-3.5 mb-6">
              {ZODIAC_LEVELS.map((lvl, index) => (
                <div key={index} className="bg-slate-950/50 p-4 rounded-xl border border-slate-810 flex items-start gap-4 hover:border-slate-700 transition">
                  <div className="h-10 w-10 bg-slate-900 rounded-lg flex items-center justify-center text-2xl border border-slate-800 shrink-0">
                    {lvl.emoji}
                  </div>
                  
                  <div className="flex-1">
                    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1 mb-1">
                      <h4 className="font-bold text-sm text-slate-200">{lvl.name}</h4>
                      <span className="font-mono text-[11px] text-amber-400 bg-amber-950/40 px-2.5 py-0.5 rounded border border-amber-900/30">
                        {lvl.minPoints === 0 ? "0 a 100" : `${lvl.minPoints} a ${lvl.maxPoints === Infinity ? "8000+" : lvl.maxPoints} pts`}
                      </span>
                    </div>
                    <p className="text-xs text-slate-400 leading-relaxed font-normal">{lvl.description}</p>
                  </div>
                </div>
              ))}
            </div>

            <div className="text-right pt-2">
              <button
                id="btn-close-zodiac-modal"
                onClick={() => setShowZodiacChart(false)}
                className="px-5 py-2.5 bg-slate-800 hover:bg-slate-750 text-xs font-bold tracking-wider uppercase text-slate-150 rounded-xl transition cursor-pointer"
              >
                Voltar ao Painel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* OVERLAY MODAL: MATRICULAR ALUNO */}
      {showAddStudent && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-slate-900 border border-slate-800 max-w-md w-full rounded-2xl p-6 shadow-2xl relative animate-in fade-in zoom-in duration-200">
            <button
              id="btn-close-add-student"
              onClick={() => {
                setShowAddStudent(false);
                setNewStudentName("");
                setNewStudentPoints(0);
              }}
              className="absolute right-5 top-5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 p-1.5 rounded-lg transition"
            >
              <X className="h-5 w-5" />
            </button>

            <div className="flex items-center gap-2.5 mb-4">
              <span className="p-2 bg-amber-500/10 rounded-xl">
                <Plus className="h-5 w-5 text-amber-500" />
              </span>
              <div>
                <h3 className="text-lg font-black text-white h-auto">Criar Novo Aluno</h3>
                <p className="text-xs text-slate-400">Insira as coordenadas místicas dele na sala.</p>
              </div>
            </div>

            <form onSubmit={handleAddStudent} className="flex flex-col gap-4">
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-450 block mb-1 font-mono">
                  Nome do Aluno
                </label>
                <input
                  id="add-student-name-input"
                  type="text"
                  required
                  placeholder="Ex: Clara de Oliveira"
                  value={newStudentName}
                  onChange={(e) => setNewStudentName(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 focus:border-slate-600 rounded-xl p-3 text-xs text-slate-100 placeholder-slate-600"
                />
              </div>

              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-450 block mb-1 font-mono">
                  Pontos Iniciais de Aura (Criação)
                </label>
                <input
                  id="add-student-points-input"
                  type="number"
                  placeholder="0"
                  value={newStudentPoints}
                  onChange={(e) => setNewStudentPoints(Number(e.target.value))}
                  className="w-full bg-slate-950 border border-slate-800 focus:border-slate-600 rounded-xl p-3 text-xs text-slate-100 font-mono"
                />
                <span className="text-[10px] text-slate-450 mt-1 block font-normal leading-relaxed">
                  Valores negativos direcionam ao lado Sombrio, positivos para o lado Celestial. Aura inicial neutra é 0.
                </span>
              </div>

              <div className="flex gap-2 justify-end mt-4">
                <button
                  id="btn-cancel-add-student"
                  type="button"
                  onClick={() => {
                    setShowAddStudent(false);
                    setNewStudentName("");
                    setNewStudentPoints(0);
                  }}
                  className="px-4 py-2 hover:bg-slate-850 text-slate-400 hover:text-slate-200 text-xs font-semibold rounded-lg transition"
                >
                  Cancelar
                </button>
                
                <button
                  id="btn-submit-add-student"
                  type="submit"
                  className="px-5 py-2.5 bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 text-xs font-bold uppercase tracking-wider rounded-lg shadow-md transition cursor-pointer"
                >
                  Criar Matrícula
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* OVERLAY MODAL: CADASTRAR NOVA TURMA */}
      {showAddTurma && (
        <div className="fixed inset-0 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-slate-900 border border-slate-800 max-w-md w-full rounded-2xl p-6 shadow-2xl relative animate-in fade-in zoom-in duration-200">
            <button
              id="btn-close-add-turma"
              onClick={() => {
                setShowAddTurma(false);
                setNewTurmaNome("");
              }}
              className="absolute right-5 top-5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 p-1.5 rounded-lg transition"
            >
              <X className="h-5 w-5" />
            </button>

            <div className="flex items-center gap-2.5 mb-4">
              <span className="p-2 bg-amber-500/10 rounded-xl">
                <Plus className="h-5 w-5 text-amber-500" />
              </span>
              <div>
                <h3 className="text-lg font-black text-white h-auto font-sans">Cadastrar Nova Turma</h3>
                <p className="text-xs text-slate-400">Inicie um novo grupo de alquimia acadêmica escolar.</p>
              </div>
            </div>

            <form onSubmit={handleCreateTurma} className="flex flex-col gap-4">
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-455 block mb-1 font-mono">
                  Nome da Turma
                </label>
                <input
                  id="add-turma-name-input"
                  type="text"
                  required
                  placeholder="Ex: 2º Ano B - Cientistas Cósmicos"
                  value={newTurmaNome}
                  onChange={(e) => setNewTurmaNome(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 focus:border-slate-600 rounded-xl p-3 text-xs text-slate-100 placeholder-slate-600 font-sans"
                />
              </div>

              <div className="flex gap-2 justify-end mt-4">
                <button
                  id="btn-cancel-add-turma"
                  type="button"
                  onClick={() => {
                    setShowAddTurma(false);
                    setNewTurmaNome("");
                  }}
                  className="px-4 py-2 hover:bg-slate-850 text-slate-400 hover:text-slate-200 text-xs font-semibold rounded-lg transition"
                >
                  Cancelar
                </button>
                
                <button
                  id="btn-submit-add-turma"
                  type="submit"
                  className="px-5 py-2.5 bg-gradient-to-r from-amber-500 to-yellow-500 text-slate-900 text-xs font-bold uppercase tracking-wider rounded-lg shadow-md transition"
                >
                  Criar Turma NoSQL
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* OVERLAY MODAL: FIRESTORE NOSQL EMULATOR */}
      {showDatabaseEmulator && (
        <div className="fixed inset-0 bg-slate-950/85 backdrop-blur-sm flex items-center justify-center p-4 z-50 animate-in fade-in duration-100">
          <div className="bg-slate-900 border border-slate-800 max-w-5xl w-full rounded-2xl max-h-[85vh] overflow-hidden p-6 shadow-2xl relative flex flex-col">
            <button
              id="btn-close-firestore-emulator"
              onClick={() => setShowDatabaseEmulator(false)}
              className="absolute right-5 top-5 text-slate-400 hover:text-white bg-slate-800 hover:bg-slate-700 p-1.5 rounded-lg transition z-10"
            >
              <X className="h-5 w-5" />
            </button>

            <div className="flex items-center gap-2.5 mb-6">
              <Database className="h-6 w-6 text-emerald-400 animate-pulse shrink-0" />
              <div>
                <h3 className="text-lg font-black text-white h-auto font-sans flex items-center gap-2 leading-none">
                  Console Cloud Firestore do Farmômetro
                  <span className="px-1.5 py-0.5 bg-emerald-900/60 text-emerald-300 border border-emerald-500/20 rounded text-[9px] font-mono font-bold uppercase tracking-wider">Modo Emulação</span>
                </h3>
                <p className="text-xs text-slate-400 font-sans mt-1">Visualização real dos documentos NoSQL e logs de esquemas gerados persistentemente</p>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto pr-1">
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
                
                {/* Turmas Collection */}
                <div className="bg-slate-950 p-4 rounded-xl border border-slate-800 flex flex-col">
                  <div className="flex items-center justify-between mb-3 shrink-0">
                    <span className="text-xs font-bold tracking-widest text-amber-400 uppercase font-mono">📂 colecao: turmas</span>
                    <span className="text-[10px] text-slate-500 font-mono">({turmas.length} docs)</span>
                  </div>
                  <pre className="text-[10px] text-slate-300 font-mono overflow-x-auto bg-slate-900 p-3 rounded-lg max-h-[350px] overflow-y-auto leading-relaxed border border-slate-800/80 flex-1">
                    {JSON.stringify(
                      turmas.map(t => ({
                        id: t.id,
                        nome: t.nome,
                        criadoEm: t.criadoEm,
                        pontosProfessor: t.pontosProfessor
                      })), 
                      null, 
                      2
                    )}
                  </pre>
                  <p className="text-[9px] text-slate-500 mt-2.5 italic font-sans leading-relaxed">
                    Representa os grupos / classes criados e as respectivas avaliações canalizadas do professor.
                  </p>
                </div>

                {/* Usuarios Collection */}
                <div className="bg-slate-950 p-4 rounded-xl border border-slate-805 flex flex-col">
                  <div className="flex items-center justify-between mb-3 shrink-0">
                    <span className="text-xs font-bold tracking-widest text-emerald-400 uppercase font-mono">📂 colecao: usuarios</span>
                    <span className="text-[10px] text-slate-500 font-mono">({students.length + 1} docs)</span>
                  </div>
                  <pre className="text-[10px] text-slate-300 font-mono overflow-x-auto bg-slate-900 p-3 rounded-lg max-h-[350px] overflow-y-auto leading-relaxed border border-slate-850 flex-1">
                    {JSON.stringify(
                      [
                        {
                          id: "prof_mestre_1",
                          nome: "Prof. Mestre da Aura",
                          email: "mestre.aura@farmometro.edu",
                          papel: "professor",
                          id_turma: selectedTurmaId,
                          aura: professorAura,
                          pontosProfessor: ppPoints
                        },
                        ...students.map(s => ({
                          id: s.id,
                          nome: s.name,
                          email: `${s.name.toLowerCase().replace(/\s+/g, "")}@farmometro.edu`,
                          papel: "aluno",
                          id_turma: selectedTurmaId,
                          aura: s.points
                        }))
                      ], 
                      null, 
                      2
                    )}
                  </pre>
                  <p className="text-[9px] text-slate-505 mt-2.5 italic font-sans leading-relaxed">
                    Armazena os registros de alunos e professores pertencentes à turma selecionada na ressonância.
                  </p>
                </div>

                {/* Historico Pontos Collection */}
                <div className="bg-slate-950 p-4 rounded-xl border border-slate-805 flex flex-col">
                  <div className="flex items-center justify-between mb-3 shrink-0">
                    <span className="text-xs font-bold tracking-widest text-purple-400 uppercase font-mono">📂 colecao: historico_pontos</span>
                    <span className="text-[10px] text-slate-500 font-mono">
                      ({students.reduce((acc, current) => acc + current.history.length, 0)} docs)
                    </span>
                  </div>
                  <pre className="text-[10px] text-slate-300 font-mono overflow-x-auto bg-slate-900 p-3 rounded-lg max-h-[350px] overflow-y-auto leading-relaxed border border-slate-800 flex-1">
                    {JSON.stringify(
                      students.flatMap(s => 
                        s.history.map(h => ({
                          id: h.id,
                          de_usuario_id: "prof_mestre_1",
                          para_usuario_id: s.id,
                          valor: h.points,
                          motivo: h.description,
                          data: h.date,
                          justificativa: h.justification,
                          feedback_imer: h.feedback
                        }))
                      ), 
                      null, 
                      2
                    )}
                  </pre>
                  <p className="text-[9px] text-slate-505 mt-2.5 italic font-sans leading-relaxed">
                    Histórico imutável de transações comportamentais avaliadas pelo "Mestre da Aura" com Gemini.
                  </p>
                </div>

              </div>
            </div>

            <div className="text-right pt-4 border-t border-slate-800 mt-4 shrink-0">
              <button
                id="btn-close-firestore-modal"
                onClick={() => setShowDatabaseEmulator(false)}
                className="px-5 py-2.5 bg-slate-800 hover:bg-slate-750 text-xs font-bold tracking-wider uppercase text-slate-100 rounded-xl transition cursor-pointer"
              >
                Voltar ao Painel
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}
