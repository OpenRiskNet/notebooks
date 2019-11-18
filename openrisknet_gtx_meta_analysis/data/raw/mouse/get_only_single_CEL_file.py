import sys

def load_to_dict(file_name, sep="\t"):
    '''
    This function assumes that a file with two columns are loaded. Tab-separated file.
    '''
    d1 = {}
    with open(file_name, 'rU') as inp:
        for line in inp:
            arr = line[:-1].split(sep)
            if arr[0] in d1:
                d1[arr[0]].append(arr[1])
            else:
                d1[arr[0]]=[arr[1]]
    return(d1)

def only_single_CEL_file(d1, preferred_study="gse72081"):
    '''
    This function filters multiple CEL files and returns only a single representative file.
    If it has a file from study gse72081 then that one will be selected automatically.
    '''
    d2 = {}
    for k in d1:
        preferred_cel_file = ""
        for cel_file in d1[k]:
            if cel_file.lower().count(preferred_study.lower())>0:
                preferred_cel_file = cel_file
        if preferred_cel_file == "":
            d2[k]=d1[k][0]
        else:
            d2[k] = preferred_cel_file
    return(d2)
    
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("#Usage:\n\tpython %s tab_delimited_2_column_file out_file" %(sys.argv[0]))
        sys.exit(1)
    file_name = sys.argv[1]
    out_file = sys.argv[2]
    d1 = load_to_dict(file_name)
    d2 = only_single_CEL_file(d1)
    with open(out_file, 'w') as out:
        for k in d2:
            out.write(k+"\t"+d2[k] + "\n")
