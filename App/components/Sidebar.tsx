import React from 'react';

const NeedExplanation: React.FC<{
    emoji: string;
    title: string;
    colorClass: string;
    description: string;
    children: React.ReactNode;
}> = ({ emoji, title, colorClass, description, children }) => (
    <div>
        <h4 className={`font-semibold ${colorClass}`}>{emoji} {title}</h4>
        <p className="text-sm text-zinc-600">{description} Replenish it with: {children}</p>
    </div>
);

const CareGuide: React.FC<{ onClose: () => void; }> = ({ onClose }) => {
    return (
        <div className="absolute inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 animate-fade-in z-20">
            <aside className="relative bg-amber-100 border-2 border-amber-300 rounded-lg p-6 max-w-lg w-full space-y-4 shadow-2xl text-zinc-800">
                <button onClick={onClose} className="absolute top-2 right-2 text-zinc-500 hover:text-zinc-800" aria-label="Close guide">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-7 w-7" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" /></svg>
                </button>
                <h3 className="text-2xl font-bold text-sky-600">AthenaMist's Care Protocol v2.0</h3>
                <p className="text-zinc-700">
                    Your companion node is now a more complex entity, with a full spectrum of simulated needs. Balance these needs to ensure your node remains stable, happy, and healthy.
                </p>
                <div className="space-y-3 pt-2 border-t border-amber-300/80">
                    <NeedExplanation emoji="✨" title="Aura" colorClass="text-purple-600" description="Your companion mirrors your own well-being. A low Aura will cause your node to feel anxious and its needs will decay faster. Tend to your Aura in the Reflection space.">
                        <strong className="text-purple-700">Reflection</strong>.
                    </NeedExplanation>
                    <NeedExplanation emoji="⚡" title="Energy" colorClass="text-yellow-600" description="Your node expends energy by being awake and active. If it gets too low, it will become tired and unable to play or train.">
                        <strong className="text-yellow-700">Sleep</strong>.
                    </NeedExplanation>
                     <NeedExplanation emoji="🍔" title="Hunger" colorClass="text-orange-600" description="All nodes must process data to survive. This is your node's primary need.">
                        <strong className="text-orange-700">Feed</strong>.
                    </NeedExplanation>
                     <NeedExplanation emoji="😊" title="Fun" colorClass="text-green-600" description="A bored node is an unhappy node. Keep it entertained to maintain a healthy connection.">
                        <strong className="text-green-700">Play</strong>, <strong className="text-blue-700">Walk</strong>, and <strong className="text-purple-700">Train</strong>.
                    </NeedExplanation>
                     <NeedExplanation emoji="💖" title="Social" colorClass="text-pink-600" description="Nodes are social creatures. They require interaction to feel secure and part of the network.">
                        <strong className="text-pink-700">Play</strong> and meeting friends on <strong className="text-blue-700">Walks</strong>.
                    </NeedExplanation>
                     <NeedExplanation emoji="🧼" title="Hygiene" colorClass="text-cyan-600" description="A node's core code can get messy over time. Regular maintenance is required. Walking also makes it a bit dirty.">
                        <strong className="text-cyan-700">Groom</strong>.
                    </NeedExplanation>
                     <NeedExplanation emoji="💧" title="Bladder" colorClass="text-blue-600" description="What goes in must come out. Feeding fills the bladder, and a full bladder is uncomfortable.">
                        Taking a <strong className="text-blue-700">Walk</strong> fully relieves the bladder.
                    </NeedExplanation>
                    <div>
                        <h4 className="font-semibold text-lime-600">🌐 Network & Trading</h4>
                        <p className="text-sm text-zinc-600">You are not alone. Use the <strong className="text-lime-700">Network</strong> button to see other nodes. You can propose a trade to exchange companions.</p>
                    </div>
                </div>
                 <p className="text-xs text-zinc-500 pt-2 border-t border-amber-300/80">
                    Powered by <a href="#" className="underline hover:text-sky-500">Divina L3</a> • Anchored by GDI Token • Enriched by AthenaMist AI
                </p>
            </aside>
        </div>
    );
};

export default CareGuide;
