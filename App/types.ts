import React from 'react';

export type PetState = 'idle' | 'happy' | 'hungry' | 'sad' | 'eating' | 'playing' | 'grooming' | 'walking' | 'anxious' | 'sleeping' | 'tired' | 'bored' | 'lonely' | 'dirty' | 'needs_potty';

export interface Pet {
  id: string;
  name: string;
  description: string;
  ArtComponent: (props: { state: PetState } & React.SVGProps<SVGSVGElement>) => JSX.Element;
}

export interface PetStats {
  energy: number;   // 0-100 (100 is rested)
  hunger: number;   // 0-100 (100 is full)
  fun: number;      // 0-100 (100 is entertained)
  social: number;   // 0-100 (100 is content)
  hygiene: number;  // 0-100 (100 is clean)
  bladder: number;  // 0-100 (100 is relieved)
  training: number; // 0-100 (Skill, not a decaying need)
}

export interface SimulatedPlayer {
  id: string;
  name: string;
  pet: Pet;
}

export interface TradeSession {
  partner: SimulatedPlayer;
}

export type WalkBlockType = 'empty' | 'treat' | 'obstacle' | 'friend';

export interface WalkBlock {
  id: number;
  type: WalkBlockType;
  discovered: boolean;
}
