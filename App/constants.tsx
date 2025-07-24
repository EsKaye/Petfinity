import React from 'react';
import { Pet, PetState, SimulatedPlayer } from './types';

// --- Reusable Effects ---
const Sparkles: React.FC = () => (
    <g fill="#fde047" stroke="none" className="animate-pulse">
        <path d="M1 8 l2 -1 l1 -2 l1 2 l2 1 l-2 1 l-1 2 l-1 -2 z" transform="translate(2, 2) scale(0.5)" />
        <path d="M1 8 l2 -1 l1 -2 l1 2 l2 1 l-2 1 l-1 2 l-1 -2 z" transform="translate(18, 5) scale(0.4)" />
        <path d="M1 8 l2 -1 l1 -2 l1 2 l2 1 l-2 1 l-1 2 l-1 -2 z" transform="translate(4, 15) scale(0.6)" />
    </g>
);

const DirtySmudge: React.FC = () => (
    <g fill="#854d0e" stroke="none" opacity="0.6">
        <circle cx="6" cy="14" r="2" />
        <circle cx="17" cy="16" r="2.5" />
    </g>
);

const SleepZzz: React.FC = () => (
     <g fill="none" stroke="#60a5fa" strokeWidth="1.5" className="animate-pulse">
        <text x="18" y="8" fontSize="6" fontFamily="monospace">z</text>
        <text x="20" y="5" fontSize="5" fontFamily="monospace">Z</text>
        <text x="22" y="2" fontSize="4" fontFamily="monospace">z</text>
    </g>
);


// --- Pet Art Components ---

const SparklynxArt: Pet['ArtComponent'] = ({ state, ...props }) => {
  const expressions = {
    idle: { eye: 'M8 10h.01M16 10h.01', mouth: 'M9 14h6' },
    happy: { eye: 'M8 9.5c0-.8.5-1.5 1.5-1.5s1.5.7 1.5 1.5V10H8z M14.5 8c1 0 1.5.7 1.5 1.5V10h-3v-.5c0-.8.5-1.5 1.5-1.5z', mouth: 'M9 14q3 2 6 0' },
    hungry: { eye: 'M8 10h.01M16 10h.01', mouth: 'M12 14 a 2,2 0 1,0 0,0.1' },
    sad: { eye: 'M8 10.5c0 .8-.5 1.5-1.5 1.5S5 11.3 5 10.5V10h3z M17.5 12c-1 0-1.5-.7-1.5-1.5V10h3v.5c0 .8-.5 1.5-1.5 1.5z', mouth: 'M9 15q3-2 6 0' },
    eating: { eye: 'M8 9.5c0-.8.5-1.5 1.5-1.5s1.5.7 1.5 1.5V10H8z M14.5 8c1 0 1.5.7 1.5 1.5V10h-3v-.5c0-.8.5-1.5 1.5-1.5z', mouth: 'M10 14 a 2,2 0 1,1 4,0' },
    playing: { eye: 'M8 9.5c0-.8.5-1.5 1.5-1.5s1.5.7 1.5 1.5V10H8z M14.5 8c1 0 1.5.7 1.5 1.5V10h-3v-.5c0-.8.5-1.5 1.5-1.5z', mouth: 'M9 14q3 2 6 0' },
    grooming: { eye: 'M8 9.5c0-.8.5-1.5 1.5-1.5s1.5.7 1.5 1.5V10H8z M14.5 8c1 0 1.5.7 1.5 1.5V10h-3v-.5c0-.8.5-1.5 1.5-1.5z', mouth: 'M9 14q3 2 6 0' },
    walking: { eye: 'M8 9.5c0-.8.5-1.5 1.5-1.5s1.5.7 1.5 1.5V10H8z M14.5 8c1 0 1.5.7 1.5 1.5V10h-3v-.5c0-.8.5-1.5 1.5-1.5z', mouth: 'M10 14 h4 v1.5 h-4 z' },
    anxious: { eye: 'M7 11 a 1,1 0 1,0 2,0 a 1,1 0 1,0 -2,0 M15 11 a 1,1 0 1,0 2,0 a 1,1 0 1,0 -2,0', mouth: 'M9 16c1-.5 2-1 3-1s2 .5 3 1' },
    sleeping: { eye: 'M8 10.5c-.5 1-1.5 1-2 0 M16 10.5c-.5 1-1.5 1-2 0', mouth: 'M11 15h2' },
    tired: { eye: 'M7 11h3M14 11h3', mouth: 'M9 15q3-2 6 0' },
    bored: { eye: 'M8 10h.01M16 10h.01', mouth: 'M10 15 a 2,2 0 1,1 4,0' },
    lonely: { eye: 'M8 10 a 2,2 0 1,1 -4,0 a 2,2 0 1,1 4,0 M16 10 a 2,2 0 1,1 -4,0 a 2,2 0 1,1 4,0', mouth: 'M9 15q3-2 6 0' },
    dirty: { eye: 'M8 10.5c0 .8-.5 1.5-1.5 1.5S5 11.3 5 10.5V10h3z M17.5 12c-1 0-1.5-.7-1.5-1.5V10h3v.5c0 .8-.5 1.5-1.5 1.5z', mouth: 'M10 14h4' },
    needs_potty: { eye: 'M7 11 a 1,1 0 1,0 2,0 a 1,1 0 1,0 -2,0 M15 11 a 1,1 0 1,0 2,0 a 1,1 0 1,0 -2,0', mouth: 'M10 15c-1 1 5 1 4 0' },
  };
  const current = expressions[state] || expressions.idle;
  const animationClass = state === 'anxious' ? 'animate-pulse-fast' : state === 'playing' || state === 'walking' ? 'animate-bounce' : state === 'eating' ? 'animate-pulse' : '';
  
  return (
    <svg viewBox="0 0 24 24" fill="none" strokeWidth="1.5" stroke="currentColor" {...props} className={`${props.className} ${animationClass}`}>
      <style>{`.animate-pulse-fast { animation: pulse 0.8s cubic-bezier(0.4, 0, 0.6, 1) infinite; }`}</style>
      <path strokeLinecap="round" strokeLinejoin="round" d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2z" stroke="#9333ea" />
      <path strokeLinecap="round" strokeLinejoin="round" d="M4 8l2-2m12 0l2 2" stroke="#f472b6" />
      <path d={current.eye} fill="#fff" stroke="none" />
      <path d={current.mouth} stroke="#fff" strokeLinecap="round"/>
      {state === 'grooming' && <Sparkles />}
      {state === 'dirty' && <DirtySmudge />}
      {state === 'sleeping' && <SleepZzz />}
    </svg>
  );
};

