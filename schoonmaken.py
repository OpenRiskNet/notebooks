# from pip._internal import main as pip
# import importlib
# import pip
#
# print(help(importlib))
#
# # import requests, pandas
#
# moduleNames = ["requests", "pandas"]

# __import__("requests")
#
# print(help(__import__))


#
# importlib.import_module(moduleNames)
# # modules = map(__import__, moduleNames)
#
# print("hallo")

# print(help(modules))



# print(help(requests))
#


# seaborn as sns
modules = ["requests",("seaborn",("as", ("sns"))), ("IPython.display",("from",["display", "SVG", "HTML"]))]


def clean_import(module):
    print(module)
    print(type(module))
    if type(module) == str:
        __import__(module)
    else:
        if module[1][0] == "as": __import__(module[0]) as module[1][1]

        print("aaaaaaaaaaaaaa ")
        print(module)
        print(module[0])
        print(module[1])
        print(module[1][0])

    # __import__()


[clean_import(x) for x in modules]






















#
#
# try:
#     import requests
# except ImportError:
#     pip(['install', 'request'])
#     import requests





#
# try:
#     from IPython.display import display, SVG, HTML
# except ImportError:
#     pip(['install', 'IPython'])
#     from IPython.display import display, SVG, HTML
#
# try:
#     import pandas
# except ImportError:
#     pip(['install', 'pandas'])
#     import pandas
#
# try:
#     import urllib
# except ImportError:
#     pip(['install', 'urllib'])
#     import urllib
#
# try:
#     import seaborn as sns
# except ImportError:
#     pip(['install', 'seaborn'])
#     import seaborn as sns
# try:
#     import matplotlib.pyplot as plt
# except ImportError:
#     pip(['install', 'matplotlib'])
#     import matplotlib.pyplot as plt
#
# try:
#     from SPARQLWrapper import SPARQLWrapper, JSON
# except ImportError:
#     pip(['install', 'sparqlwrapper'])
#     from SPARQLWrapper import SPARQLWrapper, JSON
#
# try:
#     from rdflib import Graph
# except ImportError:
#     pip(['install', 'rdflib'])
#     from rdflib import Graph