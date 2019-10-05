import itertools


def assignBasicMassProb(state, probability, PPV, NPV):
    # returns {m_P, m_N, m_PN}
    if state == 'P':
        return {
            'P': probability * PPV, 
            'N': (1. - probability) * PPV, 
            'PN': (1. - PPV)}
    elif state == 'N':
        return {
            'P': (1. - probability) * NPV, 
            'N': probability * NPV, 
            'PN': (1. - NPV)}


# Function that calculates ground mass probabilities from N basic mass probabilities, which are given in the input as a list of dictionaries `m`. 
# Output is dictionary `q` with ground mass probability for 4 different states ('P', 'N', 'PN', '0').

def assignGroundMassProb_N(m):
    q = {}
    n_sources = len(m)
    
    q['PN'] = 1
    for i in range(n_sources):
        q['PN'] = q['PN'] * m[i]['PN']
    
    
    q['P'] = 0.
    qList = list(itertools.product(['P', 'PN'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['P'] = q['P'] + subq

    q['P'] = q['P'] - q['PN']
            
        
    q['N'] = 0.
    qList = list(itertools.product(['N', 'PN'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['N'] = q['N'] + subq

    q['N'] = q['N'] - q['PN']        
        
    
    q['0'] = 0.
    qList = list(itertools.product(['N', 'PN', 'P'], repeat=n_sources))
    for keys in qList:
        listKeys = list(keys)

        subq = 1.
        for i in range(n_sources):
            subq = subq * m[i][listKeys[i]]

        q['0'] = q['0'] + subq

    q['0'] = q['0'] - q['PN'] - q['P'] - q['N']

    return q


### Combine ground mass probabilities into probability masses
# **Using either:**
# **1. Yager's rule** which increases uncertainty in case of conflicting evidence
# **2. Dempster's rule** which ignores conflicts and tends to decrease uncertainty
def YagerCombinationRule(q):
    # returns mY(P), mY(N), mY(PN)
    return {
        'P': q['P'], 
        'N': q['N'], 
        'PN': q['PN']+q['0']}


def DempsterCombinationRule(q):
    # returns mD(P), mD(N), mD(PN)
    return {
        'P': q['P']/(1. - q['0']),
        'N': q['N']/(1. - q['0']),
        'PN': q['PN']/(1. - q['0']),
    }


### Make a prediction for a binary target variable based on the probability masses
def predict(m):   
    belief = {
        'P': m['P'],
        'N': m['N'],
        'PN': m['P'] + m['N'] + m['PN']
    }
    
    plausability = {
        'P': m['P'] + m['PN'],
        'N': m['N'] + m['PN'],
        'PN': m['P'] + m['N'] + m['PN']
    }
    
    if belief['P'] > 0.5:
        prediction = 'P'
    elif belief['N'] > 0.5:
        prediction = 'N'
    else:
        prediction = 'equivocal'
    
#     print('Prediction:', prediction, '\n')
#     print('Probability intervals')
#     print('Belief/Plausability of state P:', belief['P'], plausability['P'])
#     print('Belief/Plausability of state N:', belief['N'], plausability['N'], '\n\n')
    return belief, plausability, prediction


### Make a prediction starting from the dictionaries of probability, PPV, NPV values per every model
def predict_Yager(models_pred, models_prob, models_ppv, models_npv):
    
    # list of basic mass probabilities
    ms = []
    
    # loop over models and collect basic mass probabilities
    for model in list(models_prob.keys()):
        
        # collect basic info for particular model
        state = models_pred[model]
        probability = models_prob[model]
        ppv = models_ppv[model]
        npv = models_npv[model]
        
        ms.append(assignBasicMassProb(state, probability, ppv, npv))

    # compute ground mass probability
    qs = assignGroundMassProb_N(ms)
    
    # collect belief, plausability, prediction
    return predict(YagerCombinationRule(qs))
        
    
def predict_Dempster(models_pred, models_prob, models_ppv, models_npv):
    
    # list of basic mass probabilities
    ms = []
    
    # loop over models and collect basic mass probabilities
    for model in list(models_prob.keys()):
        
        # collect basic info for particular model
        state = models_pred[model]
        probability = models_prob[model]
        ppv = models_ppv[model]
        npv = models_npv[model]
        
        ms.append(assignBasicMassProb(state, probability, ppv, npv))

    # compute ground mass probability
    qs = assignGroundMassProb_N(ms)
    
    # collect belief, plausability, prediction
    return predict(DempsterCombinationRule(qs))