const AetherwingArt: Pet['ArtComponent'] = ({ state, ...props }) => {
    const expressions = {
    idle: { pupils: "M10 11h.01M14 11h.01", mouth: "M10 15h4" },
    happy: { pupils: "M10 10.5h.01M14 10.5h.01", mouth: "M10 15c2 1.5 4 0 4 0" },
    hungry: { pupils: "M10 11h.01M14 11h.01", mouth: "M11 15 a 1,1 0 1,0 2,0" },
    sad: { pupils: "M10 11.5h.01M14 11.5h.01", mouth: "M10 16c2-1.5 4 0 4 0" },
    eating: { pupils: "M10 10.5h.01M14 10.5h.01", mouth: "M10 14.5 a 2,2 0 0,1 4,0" },
    playing: { pupils: "M10 10.5h.01M14 10.5h.01", mouth: "M10 15c2 1.5 4 0 4 0" },
    grooming: { pupils: "M10 10.5h.01M14 10.5h.01", mouth: "M10 15c2 1.5 4 0 4 0" },
    walking: { pupils: "M10 10.5h.01M14 10.5h.01", mouth: "M11 15 h2 v1 h-2 z" },
    anxious: { pupils: "M10 11h.01M14 11h.01", mouth: "M10.5 15.5c1-.5 2-.5 3 0" },
    sleeping: { pupils: "", mouth: "M11 15 h2" }, // Eyes closed
    tired: { pupils: "M10 11.5h.01M14 11.5h.01", mouth: "M10 16c2-1.5 4 0 4 0" },
    bored: { pupils: "M10 11h.01M14 11h.01", mouth: "M11 15 a 1.5,1.5 0 1,1 2,0" },
    lonely: { pupils: "M9.5 11.5h.01M13.5 11.5h.01", mouth: "M10 16c2-1.5 4 0 4 0" }, // Teary eyes
    dirty: { pupils: "M10 11.5h.01M14 11.5h.01", mouth: "M10 15h4" },
    needs_potty: { pupils: "M10 11h.01M14 11h.01", mouth: "M10.5 15.5c1-.5 2-.5 3 0" },
  };
  const current = expressions[state] || expressions.idle;
  const animationClass = state === 'anxious' ? 'animate-pulse-fast' : state === 'playing' || state === 'walking' ? 'animate-bounce' : state === 'eating' ? 'animate-pulse' : '';

  return (
    <svg viewBox="0 0 24 24" fill="none" strokeWidth="1.5" stroke="currentColor" {...props} className={`${props.className} ${animationClass}`}>
        <style>{`.animate-pulse-fast { animation: pulse 0.8s cubic-bezier(0.4, 0, 0.6, 1) infinite; }`}</style>
        <path d="M12 2L2 12l10 10 10-10L12 2z" stroke="#38bdf8"/>
        <path d="M12 2V12h10" stroke="#38bdf8" opacity="0.5"/>
        <circle cx="10" cy="11" r="2" fill="white" stroke="none" className={state === 'sleeping' ? 'hidden' : ''}/>
        <circle cx="14" cy="11" r="2" fill="white" stroke="none" className={state === 'sleeping' ? 'hidden' : ''}/>
        {state === 'sleeping' && <path d="M9 11.5c.5-.5 1.5-.5 2 0 M13 11.5c.5-.5 1.5-.5 2 0" stroke="white" strokeLinecap="round" />}
        <path d={current.pupils} fill="black" stroke="none"/>
        <path d={current.mouth} stroke="#fff" strokeLinecap="round"/>
        <path d="M4 18l4-4" stroke="#f472b6" strokeLinecap="round"/>
        <path d="M20 18l-4-4" stroke="#f472b6" strokeLinecap="round"/>
        {state === 'grooming' && <Sparkles />}
        {state === 'dirty' && <DirtySmudge />}
        {state === 'sleeping' && <SleepZzz />}
    </svg>
  );
};

