import itertools


def assignBasicMassProb(state, probability, PPV, NPV):
    # returns {m_S, m_N, m_SN}
    if state == 'S':
        return {
            'S': probability * PPV, 
            'N': (1. - probability) * PPV, 
            'SN': (1. - PPV)}
    elif state == 'N':
        return {
            'S': (1. - probability) * NPV, 
            'N': probability * NPV, 
            'SN': (1. - NPV)}


# Function that calculates ground mass probabilities from N basic mass probabilities, which are given in the input as a list of dictionaries `m`. 
# Output is dictionary `q` with ground mass probability for 4 different states ('S', 'N', 'SN', '0').

def assignGroundMassProb_N(m):
    q = {}
    n_sources = len(m)
    
    q['SN'] = 1
    for i in range(n_sources):
        q['SN'] = q['SN'] * m[i]['SN']
    
    
    q['S'] = 0.
    qList = list(itertools.product(['S', 'SN'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['S'] = q['S'] + subq

    q['S'] = q['S'] - q['SN']
            
        
    q['N'] = 0.
    qList = list(itertools.product(['N', 'SN'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['N'] = q['N'] + subq

    q['N'] = q['N'] - q['SN']        
        
    
    q['0'] = 0.
    qList = list(itertools.product(['N', 'SN', 'S'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['0'] = q['0'] + subq

    q['0'] = q['0'] - q['SN'] - q['S'] - q['N']

    return q


### Combine ground mass probabilities into probability masses
# **Using either:**
# **1. Yager's rule** which increases uncertainty in case of conflicting evidence
# **2. Dempster's rule** which ignores conflicts and tends to decrease uncertainty
def YagerCombinationRule(q):
    # returns mY(S), mY(N), mY(SN)
    return {
        'S': q['S'], 
        'N': q['N'], 
        'SN': q['SN']+q['0']}


def DempsterCombinationRule(q):
    # returns mD(S), mD(N), mD(SN)
    return {
        'S': q['S']/(1. - q['0']),
        'N': q['N']/(1. - q['0']),
        'SN': q['SN']/(1. - q['0']),
    }


### Make a prediction for a binary target variable based on the probability masses
def predict(m):   
    belief = {
        'S': m['S'],
        'N': m['N'],
        'SN': m['S'] + m['N'] + m['SN']
    }
    
    plausability = {
        'S': m['S'] + m['SN'],
        'N': m['N'] + m['SN'],
        'SN': m['S'] + m['N'] + m['SN']
    }
    
    if belief['S'] > 0.5:
        prediction = 'S'
    elif belief['N'] > 0.5:
        prediction = 'N'
    else:
        prediction = 'equivocal'
    
#     print('Prediction:', prediction, '\n')
#     print('Probability intervals')
#     print('Belief/Plausability of state S:', belief['S'], plausability['S'])
#     print('Belief/Plausability of state N:', belief['N'], plausability['N'], '\n\n')
    return belief, plausability, prediction