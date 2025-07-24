import React from 'react';
import { Pet, PetStats, PetState } from '../types';

const DialogueBox: React.FC<{ message: string; onClose: () => void }> = ({ message, onClose }) => (
    <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-full mt-[-80px] w-11/12 max-w-xs bg-yellow-100 border-2 border-yellow-300 text-gray-800 rounded-lg p-4 shadow-lg animate-fade-in-up z-20">
        <p className="text-center text-lg">{message}</p>
        <button onClick={onClose} className="absolute -top-2 -right-2 w-7 h-7 bg-red-500 text-white font-bold rounded-full border-2 border-white flex items-center justify-center shadow-md">X</button>
    </div>
);

const NeedsDisplay: React.FC<{ stats: PetStats, aura: number }> = ({ stats, aura }) => {
    const needs = [
        { label: '⚡', value: stats.energy, color: 'bg-yellow-400', tooltip: 'Energy' },
        { label: '🍔', value: stats.hunger, color: 'bg-orange-400', tooltip: 'Hunger' },
        { label: '😊', value: stats.fun, color: 'bg-green-400', tooltip: 'Fun' },
        { label: '💖', value: stats.social, color: 'bg-pink-400', tooltip: 'Social' },
        { label: '🧼', value: stats.hygiene, color: 'bg-cyan-400', tooltip: 'Hygiene' },
        { label: '💧', value: stats.bladder, color: 'bg-blue-400', tooltip: 'Bladder' },
    ];

    return (
        <div className="grid grid-cols-2 gap-x-3 gap-y-2 p-2">
            {needs.map(need => <StatusBar key={need.tooltip} {...need} />)}
             <div className="col-span-2 mt-1">
                <StatusBar value={aura} color="bg-sky-400" label="✨" tooltip="Aura" />
            </div>
        </div>
    );
};

const StatusBar: React.FC<{ value: number, color: string, label: string, tooltip: string }> = ({ value, color, label, tooltip }) => (
    <div className="w-full group relative">
        <div className="flex justify-between items-center mb-0.5">
            <span className="text-lg font-medium text-zinc-600">{label}</span>
        </div>
        <div className="w-full bg-slate-300 rounded-full h-3.5 border border-slate-400/50 shadow-inner">
            <div className={`${color} h-full rounded-full transition-all duration-500`} style={{ width: `${value}%` }}></div>
        </div>
    </div>
);

const ActionBar: React.FC<{ 
    onFeed: () => void; 
    onPlay: () => void; 
    onTrain: () => void; 
    onGroom: () => void; 
    onWalk: () => void; 
    onSleep: () => void; 
    disabled: boolean 
}> = ({ onFeed, onPlay, onTrain, onGroom, onWalk, onSleep, disabled }) => {
    const buttonClass = "bg-white text-zinc-700 font-bold py-2 rounded-lg shadow-md border-2 border-gray-300 hover:bg-gray-50 active:shadow-inner active:scale-95 transition-all transform disabled:opacity-60 disabled:cursor-not-allowed disabled:transform-none text-xs w-16 h-10 flex items-center justify-center";

    return (
        <div className="grid grid-cols-3 gap-2">
            <button onClick={onFeed} className={buttonClass} disabled={disabled} aria-label="Feed Pet">Feed</button>
            <button onClick={onPlay} className={buttonClass} disabled={disabled} aria-label="Play with Pet">Play</button>
            <button onClick={onGroom} className={buttonClass} disabled={disabled} aria-label="Groom Pet">Groom</button>
            <button onClick={onWalk} className={buttonClass} disabled={disabled} aria-label="Walk Pet">Walk</button>
            <button onClick={onTrain} className={buttonClass} disabled={disabled} aria-label="Train Pet">Train</button>
            <button onClick={onSleep} className={buttonClass} disabled={disabled} aria-label="Sleep">Sleep</button>
        </div>
    );
};

interface HomeScreenProps {
    pet: Pet;
    petName: string;
    setPetName: (name: string) => void;
    stats: PetStats;
    aura: number;
    petState: PetState;
    dialogue: string | null;
    setDialogue: (message: string | null) => void;
    onFeed: () => void;
    onPlay: () => void;
    onTrain: () => void;
    onGroom: () => void;
    onWalk: () => void;
    onSleep: () => void;
    onToggleCareGuide: () => void;
    onRestart: () => void;
    onNavigateToNetwork: () => void;
    onNavigateToReflection: () => void;
    isInteracting: boolean;
}

const HomeScreen: React.FC<HomeScreenProps> = (props) => {
    const { pet, petName, setPetName, stats, aura, petState, dialogue, setDialogue, onFeed, onPlay, onTrain, onGroom, onWalk, onSleep, onToggleCareGuide, onNavigateToNetwork, onNavigateToReflection, isInteracting } = props;
    
    const roomStyle = {
      background: 'linear-gradient(to bottom, #fdf6e3 65%, #f4e8c1 65%, #d1b48c 65%, #c6a779 100%)',
    };

    return (
        <div className="flex-grow w-full h-full flex flex-col items-center justify-between animate-fade-in relative overflow-hidden rounded-2xl">
            {/* Room Area */}
            <div className="w-full flex-grow relative flex flex-col items-center justify-end" style={roomStyle}>
                 <input 
                    type="text"
                    value={petName}
                    onChange={(e) => setPetName(e.target.value)}
                    className="absolute top-2 text-2xl font-bold text-zinc-700/80 bg-transparent text-center w-full focus:outline-none"
                    aria-label="Pet's name"
                />
                <div className="mb-4 relative">
                    {dialogue && <DialogueBox message={dialogue} onClose={() => setDialogue(null)} />}
                    <pet.ArtComponent state={petState} className="w-48 h-48 sm:w-56 sm:h-56" />
                </div>
            </div>

            {/* UI Panel Area */}
            <div className="w-full h-40 bg-slate-200 border-t-4 border-slate-400/80 p-3 flex justify-between items-center shadow-top">
                <NeedsDisplay stats={stats} aura={aura} />
                <ActionBar onFeed={onFeed} onPlay={onPlay} onTrain={onTrain} onGroom={onGroom} onWalk={onWalk} onSleep={onSleep} disabled={isInteracting || petState === 'sleeping'} />
                 <div className="flex flex-col space-y-2">
                     <button onClick={onToggleCareGuide} className="bg-sky-400 text-white w-9 h-9 rounded-full flex items-center justify-center hover:bg-sky-500 transition-colors shadow-md text-2xl font-bold" aria-label="Open Care Guide">?</button>
                     <button onClick={onNavigateToReflection} className="bg-purple-400 text-white w-9 h-9 rounded-full flex items-center justify-center hover:bg-purple-500 transition-colors shadow-md text-xl" aria-label="Go to Reflection">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-12v4m-2-2h4m5 10v4m-2-2h4M5 3a2 2 0 00-2 2v1m14 0V5a2 2 0 00-2-2h-1m-4 16v-1a2 2 0 00-2-2H9a2 2 0 00-2 2v1m14 0v-1a2 2 0 00-2-2h-1m-4-16a2 2 0 012 2v1h-4V5a2 2 0 012-2z" /></svg>
                     </button>
                     <button onClick={onNavigateToNetwork} className="bg-lime-500 text-white w-9 h-9 rounded-full flex items-center justify-center hover:bg-lime-600 transition-colors shadow-md text-xl" aria-label="Go to Network">
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}><path strokeLinecap="round" strokeLinejoin="round" d="M13 5l7 7-7 7M5 5l7 7-7 7" /></svg>
                     </button>
                </div>
            </div>
        </div>
    );
};

export default HomeScreen;
