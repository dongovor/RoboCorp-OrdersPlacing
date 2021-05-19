*** Settings ***
Documentation   Template robot main suite.
...             
Library         RPA.Browser.Selenium
Library         RPA.HTTP
Library         RPA.Tables
Library         RPA.Desktop
Library         RPA.PDF
Library         RPA.Archive
Library         RPA.Dialogs
Library         RPA.Robocloud.Secrets

*** Keywords ***
Get links
    #get download link
    ${download_link}=   Get Secret    download_link
    #get orders placing link
    ${orders_placing_link}=   Get Secret    orders_placing_link


*** Tasks ***
Minimal task
    Get links
    Log   ${download_link}
    Log   ${orders_placing_link}
