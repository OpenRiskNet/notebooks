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

