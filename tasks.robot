*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Robocorp.Vault
Library    RPA.Tables
Library    RPA.Archive


*** Variables ***
${robot_website}=    https://robotsparebinindustries.com/
${robot_order_page}=    ${robot_website}/#/robot-order
${order_csv}=    ${robot_website}/orders.csv
${SCREENSHOT_DIR}=    ${OUTPUT_DIR}${/}screenshots
${RECEIPT_DIR}=    ${OUTPUT_DIR}${/}receipts


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    3x    5 sec    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts


*** Keywords ***
Open the robot order website
    Open Available Browser    ${robot_order_page}

Get orders
    Download    ${order_csv}    overwrite=True
    ${table}=    Read table from CSV    orders.csv    header=True
    RETURN    ${table}

Close the annoying modal
    Click Button When Visible    css:.alert-buttons button

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:.form-control     ${row}[Legs]
    Input Text    address    ${row}[Address]


Preview the robot
    Click Button    Preview

Submit the order
    Click Button    Order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${saved_receipt_path}    Set Variable   ${RECEIPT_DIR}${/}order-${order_number}.pdf
    ${pdf_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${pdf_html}    ${saved_receipt_path}
    RETURN    ${saved_receipt_path}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${screenshot_path}    Set Variable    ${SCREENSHOT_DIR}${/}screenshot-${order_number}.png
    Screenshot    id:robot-preview-image    ${screenshot_path}
    RETURN    ${screenshot_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    ${receipt}=    Open Pdf    ${pdf}
    ${screenshot_file}=    Create List    ${pdf}    ${screenshot}
    Add Files To Pdf    ${screenshot_file}    ${pdf}
    Close Pdf    ${receipt}

Go to order another robot
    Click Element When Visible    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${RECEIPT_DIR}    ${OUTPUT_DIR}${/}receipts.zip