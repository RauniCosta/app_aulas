import React from "react";
import { Student, AvatarConfig, getZodiacTier } from "../types";

// Seeded generator to ensure every student has a unique base look even before custom edits
export function getDefaultAvatarConfig(name: string, id: string): AvatarConfig {
  const combined = `${name || "estudante"}-${id || "id"}`;
  let hash = 0;
  for (let i = 0; i < combined.length; i++) {
    hash = combined.charCodeAt(i) + ((hash << 5) - hash);
  }
  const absHash = Math.abs(hash);

  const archetypes = ["saiyan", "ninja", "pirate", "shinigami", "cyborg"];
  const hairStyles = ["spiky", "long", "curly", "short", "bald"];
  const hairColors = ["yellow", "blue", "white", "red", "black", "green", "purple", "cyan"];
  const accessories = ["none", "sword", "headband", "scarf", "energy_ball", "eye_patch"];
  const outfitColors = ["orange", "dark", "red", "blue", "white", "gold"];
  const backgroundAuras = ["auto", "ki", "lightning", "flames", "none"];

  return {
    archetype: archetypes[absHash % archetypes.length],
    hairStyle: hairStyles[(absHash >> 2) % hairStyles.length],
    hairColor: hairColors[(absHash >> 4) % hairColors.length],
    accessory: accessories[(absHash >> 6) % accessories.length],
    outfitColor: outfitColors[(absHash >> 8) % outfitColors.length],
    backgroundAura: backgroundAuras[(absHash >> 10) % backgroundAuras.length],
  };
}

interface AnimeAvatarProps {
  student: Student;
  size?: "sm" | "md" | "lg" | "xl";
  showAuraEffects?: boolean;
}

