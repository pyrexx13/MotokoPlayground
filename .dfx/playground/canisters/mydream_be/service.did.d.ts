import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface DAO {
  'addGoal' : ActorMethod<[string], undefined>,
  'getGoals' : ActorMethod<[], Array<string>>,
  'getManifesto' : ActorMethod<[], string>,
  'getName' : ActorMethod<[], string>,
  'setManifesto' : ActorMethod<[string], undefined>,
}
export interface _SERVICE extends DAO {}
