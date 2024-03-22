--
homigrad = homigrad or {}

homigrad.GetActiveRound = function() -- return Cur. ActiveRound 
    return homigrad.roundInfo.Mode or "homicide"
end