export default function AnimeAvatar({ student, size = "md", showAuraEffects = true }: AnimeAvatarProps) {
  const tier = getZodiacTier(student.points);
  const config = student.avatarConfig || getDefaultAvatarConfig(student.name, student.id);
  const evolutionLevel = tier.index; // 0 (Neutral) up to 12 (Supremo Dragão)
  const isSombrio = tier.alignment === "Sombrio";
  const isCelestial = tier.alignment === "Celestial";

  // Size dimensional definitions
  const sizeMap = {
    sm: "h-11 w-11",
    md: "h-20 w-20",
    lg: "h-36 w-36",
    xl: "h-48 w-48",
  };

  const dim = sizeMap[size];

  // Colors mapping definitions
  const hairColorMap: Record<string, string> = {
    yellow: "#fbbf24", // Super Saiyan
    blue: "#06b6d4",   // Super Saiyan Blue
    white: "#e2e8f0",  // Gear 5 / Ultra Instinct
    red: "#ef4444",    // Kaioken / God SSJ
    black: "#1e293b",  // Base hair
    green: "#10b981",  // Zoro style
    purple: "#a855f7", // Hakai aura
    cyan: "#22d3ee",
  };

  const outfitColorMap: Record<string, string> = {
    orange: "#f97316", // Goku Turtle Hermit
    dark: "#1e1b4b",   // Shinobi dark blue
    red: "#991b1b",    // Akatsuki / Pirate Crimson
    blue: "#1d4ed8",   // Classic blue
    white: "#f8fafc",  // Spiritual Sage
    gold: "#d97706",   // Emperor armor
  };

  const hairHex = hairColorMap[config.hairColor] || "#1e293b";
  const outfitHex = outfitColorMap[config.outfitColor] || "#1e1b4b";

  // Primary Aura Color based on student alignment & chosen aura preference
  let auraColor = "#10b981"; // Neutral teal
  if (isCelestial) {
    auraColor = "#f59e0b"; // Celestial Gold
  } else if (isSombrio) {
    auraColor = "#8b5cf6"; // Dark Sombrio Purple/Red
  }

  // Handle custom auras
  if (config.backgroundAura === "ki") auraColor = "#38bdf8"; // Light blue ki
  else if (config.backgroundAura === "flames") auraColor = "#ef4444"; // Fire
  else if (config.backgroundAura === "lightning") auraColor = "#fbbf24"; // Thunder yellow

  return (
    <div className={`relative ${dim} shrink-0 select-none flex items-center justify-center`} id={`anime-avatar-${student.id}`}>
      
      {/* 1. LAYER 0: ANIMED BACKGROUND BURST AURA (Only if enabled and points indicate evolution) */}
      {showAuraEffects && evolutionLevel > 0 && (
        <svg className="absolute inset-0 w-full h-full scale-[1.35] z-0 overflow-visible pointer-events-none" viewBox="0 0 100 100">
          <defs>
            {/* Base Radial glow gradient */}
            <radialGradient id={`glow-${student.id}`} cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor={auraColor} stopOpacity="0.45" />
              <stop offset="70%" stopColor={auraColor} stopOpacity="0.15" />
              <stop offset="100%" stopColor={auraColor} stopOpacity="0" />
            </radialGradient>

            {/* Kaioken flaming gradient */}
            <linearGradient id={`flameGrad-${student.id}`} x1="0%" y1="100%" x2="0%" y2="0%">
              <stop offset="0%" stopColor={auraColor} stopOpacity="0.6" />
              <stop offset="50%" stopColor={isSombrio ? "#dc2626" : "#f59e0b"} stopOpacity="0.4" />
              <stop offset="100%" stopColor={isSombrio ? "#4c1d95" : "#fef08a"} stopOpacity="0" />
            </linearGradient>
          </defs>

          {/* Style Block for specialized keyframe animations */}
          <style>{`
            @keyframes pulseGlow {
              0%, 100% { transform: scale(1); opacity: 0.8; }
              50% { transform: scale(1.1); opacity: 1; }
            }
            @keyframes riseFlames {
              0% { transform: translateY(2px) scaleY(0.95) skewX(-2deg); }
              50% { transform: translateY(-3px) scaleY(1.05) skewX(2deg); }
              100% { transform: translateY(2px) scaleY(0.95) skewX(-2deg); }
            }
            @keyframes lightningStrike {
              0%, 90%, 94%, 98%, 100% { opacity: 0; }
              91%, 93%, 95%, 97% { opacity: 0.95; }
            }
            @keyframes haloSpin {
              0% { transform: rotate(0deg); }
              100% { transform: rotate(360deg); }
            }
            @keyframes orbitParticles {
              0% { transform: rotate(0deg) translate(38px) rotate(0deg); }
              100% { transform: rotate(360deg) translate(38px) rotate(-360deg); }
            }
            .glow-effect-${student.id} {
              animation: pulseGlow 2.5s ease-in-out infinite;
            }
            .flame-effect-${student.id} {
              animation: riseFlames 1.2s ease-in-out infinite;
              transform-origin: bottom center;
            }
            .lightning-bolt-${student.id} {
              animation: lightningStrike 4.5s ease-in-out infinite;
            }
            .halo-spin-${student.id} {
              animation: haloSpin 12s linear infinite;
              transform-origin: 50% 50%;
            }
            .particle-orbit-${student.id} {
              animation: orbitParticles 6s linear infinite;
              transform-origin: 50% 50%;
            }
          `}</style>

          {/* Simple Radial Base Glow (Level 1+) */}
          <circle cx="50" cy="50" r="42" fill={`url(#glow-${student.id})`} className={`glow-effect-${student.id}`} />

          {/* 1A. KAIOKEN / ENERGY FLAMES (Level 4+ / Cabra+) */}
          {evolutionLevel >= 4 && (
            <g className={`flame-effect-${student.id}`}>
              {/* Flame waves behind */}
              <path d="M 22 80 C 12 50, 18 30, 32 20 C 38 15, 45 25, 50 10 C 55 25, 62 15, 68 20 C 82 30, 88 50, 78 80 Z" fill={`url(#flameGrad-${student.id})`} />
              <path d="M 30 75 C 20 52, 28 35, 40 25 C 44 20, 48 26, 50 18 C 52 26, 56 20, 60 25 C 72 35, 80 52, 70 75 Z" fill={`url(#flameGrad-${student.id})`} opacity="0.7" />
            </g>
          )}

          {/* 1B. LIGHTNING BOLTS (Level 7+ / Boi+) */}
          {evolutionLevel >= 7 && (
            <g className={`lightning-bolt-${student.id}`} stroke={isSombrio ? "#c084fc" : "#fef08a"} strokeWidth="1.5" strokeLinecap="round" fill="none">
              {/* Random electric vectors */}
              <path d="M 12 35 L 20 48 L 14 55" />
              <path d="M 88 40 L 78 52 L 84 62" />
              <path d="M 40 5 L 45 15 L 35 22" />
              <path d="M 68 12 L 60 22 L 65 30" />
            </g>
          )}

          {/* 1C. DIVINE COSMIC RING / halo (Level 10+ / Serpente+) */}
          {evolutionLevel >= 10 && (
            <g className={`halo-spin-${student.id}`} stroke={auraColor} strokeWidth="1" strokeDasharray="3,15,8,4" fill="none">
              {/* Sacred rotating mandala */}
              <circle cx="50" cy="50" r="35" opacity="0.65" />
              <circle cx="50" cy="50" r="32" opacity="0.45" strokeDasharray="1,6" />
              
              {/* Halo Nodes */}
              <circle cx="50" cy="15" r="2.5" fill={auraColor} />
              <circle cx="50" cy="85" r="2.5" fill={auraColor} />
              <circle cx="15" cy="50" r="2.5" fill={auraColor} />
              <circle cx="85" cy="50" r="2.5" fill={auraColor} />
            </g>
          )}

          {/* 1D. CELESTIAL DRAGON SPIRIT / DARK SNAKE LEVIATHAN winding in BG (Level 12 / Dragão Supremo) */}
          {evolutionLevel >= 12 && (
            <path
              d="M 15 90 C 2 60, 20 30, 50 25 C 80 20, 95 40, 85 70 C 75 90, 40 90, 30 70 C 20 50, 48 35, 50 35"
              fill="none"
              stroke={isSombrio ? "#701a75" : "#f59e0b"}
              strokeWidth="3.5"
              strokeLinecap="round"
              strokeDasharray="10, 180"
              className="halo-spin-student"
              style={{ animation: `haloSpin 6s linear infinite`, transformOrigin: "50% 50%" }}
              opacity="0.85"
            />
          )}
        </svg>
      )}

      {/* 2. LAYER 1: THE CORE CHARACTER AVATAR VECTOR Canvas */}
      <svg className="w-full h-full z-10 drop-shadow-xl relative overflow-visible" viewBox="0 0 100 100">
        <defs>
          {/* Eyes filter for intense glowing levels */}
          <filter id="eyeGlow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="1.5" result="blur" />
            <feComposite in="SourceGraphic" in2="blur" operator="over" />
          </filter>

          <clipPath id="avatarClip">
            <circle cx="50" cy="50" r="46" />
          </clipPath>

          {/* Background mesh colors */}
          <radialGradient id="cardBg" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#1e293b" />
            <stop offset="100%" stopColor="#0f172a" />
          </radialGradient>
        </defs>

        {/* Framing circle container */}
        <g clipPath="url(#avatarClip)">
          {/* Internal background circle */}
          <circle cx="50" cy="50" r="48" fill="url(#cardBg)" stroke="#334155" strokeWidth="1.5" />

          {/* A. ACCESSORIES: Back Weapon layer (e.g. Shinigami Big Sword, Samurai Katana) */}
          {config.accessory === "sword" && (
            <g transform="rotate(35, 50, 50)">
              {/* Back sword sheath */}
              <rect x="72" y="10" width="6" height="50" rx="2" fill="#0f172a" stroke="#475569" strokeWidth="1" />
              {/* Hilt and guard */}
              <rect x="70" y="5" width="10" height="3" rx="0.5" fill="#e2e8f0" />
              <rect x="73.5" y="-5" width="3" height="10" rx="1" fill="#dc2626" />
            </g>
          )}

          {/* B. BASE BODY: Shoulders and Outfits */}
          <g>
            {/* Neck */}
            <rect x="45" y="65" width="10" height="12" fill="#ffd8a8" />
            <rect x="45" y="67" width="10" height="4" fill="#fcc419" opacity="0.3" /> {/* Neck shadow */}

            {/* Outfits mapping */}
            {config.backgroundAura === "cyborg" || config.archetype === "cyborg" ? (
              // Cybernetic armor plates
              <g>
                <path d="M 28 78 C 35 70, 65 70, 72 78 L 74 98 L 26 98 Z" fill="#475569" />
                <path d="M 45 70 L 55 70 L 58 78 L 42 78 Z" fill="#334155" />
                <circle cx="50" cy="80" r="3" fill="#38bdf8" className="animate-pulse" /> {/* core indicator */}
              </g>
            ) : (
              // Standard Anime clothes with customizable colors
              <g>
                {/* Gi shoulders contour */}
                <path d="M 24 80 C 32 72, 68 72, 76 80 L 78 98 L 22 98 Z" fill={outfitHex} />
                
                {/* V-neck inner undershirt */}
                <path d="M 42 72 L 50 82 L 58 72 Z" fill={config.archetype === "saiyan" ? "#1d4ed8" : "#0f172a"} />
                {/* V-neck trim shadows */}
                <path d="M 40 73 L 50 85 L 60 73 L 58 71 L 50 81 L 42 71 Z" fill="#000" opacity="0.15" />
              </g>
            )}
          </g>

          {/* C. FACE: head shape */}
          <g id="face-base">
            {/* Jaw structure */}
            <path d="M 34 50 C 34 65, 50 72, 50 72 C 50 72, 66 65, 66 50 Z" fill="#ffe3e3" />
            <path d="M 33 46 C 33 34, 67 34, 67 46 C 67 58, 67 62, 50 71 C 33 62, 33 58, 33 46 Z" fill="#ffe8cc" /> 
            
            {/* Blushing Anime Lines */}
            <g opacity="0.35">
              <line x1="39" y1="56" x2="42" y2="53" stroke="#f03e3e" strokeWidth="1" />
              <line x1="41" y1="56" x2="44" y2="53" stroke="#f03e3e" strokeWidth="1" />
              <line x1="56" y1="56" x2="59" y2="53" stroke="#f03e3e" strokeWidth="1" />
              <line x1="58" y1="56" x2="61" y2="53" stroke="#f03e3e" strokeWidth="1" />
            </g>

            {/* Nose */}
            <path d="M 49 55 L 51 55 L 50 52 Z" fill="#e8590c" opacity="0.5" />

            {/* Small anime mouth */}
            {evolutionLevel >= 7 ? (
              // Smug confident grin for powerful tiers
              <path d="M 45 61 Q 50 65 55 61" stroke="#212529" strokeWidth="1.5" strokeLinecap="round" fill="none" />
            ) : (
              // Determinate simple line
              <path d="M 47 62 Q 50 63 53 62" stroke="#212529" strokeWidth="1.2" strokeLinecap="round" fill="none" />
            )}
          </g>

          {/* D. FACIAL FEATURES: EYES */}
          <g id="eyes">
            {config.accessory === "eye_patch" ? (
              // Pirate cool eyepatch
              <g>
                <circle cx="42" cy="46" r="5" fill="#1e293b" stroke="#0f172a" strokeWidth="1.5" />
                <line x1="32" y1="41" x2="52" y2="51" stroke="#0f172a" strokeWidth="2" />
                {/* Other side open eye */}
                <ellipse cx="58" cy="46" r="4.5" rx="4.5" ry="3" fill="#ffffff" />
                <circle cx="58" cy="46" r="2.2" fill={isSombrio ? "#701a75" : "#1d4ed8"} />
                <circle cx="59.5" cy="44.5" r="0.8" fill="#ffffff" />
              </g>
            ) : (
              // Regular or Intense Anime Eyes
              <g>
                {/* Left eye socket background */}
                <ellipse cx="41" cy="46" r="5.5" rx="5.5" ry="3.5" fill="#ffffff" />
                {/* Right eye socket background */}
                <ellipse cx="59" cy="46" r="5.5" rx="5.5" ry="3.5" fill="#ffffff" />

                {/* Eyebrows (Dynamic angry tilt for combat looks) */}
                <path d="M 34 41 Q 41 39 46 43" stroke="#212529" strokeWidth="2" strokeLinecap="round" fill="none" />
                <path d="M 66 41 Q 59 39 54 43" stroke="#212529" strokeWidth="2" strokeLinecap="round" fill="none" />

                {/* Irises */}
                {evolutionLevel >= 7 ? (
                  // Flaming/Glowing eyes filter (like DBZ Super Saiyan or Gear 5 / Sharingan)
                  <g filter="url(#eyeGlow)">
                    <circle cx="41" cy="46" r="3" fill={isSombrio ? "#dc2626" : "#fbbf24"} />
                    <circle cx="59" cy="46" r="3" fill={isSombrio ? "#dc2626" : "#fbbf24"} />
                    {/* Glowing sparks */}
                    <circle cx="41" cy="46" r="1" fill="#fff" />
                    <circle cx="59" cy="46" r="1" fill="#fff" />
                    {/* Concentric rings for high cosmic level */}
                    {evolutionLevel >= 10 && (
                      <>
                        <circle cx="41" cy="46" r="2.2" stroke="#fff" strokeWidth="0.4" fill="none" />
                        <circle cx="59" cy="46" r="2.2" stroke="#fff" strokeWidth="0.4" fill="none" />
                      </>
                    )}
                  </g>
                ) : (
                  // Calm, customizable anime irises
                  <g>
                    <circle cx="41" cy="46" r="3.2" fill={config.hairColor === "black" ? "#0284c7" : hairHex} />
                    <circle cx="59" cy="46" r="3.2" fill={config.hairColor === "black" ? "#0284c7" : hairHex} />
                    {/* Eye reflections */}
                    <circle cx="42.2" cy="44.2" r="1" fill="#ffffff" />
                    <circle cx="60.2" cy="44.2" r="1" fill="#ffffff" />
                  </g>
                )}
              </g>
            )}
          </g>

          {/* E. HAIR & BRUSH STROKES */}
          <g id="hair-base">
            {config.hairStyle === "spiky" && (
              // Epic Goku Super Saiyan spiky spikes
              <g fill={hairHex}>
                <path d="M 50 12 L 40 28 L 48 30 L 32 18 L 43 33 L 42 38 L 50 35 L 58 38 L 57 33 L 68 18 L 52 30 L 60 28 Z" />
                <path d="M 28 35 L 35 48 L 40 45 L 20 40 L 32 52 L 35 55 L 43 45 Z" />
                <path d="M 72 35 L 65 48 L 60 45 L 80 40 L 68 52 L 65 55 L 57 45 Z" />
                {/* Fringe locks */}
                <path d="M 38 38 L 44 48 L 46 42 Z" opacity="0.95" />
                <path d="M 62 38 L 56 48 L 54 42 Z" opacity="0.95" />
                <path d="M 50 36 L 50 49 L 46 45 Z" opacity="0.85" />
              </g>
            )}

            {config.hairStyle === "long" && (
              // Flowing Shinobi long hair
              <g fill={hairHex}>
                {/* Back thick locks */}
                <path d="M 22 45 C 15 55, 12 75, 24 85 C 27 75, 28 60, 28 45 Z" />
                <path d="M 78 45 C 85 55, 88 75, 76 85 C 73 75, 72 60, 72 45 Z" />
                {/* Header cap */}
                <path d="M 33 42 C 30 20, 70 20, 67 42 C 60 28, 40 28, 33 42 Z" />
                {/* Front framing strands */}
                <path d="M 34 40 L 38 58 L 42 42 Z" />
                <path d="M 66 40 L 62 58 L 58 42 Z" />
                <path d="M 48 36 L 52 50 L 53 43 Z" />
              </g>
            )}

            {config.hairStyle === "curly" && (
              // Luffy wavy/messy pirate locks
              <g fill={hairHex}>
                <circle cx="50" cy="30" r="14" />
                <circle cx="38" cy="35" r="10" />
                <circle cx="62" cy="35" r="10" />
                <circle cx="34" cy="45" r="6" />
                <circle cx="66" cy="45" r="6" />
                {/* Dynamic stray strands */}
                <path d="M 37 40 L 40 50 L 43 43 Z" />
                <path d="M 63 40 L 60 50 L 57 43 Z" />
                <path d="M 48 35 L 50 47 L 53 40 Z" />
              </g>
            )}

            {config.hairStyle === "short" && (
              // Neat classic anime crop
              <g fill={hairHex}>
                <path d="M 32 44 C 30 18, 70 18, 68 44 C 64 35, 36 35, 32 44 Z" />
                <path d="M 32 38 L 36 50 C 37 45, 39 42, 40 45 L 43 38 Z" />
                <path d="M 68 38 L 64 50 C 63 45, 61 42, 60 45 L 57 38 Z" />
                <path d="M 46 36 L 50 46 L 54 36 Z" />
              </g>
            )}

            {config.hairStyle === "bald" && (
              // Saitama / Monk look (Shiny reference)
              <g>
                <ellipse cx="50" cy="33" rx="14" ry="7" fill="#fff" opacity="0.1" /> {/* shiny pate */}
              </g>
            )}
          </g>

          {/* F. FOREGROUND ACCESSORY: headband (Ninja), Scarf, or pirate hat */}
          <g id="front-accessories">
            {config.accessory === "headband" && (
              // Naruto Leaf village headband
              <g>
                {/* Cloth wraps */}
                <path d="M 32 38 Q 50 35 68 38 L 68 43 Q 50 40 32 43 Z" fill="#1e293b" />
                {/* Metal plate */}
                <rect x="42" y="38" width="16" height="5" rx="1" fill="#94a3b8" stroke="#475569" strokeWidth="0.5" />
                {/* Spiral village symbol */}
                <circle cx="50" cy="40.5" r="1.2" stroke="#334155" strokeWidth="0.7" fill="none" />
                {/* Rivets */}
                <circle cx="43.5" cy="40.5" r="0.4" fill="#334155" />
                <circle cx="56.5" cy="40.5" r="0.4" fill="#334155" />
              </g>
            )}

            {config.accessory === "scarf" && (
              // Mikasa / Crimson Shinobi Scarf
              <g>
                {/* Main scarf wrapped around neck */}
                <path d="M 37 68 C 37 68, 41 78, 50 78 C 59 78, 63 68, 63 68 C 63 68, 59 73, 50 73 C 41 73, 37 68, 37 68 Z" fill="#991b1b" stroke="#7f1d1d" strokeWidth="0.5" />
                {/* Fluttering side tail */}
                <path d="M 61 71 C 68 71, 78 82, 85 80 C 80 88, 68 82, 60 76 Z" fill="#b91c1c" className="glow-effect-student" style={{ animation: "pulseGlow 1.8s infinite" }} />
              </g>
            )}
          </g>
        </g>
      </svg>

      {/* 3. LAYER 2: CHAKRA / KAMEHAMEHA BALL IN FOREGROUND (only if accessory is energy_ball) */}
      {config.accessory === "energy_ball" && (
        <svg className="absolute bottom-[-4px] right-[-4px] w-12 h-12 z-20 overflow-visible pointer-events-none" viewBox="0 0 100 100">
          <defs>
            <radialGradient id="rasengan" cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor="#fff" />
              <stop offset="40%" stopColor="#38bdf8" stopOpacity="0.8" />
              <stop offset="100%" stopColor="#0369a1" stopOpacity="0" />
            </radialGradient>
          </defs>
          <style>{`
            @keyframes rotateBall {
              0% { transform: rotate(0deg) scale(1); }
              50% { transform: rotate(180deg) scale(1.15); }
              100% { transform: rotate(360deg) scale(1); }
            }
            .ball-anim {
              animation: rotateBall 1.5s linear infinite;
              transform-origin: 50% 50%;
            }
          `}</style>
          <g className="ball-anim">
            {/* Plasma layers */}
            <circle cx="50" cy="50" r="38" fill="url(#rasengan)" />
            <path d="M 50 15 A 35 35 0 0 1 85 50" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" opacity="0.8" />
            <path d="M 50 85 A 35 35 0 0 1 15 50" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" opacity="0.6" />
            <circle cx="50" cy="50" r="14" fill="#fff" opacity="0.9" />
          </g>
        </svg>
      )}

      {/* 4. EVOLUTION / STREAK FLARE IN BADGE (Super Saiyan spark level 12) */}
      {evolutionLevel >= 12 && (
        <span className="absolute -top-1.5 -right-1.5 z-30 bg-gradient-to-r from-yellow-400 to-amber-500 text-slate-950 font-mono text-[8px] font-black uppercase text-center px-1.5 py-0.5 rounded-full border border-yellow-200 tracking-wider shadow shadow-amber-500/50 animate-bounce">
          SUPREMO
        </span>
      )}
    </div>
  );
}
