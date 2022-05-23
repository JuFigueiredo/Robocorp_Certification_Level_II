*** Settings ***
Documentation       Template keyword resource.

Library    RPA.HTTP
Library    RPA.FileSystem
Library    RPA.Browser.Selenium
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library     RPA.Dialogs
Library    RPA.Robocorp.Vault

*** Variables ***
${folder_path}    ${CURDIR}${/}orders
${file_name}    orders.csv


*** Keywords ***
Open the robot order website
    ${secret}=    Get Secret    caminho
    Open Available Browser    url=${secret}[url]
    Wait Until Page Contains Element   locator=xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Button When Visible    locator=xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Input form dialog
    Add heading    Enter with orders' url
    Add text input    url    label=URL
    ${result}=    Run dialog
    Download    url=${result.url}    overwrite=True    target_file=${folder_path}

Get Orders
    Create Directory    path=${folder_path}   exist_ok=True
    Empty Directory    path=${folder_path}
    Input form dialog    
    ${file_path}=    Catenate    SEPARATOR=\\    ${folder_path}    ${file_name}
    @{orders}=    Read table from CSV    path=${file_path}
    Remove File    path=${file_path}
    [Return]    @{orders}

Fill the form
    [Arguments]    ${elem}
    Select From List By Index    id:head    ${elem}[Head]
    Select Radio Button    group_name=body    value=${elem}[Body]
    Input Text    locator=class:form-control    text=${elem}[Legs]
    Input Text    locator=id:address    text=${elem}[Address]

Click submit order
    Wait Until Page Contains Element   locator=id:order
    Click Button    locator=id:order
    Wait Until Page Contains Element   locator=id:receipt
Submit the order and save result
    [Arguments]    ${order_number}
    Wait Until Page Contains Element   locator=id:preview
    Click Button    locator=id:preview
    Wait Until Keyword Succeeds    3x    200ms    Click submit order
    ${order_result_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_result_html}    ${folder_path}${/}order_result_${order_number}.pdf
    Wait Until Page Contains Element   locator=id:robot-preview-image
    Screenshot    locator=id:robot-preview-image    filename=${folder_path}${/}robot_${order_number}.png
    ${files}=    Create List    ${folder_path}${/}robot_${order_number}.png
    Add Files To Pdf    append=True    files=${files}    target_document=${folder_path}${/}order_result_${order_number}.pdf
    Remove File    path=${folder_path}${/}robot_${order_number}.png
    Wait Until Page Contains Element   locator=id:order-another
    Click Button    locator=id:order-another
    
    Wait Until Page Contains Element   locator=xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Button When Visible    locator=xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Zip orders folder
    Archive Folder With Zip    folder=${folder_path}    archive_name=${OUTPUT_DIR}${/}orders.zip
    Remove Directory    path=${folder_path}    recursive=True