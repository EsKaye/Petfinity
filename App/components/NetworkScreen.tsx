import React from 'react';
import { SimulatedPlayer } from '../types';

interface NetworkScreenProps {
    players: SimulatedPlayer[];
    onInitiateTrade: (player: SimulatedPlayer) => void;
    onBack: () => void;
}

const NetworkScreen: React.FC<NetworkScreenProps> = ({ players, onInitiateTrade, onBack }) => {
    return (
        <div className="bg-amber-50/80 border border-amber-200 rounded-lg p-6 flex flex-col items-center animate-fade-in h-full w-full">
            <div className="text-center mb-6 relative w-full">
                <button onClick={onBack} className="absolute left-0 top-1/2 -translate-y-1/2 bg-white text-zinc-700 font-bold py-2 px-3 rounded-full shadow-md border-2 border-gray-300 hover:bg-gray-50 active:shadow-inner active:scale-95 transition-all transform" aria-label="Go Back">
                    &larr;
                </button>
                <h2 className="text-3xl font-bold text-zinc-800">Neighboring Nodes</h2>
                <p className="text-zinc-600 mt-1">Connect with other custodians in the network.</p>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 w-full overflow-y-auto flex-grow p-2">
                {players.map((player) => (
                    <div key={player.id} className="group bg-white border-2 border-slate-300 rounded-xl p-5 flex flex-col items-center text-center transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl hover:border-sky-400">
                        <player.pet.ArtComponent state="idle" className="w-24 h-24 mb-3 text-pink-400" />
                        <h3 className="text-xl font-semibold text-sky-600">{player.name}</h3>
                        <p className="text-zinc-500 text-sm mb-4">Nurturing a {player.pet.name}</p>
                        <button 
                          onClick={() => onInitiateTrade(player)}
                          className="w-full bg-lime-500 text-white font-bold py-2 px-4 rounded-lg hover:bg-lime-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-lime-400 focus:ring-opacity-75 shadow-md active:shadow-inner transform active:scale-95"
                        >
                          Propose Trade
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default NetworkScreen;
