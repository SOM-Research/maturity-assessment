__author__ = 'valerio cosentino'

import os
import time
from selenium import webdriver
import util
import json
import ConfigParser

WAIT_TIME = 3
WEB_DRIVER_PATH = os.path.dirname(util.__file__) + "\selenium_driver\phantomjs.exe"
URL = "https://git.eclipse.org/c/"

CONFIG_PATH = "./params.config"
configParser = ConfigParser.RawConfigParser()
configParser.read(CONFIG_PATH)


def init_browser():
    driver = webdriver.PhantomJS()
    driver.maximize_window()
    return driver


def visit_page(driver, url):
    driver.get(url)
    time.sleep(WAIT_TIME)


def get_git_url(repo_name, url, driver):
    found = None
    visit_page(driver, url)

    candidates = [td.text for td in driver.find_elements_by_tag_name("td") if "git clone" in td.text]
    if not candidates:
        candidates = [tr for tr in driver.find_elements_by_tag_name("tr") if "git clone" in tr.text]

    if candidates:
        for c in candidates:
            link = c.split("git clone")[-1].strip()
            found = link
            break

        if not found:
            print repo_name + ": no git links candidates"
    else:
        candidates = [td.text for td in driver.find_elements_by_tag_name("td") if td.text.startswith("git://")]

        if candidates:
            found = candidates[0].strip()
        else:
            print repo_name + ": git links not found"

    if not found:
        found = "not-found"
    return found


def get_info_projects(driver, output):
    repos = {}
    found = driver.find_elements_by_tag_name("table")[-1]
    if found:
        another_driver = init_browser()
        tds = found.find_elements_by_tag_name("td")
        for td in tds:
            if td.get_attribute("class") == "reposection":
                if repos:
                    save({project_name: repos}, output)
                    repos.clear()
                project_name = td.text
            elif td.get_attribute("class") == "sublevel-repo":
                repo_name = td.text
                repo_url = td.find_element_by_tag_name("a").get_attribute("href")
                git_url = get_git_url(repo_name, repo_url, another_driver)
                repos.update({repo_name: {"url": repo_url, "git": git_url}})

        another_driver.close()
        save({project_name: repos}, output)


def init(output_file):
    try:
        os.remove(output_file)
    except OSError:
        pass


def open_file(f):
    return open(f, "a")


def close_file(f):
    f.close()


def save(data, output):
    json.dump(data, output)
    output.write("\n")


def main():
    output_file = configParser.get('params', 'file')
    init(output_file)
    driver = init_browser()
    visit_page(driver, URL)
    output = open_file(output_file)
    get_info_projects(driver, output)
    close_file(output)
    driver.close()


if __name__ == "__main__":
    main()