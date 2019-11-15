from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0


def get_good_accessions(url):
    # I had already installed phantomjs and it is in the PATH
    driver = webdriver.PhantomJS()
    driver.get(url)

    accession_list = driver.find_elements_by_class_name('col_accession')
    projects = driver.find_elements_by_class_name('col_project')
    
    accessions_to_parse=[]
    ignore_projects =  ['new-generis','envirogenomarkers']
    for i,proj in enumerate(projects):
        if not proj.text.lower() in ignore_projects:
            accessions_to_parse.append(accession_list[i].text)

    driver.close()
    return(accessions_to_parse)


def experiments_info(accession_ids, url_prefix='http://wwwdev.ebi.ac.uk/fg/dixa/group/', url_suffix='?keywords', technology_types=['array'], descr_in=['vitro'], descr_out=['vivo']):
    '''
    This function retrieves information about possibly further used and ignored experiment info.
    @param descr_in: words that should      be in the desription of the experiment
    @param descr_out: words that should NOT be in the desription of the experiment
    '''
    driver = webdriver.PhantomJS()
    # The next dict is of the form: {'acc_id':{'title1':'content1',...,'titleN':'contentN'}}
    experiments_info = {}
    ignored_experiments = {}
    for id in accession_ids:
        good_experiment = True
        url = url_prefix + id + url_suffix
        driver.get(url)
        titles = driver.find_elements_by_class_name('col_title')
        contents = driver.find_elements_by_class_name('col_contents')
        # titles and contents should have the exactly same number of elements
        assert len(titles) == len(contents)
        description = ''
        tech_type = ''
        for i, t in enumerate(titles):
            title = t.text.lower()
            # The next if statement checks for description field
            if title.count('description') > 0:
                # Check in the description for descr_in and descr_out conditions
                descr = contents[i].text.lower()
                description = descr
                # The words in descr_in should be present
                # BUT we do NOT check for this for now, because description is very sloppily written
                # for d in descr_in:
                #    if descr.count(d.lower()) < 1:
                #        good_experiment = False
                # The words in descr_out should NOT be present
                # SO, we only check if unwanted term is present or not
                # Apparently this is also not a good check, so I comment this one as well for now
                # for d in descr_out:
                #    if descr.count(d.lower()) > 0:
                #        good_experiment = False
                if descr.count('vivo')>0 and descr.count('vitro')<1:
                    # Then this is an in-vivo experiment, so discard it
                    good_experiment = False
                    
            if title.count('technology') > 0 and title.count('type') > 0:
                tech_type = contents[i].text.lower()
                # Then this is "Technology Type:" row
                # The words in technology_types Must be present                    
                for tech in technology_types:
                    if contents[i].text.lower().count(tech.lower()) < 1:
                        good_experiment = False
        if good_experiment:
            # Then add this experiment's info to a dictionary
            experiments_info[id]={titles[k].text:contents[k].text for k in range(len(titles))}
        else:
            print("The following experiment has either a problem in description or technology type")
            print(id)
            print("description:=", descr)
            print("tech type:=", tech_type)
            ignored_experiments[id] = {titles[k].text:contents[k].text for k in range(len(titles))}
    driver.close()
    print("In total {} out of {} are possibly good experiments".format(len(experiments_info.keys()), len(accession_ids)))
    return(experiments_info, ignored_experiments)



if __name__ == "__main__":
#    # Web URL to retrieve
#    url = 'http://wwwdev.ebi.ac.uk/fg/dixa/browsestudies.html'
#    accessions1 = get_good_accessions(url)
#    print("Total accessions for url {}: {}".format(url,len(accessions1)))
    
    # Web URL to retrieve
    url = 'http://wwwdev.ebi.ac.uk/fg/dixa/group/browse-table-studies.html?keywords=&sortby=relevance&sortorder=descending&page=1&pagesize=10'
    accessions2 = get_good_accessions(url)
    print("Total accessions for url {}: {}".format(url,len(accessions2)))
    used_experiments, ignored_experiments = experiments_info(accession_ids=accessions2)

    # Just to test
    import json
    with open('/tmp/used_experiments.json','w') as out:
        json.dump(used_experiments,out)
    with open('/tmp/ignored_experiments.json','w') as out:
        json.dump(ignored_experiments,out)
    
#    if accessions2 == accessions1:
#        print("Both accession ids list are     the same")
#    else:
#        print("Both accession ids list are NOT the same")
#        for i, a in enumerate(accessions1):
#            if accessions1[i].text!= accessions2[i].text:
#                print(accessions1[i].text, accessions2[i].text)
#
