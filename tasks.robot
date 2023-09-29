*** Settings ***
Documentation       Efetua pedidos de robôs da página RobotSpareBin Industries Inc.
...                 Salva a receita HTML dos pedidos como um arquivo PDF.
...                 Salva uma screenshot do robo pedido.
...                 Adiciona a screenshot do robo ao arquivo PDF.
...                 Cria um arquivo ZIP das receitas e imagens.

Library    RPA.Browser.Selenium
Library    RPA.Excel.Files
Library    RPA.Tables
Library    Collections
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive

Resource    locators/locators.robot

*** Variables ***
${DOWNLOAD_PATH}    ${CURDIR}${/}download
${EXCEL_FILE}    https://robotsparebinindustries.com/orders.csv

*** Tasks ***
Pede robôs da RobotSpareBin Industries Inc
    Abre a página de pedido dos robôs
    ${pedidos}=    Get pedidos

    FOR    ${pedido}    IN    @{pedidos}
        Reload Page
        Sleep    1.5s
        Fecha a modal chata
        Preencha o formulario    ${pedido}
        Pré-visualizar o robô
        Sleep    1.5s
        Pedir robô
        Sleep    1s
        ${pdf}=    Salvar a receita do robô como PDF    ${pedido}[Order number]
        ${screenshot}=    Tirar screenshot do robô    ${pedido}[Order number]
        Incorporar o screenshot do robô ao PDF    ${pedido}    ${screenshot}
        Criar pacote ZIP dos arquivos PDFs
        Sleep    2s
        Pedir outro robô
    END

    [Teardown]    Fechar o browser

*** Keywords ***
Abre a página de pedido dos robôs
    Open Browser    https://robotsparebinindustries.com/#/robot-order    browser=chrome    #options=add_argument("--headless")


Get pedidos
    Download    ${EXCEL_FILE}    ${DOWNLOAD_PATH}

    ${pedidos}=    Read table from CSV     ${DOWNLOAD_PATH}${/}orders.csv
    Log    ${pedidos}
    [Return]    ${pedidos}


Fecha a modal chata
    Wait Until Element Is Visible    ${btnOK}
    Click Element    ${btnOK}

    
Preencha o formulario
    [Arguments]    ${pedido}

    #Cabeça
    Wait Until Element Is Visible   ${selectHead}
    Select From List By Value    ${selectHead}    ${pedido}[Head]
    
    #Corpo
    Select Radio Button    body    ${pedido}[Body]

    #Pernas
    Input Text    ${inputLegs}    ${pedido}[Legs]

    #Endereço
    Input Text    ${inputAddress}    ${pedido}[Address]


Pré-visualizar o robô
    Wait Until Element Is Visible    ${btnPreview}
    Click Element    ${btnPreview}

Pedir robô
    Wait Until Element Is Visible    ${btnOrder}
    Click Element    ${btnOrder}


Tirar screenshot do robô
    [Arguments]    ${pedido}
    Wait Until Element Is Visible    ${robotPreview}
    ${screenshot}=    Screenshot    ${robotPreview}    ${DOWNLOAD_PATH}${/}${pedido}.png
    [Return]    ${screenshot}

Salvar a receita do robô como PDF
    [Arguments]    ${pedido}
    ${robot_recipe_html}=    Get Element Attribute    ${robotRecipe}    outerHTML
    ${saved_recipe_pdf}=    Html To Pdf    ${robot_recipe_html}    ${OUTPUT_DIR}${/}recipes${/}robot_recipe${pedido}.pdf
    [Return]    ${saved_recipe_pdf}

Incorporar o screenshot do robô ao PDF
    [Arguments]    ${pedido}    ${screenshot}
    ${pdf}=    Open Pdf    ${OUTPUT_DIR}${/}recipes${/}robot_recipe${pedido}[Order number].pdf
    Add Watermark Image To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}recipes${/}robot_recipe${pedido}[Order number].pdf

Criar pacote ZIP dos arquivos PDFs
    ${nome_arquivo_zip}=    Set Variable    ${OUTPUT_DIR}${/}robot_recipes.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}recipes    ${nome_arquivo_zip}

Pedir outro robô
    Wait Until Element Is Visible    ${btnOrderAnother}
    Click Element    ${btnOrderAnother}

Fechar o browser
    Close Browser