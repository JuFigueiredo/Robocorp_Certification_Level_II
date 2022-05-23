*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library           Collections
Library           MyLibrary
Resource          keywords.robot
Variables         MyVariables.py

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    [Teardown]    Close all dialogs
    @{orders}=    Get Orders
    Open the robot order website
    FOR    ${element}    IN    @{orders}
        Fill the form    ${element}
        Submit the order and save result    ${element}[Order number]
    END
    Zip orders folder


