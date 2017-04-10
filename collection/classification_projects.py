__author__ = 'valerio cosentino'

from selenium import webdriver
import time
import sys
import re

PROJECTS = [
'4diac',
'acceleo',
'actf',
'agail',
'ajdt',
'amalgam',
'app4mc',
'aspectj',
'b3',
'babel',
'bpel',
'bpmn2',
'bpmn2-modeler',
'buckminster',
'capra',
'cbi',
'cdo',
'cdt',
'chemclipse',
'dali',
'dash',
'diffmerge',
'dltk',
'e4',
'ease',
'eatop',
'eavp',
'ecf',
'eclemma',
'eclipselink',
'eclipsescada',
'ecoretools',
'edapt',
'edje',
'eef',
'efm',
'efxclipse',
'egerrit',
'egf',
'egit',
'emf',
'emf-parsley',
'emf-query',
'emf-store',
'emf-transaction',
'emf-validation',
'emfatic',
'emfclient',
'emfcompare',
'epf',
'epsilon',
'equinox',
'etrice',
'facet',
'gemini',
'gendoc',
'geoperil',
'gmf-notation',
'gmf-tooling',
'graphiti',
'handly',
'henshin',
'hono',
'hudson',
'ignite',
'intent',
'iofog',
'january',
'jdt',
'jdtls',
'jeetools',
'jetty',
'jgit',
'jsdt',
'jsf',
'jubula',
'jwt',
'kapua',
'krikkit',
'ldt',
'libra',
'linuxtools',
'lsp4e',
'lsp4j',
'lyo',
'm2e',
'm2e-wtp',
'm2t',
'mat',
'mdht',
'mdmbl',
'mdmweb',
'milo',
'mmt',
'modisco',
'mosquitto',
'mpc',
'mtj',
'mylyn',
'nattable',
'nebula',
'objectteams',
'ocl',
'ogee',
'om2m',
'omr',
'oomph',
'openk-platform',
'orbit',
'orion',
'osbp',
'osee',
'papyrus',
'pde',
'pdt',
'planeteclipse.org',
'platform',
'pmf',
'ptp',
'rap',
'rcptt',
'recommenders',
'recommenders.incubator',
'riena',
'rmf',
'rtsc',
'sandbox',
'sapphire',
'scanning',
'scout',
'servertools',
'simopenpass',
'simrel',
'sirius',
'sisu',
'skalli',
'sphinx',
'stardust',
'statet',
'stem',
'sw360',
'swtbot',
'tcf',
'texo',
'tigerstripe',
'tinydtls',
'titan',
'tm',
'tracecompass',
'tycho',
'uml2',
'umlgen',
'unide',
'uomo',
'usssdk',
'viatra',
'virgo',
'webservices',
'websites',
'webtools-common',
'windowbuilder',
'winery',
'xsd',
'xwt',
'yasson'
]

driver = webdriver.Chrome(executable_path='./chromedriver.exe')
URL = 'http://projects.eclipse.org/search/projects?f[0]=im_field_project_techology_types%3A27'


def access():
    driver.get(URL)
    driver.maximize_window()

    time.sleep(5)


def stop():
    driver.close()
    sys.exit()


def next_page():
    found = True

    try:
        li = driver.find_element_by_class_name("next")

        if li:
            href = li.find_element_by_tag_name("a").get_attribute("href")
            driver.get(href)

        time.sleep(5)
    except:
        found = False

    return found


def find_candidates(project_name, url):
    candidates = []

    for p in PROJECTS:
        if p in project_name.lower() or p in url.lower():
            candidates.append(p)

    return candidates


def get_data():
    next = True

    while next:
        rows = driver.find_elements_by_tag_name("tr")

        for r in rows:
            tds = r.find_elements_by_tag_name("td")
            try:
                project_name = tds[0].text
                tag_a = tds[1].find_element_by_tag_name("a")
                href = tag_a.get_attribute("href")

                if project_name and href:
                    print project_name + " - " + href + " - candidates: " + ','.join(find_candidates(project_name, href))

            except:
                continue

        next = next_page()


def main():
    access()

    get_data()

    stop()

if __name__ == '__main__':
    main()
