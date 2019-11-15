# Import needed modules
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support import expected_conditions as EC # available since 2.26.0

import re

def get_good_accessions(url):
    # I had already installed phantomjs and it is in the PATH
    driver = webdriver.PhantomJS()
    driver.get(url)
    print("URL=" + url)
    accession_list = driver.find_elements_by_class_name('col_accession')
    projects = driver.find_elements_by_class_name('col_project')
    
    accessions_to_parse=[]
    ignore_projects =  ['new-generis','envirogenomarkers', 'ntc','predtox']
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
        # contents = driver.find_elements_by_class_name('col_contents')
        # titles and contents should have the exactly same number of elements
        # assert len(titles) == len(contents)
        description = ''
        tech_type = ''
        contents_dict = {}
        for i, t in enumerate(titles):
            title = t.text.lower()
            title1 = re.sub('\s*:$','',t.text) # This one we need for Xpath search
            retrieved_data = driver.find_elements_by_xpath('//div[@class="col_title" and contains(text(),"' + title1 + '")]/ancestor::td/following-sibling::td/div[@class="col_contents"]/*')
            if len(retrieved_data) == 0:
                # Then re-retrieve it, because it is not an array but just a text
                retrieved_data = driver.find_elements_by_xpath('//div[@class="col_title" and contains(text(),"' + title1 + '")]/ancestor::td/following-sibling::td/div[@class="col_contents"]')
                assert len(retrieved_data) == 1 # There should be only single entry
                contents_dict[title1] = retrieved_data[0].text
            else:
                contents_dict[title1] = [rd.text for rd in retrieved_data]
                contents_dict[title1] = ';'.join(contents_dict[title1])
            # The next if statement checks for description field
            if title.count('description') > 0:
                # Check in the description for descr_in and descr_out conditions
                descr = contents_dict[title1].lower()
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
                    # Also check for cases with "Ex vivo" or "Ex-vivo"
                    if len(re.findall('ex[\s-]*vivo',s, re.IGNORECASE)) < 1:
                        good_experiment = False
                    
            if title.count('technology') > 0 and title.count('type') > 0:
                tech_type = contents_dict[title1].lower()
                # Then this is "Technology Type:" row
                # The words in technology_types Must be present                    
                for tech in technology_types:
                    if contents_dict[title1].lower().count(tech.lower()) < 1:
                        good_experiment = False
        if good_experiment:
            # Then add this experiment's info to a dictionary
            # Remove unnesseray ' :' suffix from titles
            # experiments_info[id]={re.sub('\s*:$','',titles[k].text):contents[k].text for k in range(len(titles))}
            experiments_info[id] = contents_dict
        else:
            print("The following experiment has either a problem in description or technology type")
            print(id)
            print("description:=", descr)
            print("tech type:=", tech_type)
            # ignored_experiments[id] = {titles[k].text:contents[k].text for k in range(len(titles))}
            ignored_experiments[id] = contents_dict
    driver.close()
    print("In total {} out of {} are possibly good experiments".format(len(experiments_info.keys()), len(accession_ids)))
    return(experiments_info, ignored_experiments)


if __name__ == "__main__":
    url = 'http://wwwdev.ebi.ac.uk/fg/dixa/group/browse-table-studies.html?keywords=&sortby=relevance&sortorder=descending&page=1&pagesize=100'
    accessions2 = get_good_accessions(url)
    used_experiments, ignored_experiments = experiments_info(accession_ids=accessions2)
    
    # Just to test
    import json
    with open('../data/interim/used_experiments_all1.json','w') as out:
        json.dump(used_experiments,out)
    with open('../data/interim/ignored_experiments_all1.json','w') as out:
        json.dump(ignored_experiments,out)
