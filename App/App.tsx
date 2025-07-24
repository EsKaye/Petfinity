import React, { useState, useEffect, useCallback } from 'react';
import { Pet, PetStats, PetState, SimulatedPlayer, TradeSession, WalkBlock, WalkBlockType } from './types';
import { PET_OPTIONS, SIMULATED_PLAYERS } from './constants';
import Header from './components/Header';
import AdoptionScreen from './components/FileBrowser';
import HomeScreen from './components/Readme';
import CareGuide from './components/Sidebar';
import NetworkScreen from './components/NetworkScreen';
import TradeModal from './components/TradeModal';
import WalkScreen from './components/WalkScreen';
import ReflectionScreen from './components/ReflectionScreen';

const initialStats: PetStats = {
  energy: 100,
  hunger: 80,
  fun: 80,
  social: 80,
  hygiene: 100,
  bladder: 80,
  training: 0,
};

const App: React.FC = () => {
  const [view, setView] = useState<'adoption' | 'home' | 'network' | 'walk' | 'reflection'>('adoption');
  const [adoptedPet, setAdoptedPet] = useState<Pet | null>(null);
  const [petName, setPetName] = useState('');
  const [stats, setStats] = useState<PetStats>(initialStats);
  const [petState, setPetState] = useState<PetState>('idle');
  const [dialogue, setDialogue] = useState<string | null>(null);
  const [showCareGuide, setShowCareGuide] = useState(false);
  const [isInteracting, setIsInteracting] = useState(false);

  // --- User State ---
  const [aura, setAura] = useState(100);

  const [players, setPlayers] = useState<SimulatedPlayer[]>(SIMULATED_PLAYERS);
  const [tradeSession, setTradeSession] = useState<TradeSession | null>(null);

  // --- Walk Mini-Game State ---
  const [walkPath, setWalkPath] = useState<WalkBlock[]>([]);
  const [walkPosition, setWalkPosition] = useState(0);
  const [walkRewards, setWalkRewards] = useState({ fun: 0, social: 0 });
  const [walkEventMessage, setWalkEventMessage] = useState<string | null>(null);


  // Game loop for stats and aura decay
  useEffect(() => {
    if (!adoptedPet || isInteracting || view !== 'home' || petState === 'sleeping') return;

    const gameTick = setInterval(() => {
      const auraModifier = aura < 30 ? 1.5 : aura > 80 ? 0.75 : 1;
      setStats(prev => ({
        ...prev,
        energy: Math.max(0, prev.energy - (0.5 * auraModifier)),
        hunger: Math.max(0, prev.hunger - (1 * auraModifier)),
        fun: Math.max(0, prev.fun - (0.7 * auraModifier)),
        social: Math.max(0, prev.social - (0.4 * auraModifier)),
        hygiene: Math.max(0, prev.hygiene - (0.3 * auraModifier)),
        bladder: Math.max(0, prev.bladder - (0.8 * auraModifier)),
      }));
       setAura(a => Math.max(0, a - 1));
    }, 5000);

    return () => clearInterval(gameTick);
  }, [adoptedPet, isInteracting, view, aura, petState]);

  // Update pet's visual state and dialogue based on stats and aura
  useEffect(() => {
    if (isInteracting || tradeSession || view !== 'home' || petState === 'sleeping') return;
    
    const petDisplayName = petName || 'Your pet';
    
    if (aura < 30) {
      setPetState('anxious');
      setDialogue(`${petDisplayName} feels a strange tension in the network...`);
    } else if (stats.bladder < 20) {
      setPetState('needs_potty');
      setDialogue(`${petDisplayName} is squirming... it needs to go on a walk!`);
    } else if (stats.energy < 20) {
      setPetState('tired');
      setDialogue(`${petDisplayName} looks exhausted and needs to sleep.`);
    } else if (stats.hunger < 20) {
      setPetState('hungry');
      setDialogue(`${petDisplayName} seems to be hungry...`);
    } else if (stats.hygiene < 30) {
      setPetState('dirty');
      setDialogue(`${petDisplayName} could really use a cleaning.`);
    } else if (stats.social < 30) {
      setPetState('lonely');
      setDialogue(`${petDisplayName} looks a bit lonely.`);
    } else if (stats.fun < 30) {
      setPetState('bored');
      setDialogue(`${petDisplayName} seems bored and needs some fun.`);
    } else if (stats.fun > 95 && stats.hunger > 95) {
      setPetState('happy');
    } else {
      setPetState('idle');
    }
  }, [stats, isInteracting, petName, dialogue, tradeSession, view, aura, petState]);
  
  const handleAdopt = useCallback((pet: Pet) => {
    setAdoptedPet(pet);
    setPetName(pet.name);
    setStats(initialStats);
    setAura(100);
    setShowCareGuide(true);
    setView('home');
  }, []);

  const handleInteraction = (
      stateChange: Partial<PetStats>, 
      animationState: PetState, 
      duration: number,
      newDialogue: string | null
    ) => {
    if (isInteracting || aura < 30 || petState === 'sleeping') {
      if(aura < 30) setDialogue(`${petName || 'Your pet'} is too anxious to react right now.`);
      if(petState === 'sleeping') setDialogue(`${petName || 'Your pet'} is fast asleep...`);
      return;
    }

    setIsInteracting(true);
    setPetState(animationState);
    if(newDialogue) setDialogue(newDialogue);

    setTimeout(() => {
      setStats(s => ({
        energy: Math.min(100, Math.max(0, s.energy + (stateChange.energy || 0))),
        hunger: Math.min(100, Math.max(0, s.hunger + (stateChange.hunger || 0))),
        fun: Math.min(100, Math.max(0, s.fun + (stateChange.fun || 0))),
        social: Math.min(100, Math.max(0, s.social + (stateChange.social || 0))),
        hygiene: Math.min(100, Math.max(0, s.hygiene + (stateChange.hygiene || 0))),
        bladder: Math.min(100, Math.max(0, s.bladder + (stateChange.bladder || 0))),
        training: Math.min(100, Math.max(0, s.training + (stateChange.training || 0))),
      }));
      setIsInteracting(false);
      setDialogue(null);
    }, duration);
  };
  
  const handleFeed = useCallback(() => {
    handleInteraction({ hunger: 40, bladder: -20 }, 'eating', 2000, 'Yum!');
  }, [isInteracting, aura, petName]);

  const handlePlay = useCallback(() => {
    handleInteraction({ fun: 30, social: 15, energy: -10 }, 'playing', 2000, `${petName || 'Your pet'} is having a great time!`);
  }, [isInteracting, petName, aura]);

  const handleTrain = useCallback(() => {
    handleInteraction({ training: 5, fun: 5, energy: -15 }, 'happy', 1500, `${petName || 'Your pet'} learned something new!`);
  }, [isInteracting, petName, aura]);

  const handleGroom = useCallback(() => {
    handleInteraction({ hygiene: 100, fun: 10 }, 'grooming', 2000, 'Feeling fresh and clean!');
  }, [isInteracting, aura]);

  const handleSleep = useCallback(() => {
    if (isInteracting) return;
    setIsInteracting(true);
    setPetState('sleeping');
    setDialogue('Zzz...');

    let sleptTime = 0;
    const sleepDuration = 10000; // 10 seconds
    const sleepInterval = setInterval(() => {
      sleptTime += 500;
      setStats(s => ({ ...s, energy: Math.min(100, s.energy + 5) }));
      if(sleptTime >= sleepDuration) {
        clearInterval(sleepInterval);
        setIsInteracting(false);
        setDialogue(`${petName || 'Your pet'} is awake and refreshed!`);
        setPetState('idle');
         setTimeout(() => setDialogue(null), 2000);
      }
    }, 500);
  }, [isInteracting, petName]);

  const handleRestoreAura = useCallback((amount: number) => {
    setAura(a => Math.min(100, a + amount));
    setView('home');
    setDialogue('You feel a sense of calm. Your companion feels it too.');
    setTimeout(() => setDialogue(null), 3000);
  }, []);

  const generateWalkPath = (length = 10): WalkBlock[] => {
    const types: WalkBlockType[] = ['treat', 'obstacle', 'friend'];
    const weights: Record<WalkBlockType, number> = { empty: 0.5, treat: 0.25, obstacle: 0.15, friend: 0.1 };
    let path: WalkBlock[] = [];
    for (let i = 0; i < length; i++) {
        let rand = Math.random();
        let type: WalkBlockType = 'empty';
        if (rand < weights.treat) type = 'treat';
        else if (rand < weights.treat + weights.obstacle) type = 'obstacle';
        else if (rand < weights.treat + weights.obstacle + weights.friend) type = 'friend';
        path.push({ id: i, type, discovered: false });
    }
    return path;
  }

  const handleBeginWalk = useCallback(() => {
    if (aura < 30 || petState === 'tired') {
        setDialogue(`${petName || 'Your pet'} is too anxious or tired for a walk.`);
        return;
    }
    const newPath = generateWalkPath();
    setWalkPath(newPath);
    setWalkPosition(0);
    setWalkRewards({ fun: 0, social: 0 });
    setWalkEventMessage('Let\'s go for a walk!');
    setView('walk');
  }, [aura, petName, petState]);

  const handleWalkStep = useCallback(() => {
    if(walkPosition >= walkPath.length) return;

    const currentBlock = walkPath[walkPosition];
    let newRewards = { ...walkRewards };
    let message = '...';

    switch(currentBlock.type) {
        case 'treat':
            newRewards.fun += 5;
            message = 'You found a fun new data-node!';
            break;
        case 'obstacle':
            newRewards.fun -= 5;
            message = 'You navigated a tricky firewall!';
            break;
        case 'friend':
            newRewards.fun += 10;
            newRewards.social += 20;
            message = 'You met another friendly node!';
            break;
        case 'empty':
            message = 'The path is clear.';
            break;
    }

    setWalkPath(p => p.map(b => b.id === currentBlock.id ? { ...b, discovered: true } : b));
    setWalkRewards(newRewards);
    setWalkEventMessage(message);
    
    setTimeout(() => {
        if(walkPosition + 1 >= walkPath.length){
            handleEndWalk(newRewards);
        } else {
            setWalkPosition(p => p + 1);
        }
    }, 1000);

  }, [walkPath, walkPosition, walkRewards]);

  const handleEndWalk = useCallback((finalRewards?: {fun: number; social: number}) => {
    const rewardsToApply = finalRewards || walkRewards;
    setStats(s => ({
        ...s,
        fun: Math.min(100, s.fun + rewardsToApply.fun + 15), // base fun for finishing
        social: Math.min(100, s.social + rewardsToApply.social),
        energy: Math.max(0, s.energy - 20),
        hygiene: Math.max(0, s.hygiene - 10),
        bladder: 100 // Walk relieves bladder fully
    }));
    setView('home');
    setDialogue('What a great walk that was!');
    setTimeout(() => setDialogue(null), 3000);
  }, [walkRewards]);


  const handleRestart = useCallback(() => {
    setAdoptedPet(null);
    setPetName('');
    setDialogue(null);
    setView('adoption');
  }, []);

  const handleNavigate = (targetView: 'home' | 'network' | 'reflection') => {
    setView(targetView);
  };
  
  const handleInitiateTrade = (partner: SimulatedPlayer) => {
    setTradeSession({ partner });
  };
  
  const handleCancelTrade = () => {
    setTradeSession(null);
  };
  
  const handleConfirmTrade = () => {
    if (!tradeSession || !adoptedPet) return;
  
    const partnerId = tradeSession.partner.id;
    const myOldPet = adoptedPet;
    const theirOldPet = tradeSession.partner.pet;
  
    setPlayers(currentPlayers => 
      currentPlayers.map(p => 
        p.id === partnerId ? { ...p, pet: myOldPet } : p
      )
    );
  
    setAdoptedPet(theirOldPet);
    setPetName(theirOldPet.name);
    setStats(initialStats);
    setAura(100);
    setDialogue(`You've successfully traded for ${theirOldPet.name}!`);
  
    setTradeSession(null);
    setView('home');
  };

  const renderView = () => {
    switch(view) {
        case 'adoption':
            return <AdoptionScreen pets={PET_OPTIONS} onAdopt={handleAdopt} />;
        case 'home':
            if (!adoptedPet) return <AdoptionScreen pets={PET_OPTIONS} onAdopt={handleAdopt} />; // Fallback
            return (
                <HomeScreen
                  pet={adoptedPet}
                  petName={petName}
                  setPetName={setPetName}
                  stats={stats}
                  aura={aura}
                  petState={petState}
                  dialogue={dialogue}
                  setDialogue={setDialogue}
                  onFeed={handleFeed}
                  onPlay={handlePlay}
                  onTrain={handleTrain}
                  onGroom={handleGroom}
                  onWalk={handleBeginWalk}
                  onSleep={handleSleep}
                  onToggleCareGuide={() => setShowCareGuide(s => !s)}
                  onRestart={handleRestart}
                  onNavigateToNetwork={() => handleNavigate('network')}
                  onNavigateToReflection={() => handleNavigate('reflection')}
                  isInteracting={isInteracting}
                />
            );
        case 'network':
            return <NetworkScreen players={players} onInitiateTrade={handleInitiateTrade} onBack={() => handleNavigate('home')} />;
        case 'walk':
            if (!adoptedPet) return <AdoptionScreen pets={PET_OPTIONS} onAdopt={handleAdopt} />; // Fallback
            return <WalkScreen
                      pet={adoptedPet}
                      path={walkPath}
                      position={walkPosition}
                      onStep={handleWalkStep}
                      onEndWalk={handleEndWalk}
                      eventMessage={walkEventMessage}
                    />;
        case 'reflection':
            return <ReflectionScreen onRestoreAura={handleRestoreAura} onBack={() => handleNavigate('home')} />;
        default:
            return <AdoptionScreen pets={PET_OPTIONS} onAdopt={handleAdopt} />;
    }
  }

  return (
    <div className="bg-amber-100 text-zinc-800 min-h-screen font-sans antialiased flex flex-col overflow-hidden" style={{ fontFamily: "'Comic Sans MS', 'Chalkboard SE', 'cursive'" }}>
      <Header />
      <main className="flex-grow max-w-screen-md mx-auto p-2 sm:p-4 w-full h-full flex flex-col">
        <div className="relative w-full h-full flex-grow flex flex-col bg-slate-200 rounded-2xl shadow-inner-lg" style={{boxShadow: 'inset 0 4px 10px 0 rgb(0 0 0 / 0.15)'}}>
            {renderView()}
            {showCareGuide && <CareGuide onClose={() => setShowCareGuide(false)} />}
            {tradeSession && adoptedPet && (
                <TradeModal
                    myPet={adoptedPet}
                    tradeSession={tradeSession}
                    onConfirm={handleConfirmTrade}
                    onCancel={handleCancelTrade}
                />
            )}
        </div>
      </main>
       <footer className="text-center p-4 text-amber-800/80 text-xs">
          <p>This project is part of the <strong>Divina L3 Open-Source Game Network</strong></p>
          <p>Fork. Build. Evolve. Every game is a shard of the mythos.</p>
       </footer>
    </div>
  );
};

export default App;
