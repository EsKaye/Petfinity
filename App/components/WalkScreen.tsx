import React from 'react';
import { Pet, WalkBlock, WalkBlockType } from '../types';

const BlockIcon: React.FC<{type: WalkBlockType}> = ({type}) => {
    switch(type) {
        case 'treat': return <span className="text-2xl">🍬</span>;
        case 'obstacle': return <span className="text-2xl">🚧</span>;
        case 'friend': return <span className="text-2xl">😊</span>;
        case 'empty': return <span className="text-xl text-slate-400">·</span>;
        default: return null;
    }
}

interface WalkScreenProps {
    pet: Pet;
    path: WalkBlock[];
    position: number;
    eventMessage: string | null;
    onStep: () => void;
    onEndWalk: () => void;
}

const WalkScreen: React.FC<WalkScreenProps> = ({ pet, path, position, eventMessage, onStep, onEndWalk }) => {
    const isWalkOver = position >= path.length;

    return (
        <div className="flex-grow w-full h-full flex flex-col items-center justify-between animate-fade-in relative overflow-hidden rounded-2xl p-4 bg-lime-50/80 border border-lime-200">
            {/* Walk Path Display */}
            <div className="w-full bg-white/60 rounded-lg p-2 shadow-inner">
                <div className="flex justify-center items-center space-x-1 sm:space-x-2">
                    {path.map((block, index) => (
                        <div key={block.id} className={`w-10 h-10 sm:w-12 sm:h-12 rounded-lg flex items-center justify-center border-2 transition-all duration-300 ${index === position && !isWalkOver ? 'bg-yellow-200 border-yellow-400 scale-110' : 'bg-lime-100 border-lime-300'}`}>
                            {block.discovered ? <BlockIcon type={block.type} /> : <span className="text-2xl font-bold text-lime-600">?</span>}
                        </div>
                    ))}
                </div>
            </div>

            {/* Pet and Event Area */}
            <div className="flex-grow flex flex-col items-center justify-center relative w-full">
                <div className="absolute top-4 w-full px-2">
                    {eventMessage && <p className="text-center bg-white/80 text-zinc-700 font-semibold p-2 rounded-lg shadow-md animate-fade-in">{eventMessage}</p>}
                </div>
                <pet.ArtComponent state="walking" className="w-40 h-40 sm:w-48 sm:h-48 animate-bounce" />
            </div>

            {/* Controls */}
            <div className="w-full flex justify-center items-center space-x-4 p-2">
                 <button 
                    onClick={onEndWalk}
                    className="bg-red-400 text-white font-bold py-3 px-6 rounded-lg hover:bg-red-500 transition-all duration-200 shadow-md active:shadow-inner transform active:scale-95 disabled:opacity-60"
                    aria-label="End Walk"
                    disabled={isWalkOver}
                >
                    End Walk
                </button>
                <button 
                    onClick={onStep}
                    className="bg-green-500 text-white font-bold py-4 px-10 rounded-lg hover:bg-green-600 transition-all duration-200 shadow-lg active:shadow-inner transform active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed"
                    aria-label="Next Step"
                    disabled={isWalkOver}
                >
                    {isWalkOver ? 'Finished!' : 'Next Step'}
                </button>
            </div>
        </div>
    );
};

export default WalkScreen;