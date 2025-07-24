import React from 'react';
import { Pet } from '../types';

interface AdoptionScreenProps {
    pets: Pet[];
    onAdopt: (pet: Pet) => void;
}

const AdoptionScreen: React.FC<AdoptionScreenProps> = ({ pets, onAdopt }) => {
    return (
        <div className="bg-amber-50/80 border border-amber-200 rounded-lg p-6 flex flex-col items-center animate-fade-in h-full">
            <div className="text-center mb-6">
                <h2 className="text-3xl font-bold text-zinc-800 mb-2">Activate a New Life Node</h2>
                <p className="text-zinc-600">Every node is alive. Choose a companion to nurture within the network.</p>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full">
                {pets.map((pet) => (
                    <div key={pet.id} className="group bg-white border-2 border-slate-300 rounded-xl p-6 flex flex-col items-center text-center hover:border-sky-400 transition-all duration-300 transform hover:-translate-y-1 hover:shadow-xl">
                        <pet.ArtComponent state="idle" className="w-28 h-28 mb-4 text-pink-400 transition-transform duration-300 group-hover:scale-110" />
                        <h3 className="text-2xl font-semibold text-sky-600 mb-2">{pet.name}</h3>
                        <p className="text-zinc-500 text-sm mb-6 flex-grow">{pet.description}</p>
                        <button 
                          onClick={() => onAdopt(pet)}
                          className="w-full bg-pink-500 text-white font-bold py-3 px-4 rounded-lg hover:bg-pink-600 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-pink-400 focus:ring-opacity-75 shadow-md active:shadow-inner transform active:scale-95"
                        >
                          Activate Node
                        </button>
                    </div>
                ))}
            </div>
        </div>
    );
};

export default AdoptionScreen;