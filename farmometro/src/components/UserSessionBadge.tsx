import React, { useState } from "react";
import { UserSession } from "./Gatekeeper";
import { Student } from "../types";
import { 
  Crown, 
  GraduationCap, 
  UserCircle2, 
  LogOut, 
  Compass, 
  UserCheck2,
  ChevronDown,
  Lock
} from "lucide-react";
import AnimeAvatar from "./AnimeAvatar";

interface UserSessionBadgeProps {
  currentSession: UserSession;
  students: Student[];
  onLogout: () => void;
  onSelectSession: (session: UserSession) => void;
}

export default function UserSessionBadge({
  currentSession,
  students,
  onLogout,
  onSelectSession
}: UserSessionBadgeProps) {
  const [isOpen, setIsOpen] = useState(false);

  const matchedStudent = currentSession.role === "aluno" 
    ? students.find(s => s.id === currentSession.studentId) 
    : null;

  // Render descriptive badge text & icon
  let text = "Público (Visitante)";
  let badgeColor = "border-slate-800 bg-slate-950/80 text-slate-400";
  let icon = <Compass className="h-3.5 w-3.5 text-slate-400" />;

  if (currentSession.role === "professor") {
    text = "Prof. Mestre 🥋";
    badgeColor = "border-amber-500/30 bg-amber-950/20 text-amber-400";
    icon = <GraduationCap className="h-3.5 w-3.5" />;
  } else if (currentSession.role === "admin") {
    text = "Mestre Supremo (ADM) 👑";
    badgeColor = "border-purple-500/30 bg-purple-950/20 text-purple-400";
    icon = <Crown className="h-3.5 w-3.5 text-purple-400" />;
  } else if (currentSession.role === "aluno" && matchedStudent) {
    text = `${matchedStudent.name.split(" ")[0]} 🌀`;
    badgeColor = "border-sky-500/30 bg-sky-950/20 text-sky-400";
    icon = <UserCheck2 className="h-3.5 w-3.5 text-sky-400" />;
  }

  return (
    <div className="relative font-sans text-left z-30" id="user-session-badge">
      
      {/* Active Trigger Tab */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`flex items-center gap-2 px-3 py-1.5 rounded-lg border text-xs font-black transition ${badgeColor}`}
      >
        {currentSession.role === "aluno" && matchedStudent ? (
          <AnimeAvatar student={matchedStudent} size="sm" showAuraEffects={false} />
        ) : (
          <span className="p-1 bg-slate-900 rounded-md">{icon}</span>
        )}
        <div className="text-left leading-tight hidden sm:block">
          <span className="text-[9px] uppercase text-slate-500 font-mono block font-bold">Identidade Ativa</span>
          <span className="truncate max-w-[120px] block">{text}</span>
        </div>
        <ChevronDown className={`h-3.5 w-3.5 text-slate-500 transition duration-250 ${isOpen ? "rotate-180" : ""}`} />
      </button>

      {isOpen && (
        <>
          {/* Backdrop dismiss overlay */}
          <div className="fixed inset-0 z-10" onClick={() => setIsOpen(false)} />

          {/* Settings Dropdown Card */}
          <div className="absolute right-0 mt-2 w-64 bg-slate-950 rounded-xl border border-slate-800 shadow-2xl p-4 z-20 animate-in fade-in slide-in-from-top-2 duration-150">
            <h4 className="text-[10px] font-black uppercase text-slate-500 tracking-wider mb-2.5 font-mono">
              Trocar Alinhamento de Acesso
            </h4>

            <div className="space-y-1.5">
              <button
                onClick={() => {
                  onSelectSession({ role: "visitor" });
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between p-2 rounded-lg text-xs font-bold transition text-left ${currentSession.role === "visitor" ? "bg-slate-900 text-amber-400" : "text-slate-400 hover:text-white hover:bg-slate-900/60"}`}
              >
                <span className="flex items-center gap-2">
                  <Compass className="h-4 w-4" />
                  Visitante (Visualizar Tab)
                </span>
                {currentSession.role === "visitor" && <span className="h-1.5 w-1.5 rounded-full bg-amber-400" />}
              </button>

              <button
                onClick={() => {
                  onSelectSession({ role: "professor" });
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between p-2 rounded-lg text-xs font-bold transition text-left ${currentSession.role === "professor" ? "bg-amber-950/20 text-amber-400 border border-amber-500/10" : "text-slate-400 hover:text-white hover:bg-slate-900/60"}`}
              >
                <span className="flex items-center gap-2">
                  <GraduationCap className="h-4 w-4" />
                  Professor Mestre
                </span>
                {currentSession.role === "professor" && <span className="h-1.5 w-1.5 rounded-full bg-amber-400" />}
              </button>

              <button
                onClick={() => {
                  onSelectSession({ role: "admin" });
                  setIsOpen(false);
                }}
                className={`w-full flex items-center justify-between p-2 rounded-lg text-xs font-bold transition text-left ${currentSession.role === "admin" ? "bg-purple-950/20 text-purple-400 border border-purple-500/10" : "text-slate-400 hover:text-white hover:bg-slate-900/60"}`}
              >
                <span className="flex items-center gap-2">
                  <Crown className="h-4 w-4" />
                  Mestre Supremo (ADM)
                </span>
                {currentSession.role === "admin" && <span className="h-1.5 w-1.5 rounded-full bg-purple-400" />}
              </button>
            </div>

            <div className="border-t border-slate-900 my-3 pt-3">
              <button
                onClick={() => {
                  onLogout();
                  setIsOpen(false);
                }}
                className="w-full flex items-center gap-2 p-2 rounded-lg text-xs font-bold text-rose-400 hover:bg-rose-950/20 hover:text-rose-300 transition text-left"
              >
                <LogOut className="h-4 w-4 shrink-0" />
                <span>Revogar Selo (Log Out)</span>
              </button>
            </div>

            <div className="bg-slate-900 p-2.5 rounded-lg border border-slate-850 text-[10px] leading-relaxed font-normal text-slate-500 mt-2 italic">
              ✦ O Dashboard principal permanece totalmente público, sem exigir credenciais.
            </div>
          </div>
        </>
      )}
    </div>
  );
}
