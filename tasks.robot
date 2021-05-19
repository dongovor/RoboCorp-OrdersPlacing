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
Library         RPA.PDF
Library         RPA.Archive
Library         RPA.Dialogs
Library         RPA.Robocloud.Secrets
Library         RPA.FileSystem

*** Keywords ***
Try to get input from business user
    #get input from user or use default value if "None"
    Create Form   Please provide link to the orders file or press submit to use default link 
    Add Text Input    Download Link    download_link
    &{user_input}=   Request Response
    IF    '${user_input["download_link"]}' == 'None'
        Log   None as user input.
        ${secrets}=    Get Secret    placing_orders_info
        FOR    ${key}    IN    @{secrets}
            Log  ${key}
        END       
        Log  ${key}
        Download    ${secrets}[default_download_link]    overwrite=True
    ELSE
        Log   Downloading file ${user_input["download_link"]}
        Download    ${user_input["download_link"]}    overwrite=True
    END  

*** Keywords ***
Read input file
    #read downloaded input file
    ${input_table}=    Read Table From Csv    orders.csv
    [Return]    ${input_table}

*** Keywords ***
Open ordering website
    #get orders placing link and navigate
    ${secrets}=    Get Secret    placing_orders_info
    Open Available Browser    ${secrets}[orders_placing_url]

*** Keywords ***
Close popup
    #Click Ok when popup appear
    Click Element When Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

*** Keywords ***
Choose Head
    #click element in drop-down using value from Head cell + 1, because 1st drop-down element not body part
    [Arguments]    ${input_order}
    Click Element    //*[@id="head"]/option[${input_order}[Head] + 1]

*** Keywords ***
Choose Body
    #click body part radio btn by xpath
    [Arguments]    ${input_order}
    Click Element    //*[@id="id-body-${input_order}[Body]"]    

*** Keywords ***
Choose Legs
    #enter legs model number by xpath
    [Arguments]    ${input_order}
    Input Text    xpath://input[@placeholder="Enter the part number for the legs"]     ${input_order}[Legs]    

*** Keywords ***
Type address
    #type address by xpath
    [Arguments]    ${input_order}
    Input Text    xpath://*[@id="address"]    ${input_order}[Address]

*** Keywords ***
Click Preview
    #click Preview btn
    Click Button    //*[@id="preview"]

*** Keywords ***
Click Order
    #click Order btn
    Click Button    //*[@id="order"]
    Wait Until Element Is Visible    //*[@id="receipt"]/h3

*** Keywords ***
Save as PDF
    [Arguments]    ${input_order}
    ${order_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${order_html}    ${CURDIR}${/}output${/}receipts${/}robor_order_${input_order}[Order number].pdf
    [Return]    ${CURDIR}${/}output${/}receipts${/}robor_order_${input_order}[Order number].pdf

*** Keywords ***
Take Robot screenshot
    #wait until robot picture fully loaded and take screenshot
    [Arguments]    ${input_order}
    #wait until head loaded
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]/img[1]
    #wait until body loaded
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]/img[2]
    #wait until legs loaded
    Wait Until Element Is Visible    //*[@id="robot-preview-image"]/img[3]
    Capture Element Screenshot    //*[@id="robot-preview-image"]    ${CURDIR}${/}output${/}receipts${/}${input_order}[Order number].png
    [Return]    ${CURDIR}${/}output${/}receipts${/}${input_order}[Order number].png

*** Keywords ***
Add screenshot to the pdf
    #add robot screenshot to the pdf as watermark
    [Arguments]    ${path_to_pdf}    ${path_to_robot_picture}
    Open Pdf    ${path_to_pdf}
    Add Watermark Image To Pdf    ${path_to_robot_picture}    ${path_to_pdf}
    Close Pdf    ${path_to_pdf}

*** Keywords ***
Click Order Another Robot
    #click order another robot btn
    Click Button    //*[@id="order-another"]

*** Keywords ***
Compress orders
    #create archive with orders pdf's
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    ${CURDIR}${/}output${/}orders.zip

*** Tasks ***
Minimal task
    Try to get input from business user
    ${input_orders}=    Read input file
    Open ordering website
    FOR    ${input_order}    IN    @{input_orders}
        Log    "Order info "${input_order}
        Log    ${input_order}/[Head]
        Close popup
        Choose Head    ${input_order}
        Choose Body    ${input_order}
        Choose Legs    ${input_order}
        Type address    ${input_order}
        Click Preview
        Wait Until Keyword Succeeds    15x    1 sec    Click Order
        ${create_pdf_w_order_info}=   Save as PDF    ${input_order}
        ${take_robot_screenshot}=   Take Robot screenshot    ${input_order}
        Add screenshot to the pdf    ${create_pdf_w_order_info}    ${take_robot_screenshot}
        Remove File    ${take_robot_screenshot}    missing_ok=True
        Click Order Another Robot
    END
    Close Browser
    Compress orders
    Log   Done








