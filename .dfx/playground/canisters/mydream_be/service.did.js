export const idlFactory = ({ IDL }) => {
  const DAO = IDL.Service({
    'addGoal' : IDL.Func([IDL.Text], [], []),
    'getGoals' : IDL.Func([], [IDL.Vec(IDL.Text)], ['query']),
    'getManifesto' : IDL.Func([], [IDL.Text], ['query']),
    'getName' : IDL.Func([], [IDL.Text], ['query']),
    'setManifesto' : IDL.Func([IDL.Text], [], []),
  });
  return DAO;
};
export const init = ({ IDL }) => { return []; };
