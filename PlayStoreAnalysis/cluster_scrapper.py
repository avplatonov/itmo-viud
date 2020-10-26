import requests
import app_scrapper
from bs4 import BeautifulSoup
from parsing_constants import clusterBaseString, clusterLinkClass

def get_app_ids(url, count = 999):

    clusterPage = requests.get(clusterBaseString + url)
    soup = BeautifulSoup(clusterPage.text, 'html.parser')
    return [el["href"].split("=")[1] for el in soup.find_all(class_ = clusterLinkClass)[:count]]

def get_app_names(url):
    count = 0
    max_count = 5
    queue = get_app_ids(url, 2)

    while len(queue) > 0:
        appid = queue[0]
        appData = app_scrapper.get_page_data(appid)
        print(appData['name'])
        count += 1
        print(queue)
        print(count)
        if count <= max_count:
            queue += get_app_ids(appData['related_cluster_url'], 2)
        queue.remove(appid)
        
        
get_app_names("/store/apps/collection/cluster?clp=ogomCBEqAggIMh4KGGNvbS5zdGFya29tZW50LkpETVJhY2luZxABGAM%3D:S:ANO1ljLmeKs&gsr=CimiCiYIESoCCAgyHgoYY29tLnN0YXJrb21lbnQuSkRNUmFjaW5nEAEYAw%3D%3D:S:ANO1ljIBSEU")

