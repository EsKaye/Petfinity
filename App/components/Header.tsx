
import React from 'react';

const Header: React.FC = () => {
    return (
        <header className="text-center p-3 border-b-2 border-slate-300">
            <h1 className="text-4xl sm:text-5xl font-bold text-pink-500 tracking-wider" style={{ textShadow: '1px 1px #fff, 2px 2px #fbcfe8' }}>
                Petfinity
            </h1>
            <h2 className="text-sky-600 text-xs sm:text-sm uppercase tracking-widest font-semibold">A Divina L3 Shard</h2>
        </header>
    );
};

export default Header;