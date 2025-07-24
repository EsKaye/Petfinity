import React from 'react';
import { Pet, TradeSession } from '../types';

interface TradeModalProps {
    myPet: Pet;
    tradeSession: TradeSession;
    onConfirm: () => void;
    onCancel: () => void;
}

const TradeModal: React.FC<TradeModalProps> = ({ myPet, tradeSession, onConfirm, onCancel }) => {
    const { partner } = tradeSession;

    return (
        <div className="absolute inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fade-in z-30">
            <div className="relative bg-amber-100 border-4 border-amber-300 rounded-xl p-6 max-w-2xl w-full space-y-4 shadow-2xl text-zinc-800 transform scale-100 transition-transform">
                <h3 className="text-3xl font-bold text-sky-600 text-center mb-4">Trade Proposal</h3>
                
                <div className="flex items-center justify-around w-full">
                    {/* Your Offer */}
                    <div className="flex flex-col items-center p-4 bg-white/70 rounded-lg border-2 border-slate-300 shadow-inner">
                        <h4 className="text-lg font-semibold text-zinc-700 mb-2">Your Node</h4>
                        <myPet.ArtComponent state="idle" className="w-32 h-32" />
                        <p className="mt-2 text-xl font-bold text-pink-500">{myPet.name}</p>
                    </div>

                    {/* Exchange Icon */}
                    <div className="text-4xl text-lime-500 font-bold mx-4">
                        &harr;
                    </div>

                    {/* Their Offer */}
                    <div className="flex flex-col items-center p-4 bg-white/70 rounded-lg border-2 border-slate-300 shadow-inner">
                        <h4 className="text-lg font-semibold text-zinc-700 mb-2">{partner.name}'s Node</h4>
                        <partner.pet.ArtComponent state="idle" className="w-32 h-32" />
                        <p className="mt-2 text-xl font-bold text-purple-500">{partner.pet.name}</p>
                    </div>
                </div>

                <div className="flex justify-center space-x-6 pt-6">
                    <button onClick={onCancel} className="bg-red-400 text-white font-bold py-3 px-8 rounded-lg hover:bg-red-500 transition-all duration-200 shadow-md active:shadow-inner transform active:scale-95">
                        Cancel
                    </button>
                    <button onClick={onConfirm} className="bg-green-500 text-white font-bold py-3 px-8 rounded-lg hover:bg-green-600 transition-all duration-200 shadow-md active:shadow-inner transform active:scale-95">
                        Confirm Trade
                    </button>
                </div>
            </div>
        </div>
    );
};

export default TradeModal;
