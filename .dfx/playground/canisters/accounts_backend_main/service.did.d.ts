import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface DAO {
  'balanceOf' : ActorMethod<[Account], bigint>,
  'mint' : ActorMethod<[Principal, bigint], undefined>,
  'tokenName' : ActorMethod<[], string>,
  'tokenSymbol' : ActorMethod<[], string>,
  'totalSupply' : ActorMethod<[], bigint>,
  'transfer' : ActorMethod<[Account, Account, bigint], Result>,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Subaccount = Uint8Array | number[];
export interface _SERVICE extends DAO {}
