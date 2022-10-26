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


*** Variables ***
${robot_website}=    https://robotsparebinindustries.com/
${robot_order_page}=    ${robot_website}/#/robot-order
${order_csv}=    ${robot_website}/orders.csv


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #    Go to order another robot
    END
    # Create a ZIP file of the receipts


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
