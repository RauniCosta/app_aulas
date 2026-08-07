import React, { useState } from "react";
import { Student } from "../types";
import { 
  ShieldAlert, 
  Lock, 
  KeyRound, 
  GraduationCap, 
  User, 
  Crown, 
  Zap, 
  Flame,
  CheckCircle,
  Eye
} from "lucide-react";
import AnimeAvatar from "./AnimeAvatar";

export interface UserSession {
  role: "visitor" | "professor" | "aluno" | "admin";
  studentId?: string;
}

interface GatekeeperProps {
  students: Student[];
  allowedRoles: ("professor" | "aluno" | "admin")[];
  currentSession: UserSession;
  onLogin: (session: UserSession) => void;
  children: React.ReactNode;
}

export default function Gatekeeper({
  students,
  allowedRoles,
  currentSession,
  onLogin,
  children
}: GatekeeperProps) {
  const [selectedRole, setSelectedRole] = useState<"professor" | "aluno" | "admin">("professor");
  const [tempStudentId, setTempStudentId] = useState<string>("");
  const [passphrase, setPassphrase] = useState<string>("");
  const [errorText, setErrorText] = useState<string | null>(null);

  // Auto-select first student if student list is loaded
  React.useEffect(() => {
    if (students.length > 0 && !tempStudentId) {
      setTempStudentId(students[0].id);
    }
  }, [students, tempStudentId]);

  const hasAccess = (allowedRoles as string[]).includes(currentSession.role);

  if (hasAccess) {
    return <>{children}</>;
  }

  // Handle simulated thematic seal break
  const handleUnlock = (e: React.FormEvent) => {
    e.preventDefault();
    setErrorText(null);

    if (selectedRole === "professor") {
      // Direct access allowed, but let's check basic passphrase if they type something wrong, or default to correct
      const trimmed = passphrase.trim().toLowerCase();
      if (trimmed && trimmed !== "aura" && trimmed !== "professor") {
        setErrorText("❌ Canto rúnico incorreto! Tente 'aura' ou deixe em branco para passar.");
        return;
      }
      onLogin({ role: "professor" });
    } else if (selectedRole === "admin") {
      const trimmed = passphrase.trim().toLowerCase();
      if (trimmed && trimmed !== "admin" && trimmed !== "supremo") {
        setErrorText("❌ Selo do Mestre recusado! Tente 'admin' ou deixe em branco para passar.");
        return;
      }
      onLogin({ role: "admin" });
    } else if (selectedRole === "aluno") {
      if (!tempStudentId) {
        setErrorText("❌ Nenhum guerreiro selecionado no pergaminho.");
        return;
      }
      onLogin({ role: "aluno", studentId: tempStudentId });
    }
  };

  // Get requested portal name
  const portalName = allowedRoles.includes("professor") 
    ? "Painel do Professor Mestre" 
    : "Portal Cósmico do Aluno";

  return (
    <div className="max-w-xl mx-auto my-8 animate-in fade-in zoom-in-95 duration-350" id="gatekeeper-panel">
      
      {/* Visual Seal Card */}
      <div className="bg-slate-950 p-8 rounded-3xl border-2 border-slate-800/80 shadow-[0_0_50px_rgba(245,158,11,0.06)] relative overflow-hidden text-left">
        
        {/* Background glowing particles and circles */}
        <div className="absolute top-0 right-0 w-48 h-48 bg-amber-500/5 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-8 -left-8 w-40 h-40 bg-purple-500/5 rounded-full blur-3xl pointer-events-none" />

        {/* Energy Gate Indicator */}
        <div className="flex flex-col items-center text-center mb-6 relative">
          <div className="h-16 w-16 bg-gradient-to-tr from-amber-500/10 to-purple-600/15 rounded-2xl border-2 border-amber-500/35 flex items-center justify-center mb-4 relative group">
            <Lock className="h-7 w-7 text-amber-400 group-hover:scale-110 transition duration-300" />
            <span className="absolute -top-1 -right-1 bg-amber-500 text-[8px] font-mono font-black text-slate-950 px-1 rounded-full uppercase py-0.5">
              SELO
            </span>
          </div>

          <span className="text-[10px] font-bold tracking-widest text-amber-500 uppercase font-mono">
            Selo de Acesso Requerido
          </span>
          <h2 className="text-xl font-black text-white mt-1">Conexão Espiritual Necessária</h2>
          <p className="text-xs text-slate-400 max-w-sm mt-1 leading-normal">
            O {portalName} está protegido por leis cósmicas de aura. Escolha sua identidade para sintonizar.
          </p>
        </div>

        {/* Role Selector Tabs */}
        <div className="grid grid-cols-3 bg-slate-900/90 p-1 rounded-xl border border-slate-850 gap-1 mb-6 text-xs font-bold">
          <button
            type="button"
            onClick={() => {
              setSelectedRole("professor");
              setErrorText(null);
            }}
            className={`py-2 rounded-lg transition flex flex-col items-center gap-1 ${selectedRole === "professor" ? "bg-amber-500 text-slate-950 font-black shadow-md" : "text-slate-400 hover:text-slate-200 hover:bg-slate-850/50"}`}
          >
            <GraduationCap className="h-4.5 w-4.5" />
            <span className="text-[10px] uppercase">Professor</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSelectedRole("aluno");
              setErrorText(null);
            }}
            className={`py-2 rounded-lg transition flex flex-col items-center gap-1 ${selectedRole === "aluno" ? "bg-amber-500 text-slate-950 font-black shadow-md" : "text-slate-400 hover:text-slate-200 hover:bg-slate-850/50"}`}
          >
            <User className="h-4.5 w-4.5" />
            <span className="text-[10px] uppercase">Estudante</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSelectedRole("admin");
              setErrorText(null);
            }}
            className={`py-2 rounded-lg transition flex flex-col items-center gap-1 ${selectedRole === "admin" ? "bg-amber-500 text-slate-950 font-black shadow-md" : "text-slate-400 hover:text-slate-200 hover:bg-slate-850/50"}`}
          >
            <Crown className="h-4.5 w-4.5" />
            <span className="text-[10px] uppercase">Mestre ADM</span>
          </button>
        </div>

        <form onSubmit={handleUnlock} className="space-y-4">
          
          {selectedRole === "aluno" && (
            <div className="bg-slate-900/40 p-4 rounded-2xl border border-slate-850/80 animate-in slide-in-from-top duration-200">
              <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 font-mono block mb-2">
                Selecione seu nome de Guerreiro:
              </label>
              
              {students.length === 0 ? (
                <p className="text-xs text-rose-400 font-bold bg-rose-955/20 p-2.5 rounded-xl border border-rose-900/20 text-center">
                  ⚠️ Nenhum aluno matriculado na turma ativa! Adicione alunos no painel ou mude a turma.
                </p>
              ) : (
                <div className="flex items-center gap-4 bg-slate-900 p-3 rounded-xl border border-slate-800">
                  {(() => {
                    const matchedStudent = students.find(s => s.id === tempStudentId);
                    return matchedStudent ? (
                      <AnimeAvatar student={matchedStudent} size="sm" showAuraEffects={false} />
                    ) : (
                      <div className="h-11 w-11 rounded-lg bg-slate-950 border border-slate-800" />
                    );
                  })()}
                  
                  <div className="flex-1">
                    <select
                      value={tempStudentId}
                      onChange={(e) => setTempStudentId(e.target.value)}
                      className="w-full bg-transparent text-xs font-black text-amber-400 focus:outline-none cursor-pointer pr-1"
                    >
                      {students.map((s) => (
                        <option key={s.id} value={s.id} className="bg-slate-950 text-slate-100 text-xs">
                          {s.name}
                        </option>
                      ))}
                    </select>
                    <span className="text-[9px] text-slate-500 font-mono block mt-0.5">Identidade Escolar Alinhada</span>
                  </div>
                </div>
              )}
            </div>
          )}

          {(selectedRole === "professor" || selectedRole === "admin") && (
            <div className="bg-slate-900/40 p-4 rounded-xl border border-slate-850/80 space-y-3 animate-in slide-in-from-top duration-200">
              <div>
                <label className="text-[10px] font-bold uppercase tracking-wider text-slate-400 font-mono block mb-1">
                  Chave Mística (Passphrase) de Sintonia:
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-500">
                    <KeyRound className="h-4 w-4" />
                  </span>
                  <input
                    type="password"
                    placeholder={selectedRole === "professor" ? "Dica: deixe em branco ou digite 'aura'" : "Dica: deixe em branco ou digite 'admin'"}
                    value={passphrase}
                    onChange={(e) => setPassphrase(e.target.value)}
                    className="w-full bg-slate-950 border border-slate-800 focus:border-slate-700 rounded-xl py-2.5 pl-10 pr-4 text-xs text-slate-100 placeholder-slate-600 focus:outline-none"
                  />
                </div>
              </div>

              <div className="text-[10.5px] text-slate-500 font-normal leading-normal italic flex items-start gap-1">
                <span className="text-amber-500 animate-pulse mt-0.5 shrink-0">✦</span>
                <span>
                  Por questões acadêmicas de apresentação rápida, você pode sintonizar o canal diretamente tocando no botão livre de validação!
                </span>
              </div>
            </div>
          )}

          {errorText && (
            <div className="p-3.5 bg-rose-950/75 border border-rose-500/20 text-rose-300 text-xs rounded-xl font-bold flex items-center gap-2 animate-shake">
              <span>{errorText}</span>
            </div>
          )}

          <button
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-amber-500 via-yellow-500 to-amber-600 text-slate-900 hover:opacity-95 text-xs font-black uppercase tracking-widest rounded-xl shadow-lg shadow-amber-500/10 flex items-center justify-center gap-2 transition duration-200 active:scale-98"
          >
            <Zap className="h-4 w-4 animate-bounce" />
            Canalizar Ligação de Aura
          </button>
        </form>

        {/* Friendly explanation */}
        <div className="mt-6 pt-5 border-t border-slate-900 flex items-start gap-3 text-slate-450 text-[11px] leading-relaxed">
          <CheckCircle className="h-5 w-5 text-emerald-400/80 shrink-0 mt-0.5" />
          <p>
            O <strong>Dashboard principal de classificação</strong> continua com <strong>visualização pública livre</strong>. Qualquer espectador pode analisar a classificação e os scores de todos os alunos livremente sem precisar de login.
          </p>
        </div>

      </div>
    </div>
  );
}