const GlimmerfangArt: Pet['ArtComponent'] = ({ state, ...props }) => {
    const expressions = {
    idle: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M10 15h4" },
    happy: { eyes: "M9 9.5 h2 M15 9.5 h2", mouth: "M10 15q2 1.5 4 0" },
    hungry: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M11 15 h2 v1 h-2z" },
    sad: { eyes: "M9 11 h2 M15 11 h2", mouth: "M10 16q2-1.5 4 0" },
    eating: { eyes: "M9 9.5 h2 M15 9.5 h2", mouth: "M10.5 14.5 a 1.5,1.5 0 0,1 3,0" },
    playing: { eyes: "M9 9.5 h2 M15 9.5 h2", mouth: "M10 15q2 1.5 4 0" },
    grooming: { eyes: "M9 9.5 h2 M15 9.5 h2", mouth: "M10 15q2 1.5 4 0" },
    walking: { eyes: "M9 9.5 h2 M15 9.5 h2", mouth: "M11 14.5 h2 v1.5 h-2z" },
    anxious: { eyes: "M9 10 l1 1 M10 11 l-1 -1 M15 10 l1 1 M16 11 l-1 -1", mouth: "M10 15.5 h4" },
    sleeping: { eyes: "M9 10.5 h2 M15 10.5 h2", mouth: "M11 15h2" },
    tired: { eyes: "M9 10.5 v1.5 M11 10.5 v1.5 M15 10.5 v1.5 M17 10.5 v1.5", mouth: "M10 16q2-1.5 4 0" },
    bored: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M10.5 15 a 1.5,1.5 0 1,1 3,0" },
    lonely: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M10 16q2-1.5 4 0" },
    dirty: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M10 15h4" },
    needs_potty: { eyes: "M9 10 l2 2 M11 10 l-2 2 M15 10 l2 2 M17 10 l-2 2", mouth: "M10.5 15.5c-1 1 5 1 4 0" },
  };
  const current = expressions[state] || expressions.idle;
  const animationClass = state === 'anxious' ? 'animate-pulse-fast' : state === 'playing' || state === 'walking' ? 'animate-bounce' : state === 'eating' ? 'animate-pulse' : '';

  return (
    <svg viewBox="0 0 24 24" fill="none" strokeWidth="1.5" stroke="currentColor" {...props} className={`${props.className} ${animationClass}`}>
      <style>{`.animate-pulse-fast { animation: pulse 0.8s cubic-bezier(0.4, 0, 0.6, 1) infinite; }`}</style>
      <path d="M12 2 L22 7 L18 21 H6 L2 7 Z" stroke="#a78bfa"/>
      <path d="M9 19 l-4-10" stroke="#f472b6" opacity="0.7"/>
      <path d="M15 19 l4-10" stroke="#f472b6" opacity="0.7"/>
      <path d={current.eyes} stroke="#fff" strokeLinecap="round"/>
      <path d={current.mouth} stroke="#fff" strokeLinecap="round"/>
      {state === 'grooming' && <Sparkles />}
      {state === 'dirty' && <DirtySmudge />}
      {state === 'sleeping' && <SleepZzz />}
    </svg>
  );
};

// --- Pet Definitions ---

export const PET_OPTIONS: Pet[] = [
  {
    id: 'sparklynx',
    name: 'Sparklynx',
    description: 'A playful node forged from cosmic dust and raw network energy. It thrives on joyful interaction and stable connections.',
    ArtComponent: SparklynxArt,
  },
  {
    id: 'aetherwing',
    name: 'Aetherwing',
    description: 'This crystalline entity glides through data streams. It requires frequent synchronization to maintain its ethereal form.',
    ArtComponent: AetherwingArt,
  },
  {
    id: 'glimmerfang',
    name: 'Glimmerfang',
    description: 'A stoic, resilient node with a core of solidified light. Its energy levels must be carefully managed to prevent decay.',
    ArtComponent: GlimmerfangArt,
  },
];


// --- Simulated Player Data ---
export const SIMULATED_PLAYERS: SimulatedPlayer[] = [
    {
        id: 'player_b',
        name: 'Echo_Shard_42',
        pet: PET_OPTIONS[1], // Aetherwing
    },
    {
        id: 'player_c',
        name: 'Node_7B',
        pet: PET_OPTIONS[2], // Glimmerfang
    },
     {
        id: 'player_d',
        name: 'Ghost_in_the_Circuit',
        pet: PET_OPTIONS[0], // Sparklynx
    }
];
