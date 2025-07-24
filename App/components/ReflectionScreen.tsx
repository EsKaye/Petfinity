import React, { useState } from 'react';

interface ReflectionScreenProps {
    onRestoreAura: (amount: number) => void;
    onBack: () => void;
}

const ReflectionScreen: React.FC<ReflectionScreenProps> = ({ onRestoreAura, onBack }) => {
    const [isFocusing, setIsFocusing] = useState(false);
    const [affirmation, setAffirmation] = useState<string | null>(null);

    const handleFocus = () => {
        setIsFocusing(true);
        setTimeout(() => {
            onRestoreAura(25);
        }, 3000);
    };

    const handleAffirm = () => {
        const affirmations = [
            "I am a capable and calm custodian.",
            "My connection to the network is strong.",
            "I navigate challenges with ease.",
            "Today, I will build something beautiful."
        ];
        const randomAffirmation = affirmations[Math.floor(Math.random() * affirmations.length)];
        setAffirmation(randomAffirmation);
        onRestoreAura(15);
    };

    if (isFocusing) {
        return (
            <div className="flex-grow w-full h-full flex flex-col items-center justify-center animate-fade-in relative overflow-hidden rounded-2xl p-4 bg-gradient-to-br from-purple-200 to-indigo-300">
                <div className="text-center text-white">
                    <p className="text-2xl font-semibold animate-pulse-slow">Breathe in...</p>
                    <p className="text-2xl font-semibold animate-pulse-slow [animation-delay:1.5s]">Breathe out...</p>
                </div>
                 <style>{`.animate-pulse-slow { animation: pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite; }`}</style>
            </div>
        );
    }

    return (
        <div className="flex-grow w-full h-full flex flex-col items-center justify-center animate-fade-in relative overflow-hidden rounded-2xl p-6 bg-gradient-to-br from-sky-100 to-indigo-200">
            <div className="text-center mb-8">
                 <h2 className="text-4xl font-bold text-zinc-800 mb-2">Reflection Space</h2>
                 <p className="text-zinc-600">Tend to your own Aura. A calm mind makes a stable node.</p>
            </div>
            
            <div className="space-y-6 w-full max-w-sm">
                <button 
                    onClick={handleFocus}
                    className="w-full bg-purple-500 text-white font-bold py-4 px-6 rounded-lg hover:bg-purple-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-purple-400 focus:ring-opacity-75 shadow-lg active:shadow-inner transform active:scale-95 text-xl"
                >
                    Focus (Breathe)
                </button>
                <button 
                    onClick={handleAffirm}
                    className="w-full bg-sky-500 text-white font-bold py-4 px-6 rounded-lg hover:bg-sky-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-sky-400 focus:ring-opacity-75 shadow-lg active:shadow-inner transform active:scale-95 text-xl"
                >
                    Recite Affirmation
                </button>
            </div>
            
            {affirmation && (
                <div className="mt-8 p-4 bg-white/70 rounded-lg shadow-md text-center text-indigo-700 font-semibold animate-fade-in">
                    <p>"{affirmation}"</p>
                </div>
            )}
            
            <button onClick={onBack} className="absolute bottom-6 bg-white text-zinc-700 font-bold py-2 px-4 rounded-full shadow-md border-2 border-gray-300 hover:bg-gray-50 active:shadow-inner active:scale-95 transition-all transform" aria-label="Go Back">
                Return to Node
            </button>
        </div>
    );
};

export default ReflectionScreen;
