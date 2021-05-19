*** Settings ***
Documentation   Orders placing robot.
...             Downloads input file provided by user if empty use default link.
...             Navigates by default link from secrets.
...             For each order from input file places order and saves order info:
...             1. Order info HTML as PDF.
...             2. Screenshot of the robot.
...             Creates ZIP archive with placed orders info.
Library         RPA.Browser.Selenium
Library         RPA.HTTP
Library         RPA.Tables
Library         RPA.Desktop
Library         RPA.PDF
Library         RPA.Archive
Library         RPA.Dialogs
Library         RPA.Robocloud.Secrets

*** Keywords ***
Download input file
    [Arguments]    ${download_link}
    IF    ${download_link} == ''
        ${secrets}=    Get Secret    placing_orders_info
        Download    ${secrets}[download_link]    overwrite=True
    ELSE
        Download    ${download_link}    overwrite=True
    END
    ${input_table}=    Read Table From Csv    orders.csv
    [Return]    ${input_table}

*** Keywords ***
# Get links
#     #get secrets
#     ${secrets}=    Get Secret    placing_orders_info
#     #get download link
#     Log   ${secrets}[download_link]
#     #get orders placing link
#     ${orders_placing_link}=   Get Secret    orders_placing_link


*** Tasks ***
Minimal task
    ${download_link}=    Download input file
    #Log   ${download_link}
    #Log   ${orders_placing_link}

