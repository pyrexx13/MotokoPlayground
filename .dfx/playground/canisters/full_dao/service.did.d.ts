import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export type CreateProposalErr = { 'NotDAOMember' : null } |
  { 'NotEnoughTokens' : null };
export type CreateProposalOk = bigint;
export type CreateProposalResult = { 'ok' : CreateProposalOk } |
  { 'err' : CreateProposalErr };
export interface DAO {
  'addGoal' : ActorMethod<[string], undefined>,
  'addMember' : ActorMethod<[Member], Result>,
  'balanceOf' : ActorMethod<[Account], bigint>,
  'createProposal' : ActorMethod<[string], CreateProposalResult>,
  'getAllMembers' : ActorMethod<[], Array<Member>>,
  'getAllProposals' : ActorMethod<[], Array<Proposal>>,
  'getGoals' : ActorMethod<[], Array<string>>,
  'getManifesto' : ActorMethod<[], string>,
  'getMember' : ActorMethod<[Principal], Result_1>,
  'getName' : ActorMethod<[], string>,
  'getProposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'mint' : ActorMethod<[Principal, bigint], undefined>,
  'numberOfMembers' : ActorMethod<[], bigint>,
  'removeMember' : ActorMethod<[], Result>,
  'setManifesto' : ActorMethod<[string], undefined>,
  'tokenName' : ActorMethod<[], string>,
  'tokenSymbol' : ActorMethod<[], string>,
  'totalSupply' : ActorMethod<[], bigint>,
  'transfer' : ActorMethod<[Account, Account, bigint], Result>,
  'updateMember' : ActorMethod<[Member], Result>,
  'vote' : ActorMethod<[bigint, boolean], voteResult>,
}
export interface Member { 'age' : bigint, 'name' : string }
export interface Proposal {
  'id' : bigint,
  'status' : Status,
  'votes' : bigint,
  'voters' : Array<Principal>,
  'manifest' : string,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : Member } |
  { 'err' : string };
export type Status = { 'Open' : null } |
  { 'Rejected' : null } |
  { 'Accepted' : null };
export type Subaccount = Uint8Array | number[];
export type VoteErr = { 'AlreadyVoted' : null } |
  { 'ProposalEnded' : null } |
  { 'ProposalNotFound' : null } |
  { 'NotDAOMember' : null } |
  { 'NotEnoughTokens' : null };
export type VoteOk = { 'ProposalOpen' : null } |
  { 'ProposalRefused' : null } |
  { 'ProposalAccepted' : null };
export type voteResult = { 'ok' : VoteOk } |
  { 'err' : VoteErr };
export interface _SERVICE extends DAO {}
