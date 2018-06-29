*** Settings ***
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   prom_service.py


*** Variables ***
${sign_in}                                                         css=.qa_entrance_btn
${login_sign_in}                                                   name=email
${password_sign_in}                                                name=password


*** Keywords ***
Підготувати клієнт для користувача
    [Arguments]     ${username}
    [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
    Set Suite Variable  ${my_alias}  my_custom_alias
    Open Browser  ${USERS.users['${username}'].homepage}  ${USERS.users['${username}'].browser}  alias=my_custom_alias
    Set Window Size       @{USERS.users['${username}'].size}
    Set Window Position   @{USERS.users['${username}'].position}
    Run Keyword If   '${username}' != 'Prom_provider1'   Login   ${username}

Підготувати дані для оголошення тендера
    [Arguments]  ${username}   ${tender_data}    ${role_name}
    ${tender_data}=     Run keyword if    '${role_name}' == 'viewer'
    ...    adapt_assetholder_viewer   ${tender_data}
    ...  ELSE IF  '${role_name}' == 'tender_owner'    adapt_assetholder_owner     ${tender_data}
    [Return]  ${tender_data}

Підготувати дані для оголошення тендера користувачем
    [Arguments]   ${username}    ${tender_data}    ${role_name}
    [Documentation]  Відключити створення тендеру в тестовому режимі
    ${tender_data}=     Run keyword if    '${role_name}' == 'viewer' or '${role_name}' == 'tender_owner' or '${role_name}' == 'provider' or '${role_name}' == 'provider1'
    ...       adapt_test_mode   ${tender_data}
    [Return]      ${tender_data}


Login
    [Arguments]  @{ARGUMENTS}
    Click Element   ${sign_in}
    Sleep   1
    Clear Element Text   name=email
    Input Text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
    Input Text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Button    id=submit_button
    Sleep   2


Створити об'єкт МП
    [Arguments]   ${username}    ${tender_data}
    ${title}=                   Get From Dictionary         ${tender_data.data}                     title
    ${description}=             Get From Dictionary         ${tender_data.data}                     description
    ${decisions_title}=         Get From Dictionary         ${tender_data.data.decisions[0]}        title
    ${decisions_date}=          Get From Dictionary         ${tender_data.data.decisions[0]}        decisionDate
    ${decisions_date}=          convert_iso_date_to_prom    ${decisions_date}
    ${decisions_id}=            Get From Dictionary         ${tender_data.data.decisions[0]}        decisionID
    ${holder_countryName}       Get From Dictionary         ${tender_data.data.assetHolder.address}     countryName
    ${holder_locality}          Get From Dictionary         ${tender_data.data.assetHolder.address}     locality
    ${holder_postalCode}        Get From Dictionary         ${tender_data.data.assetHolder.address}     postalCode
    ${holder_region}            Get From Dictionary         ${tender_data.data.assetHolder.address}     region
    ${holder_streetAddress}     Get From Dictionary         ${tender_data.data.assetHolder.address}     streetAddress
    ${holder_email}             Get From Dictionary         ${tender_data.data.assetHolder.contactPoint}     email
    ${holder_telephone}         Get From Dictionary         ${tender_data.data.assetHolder.contactPoint}     telephone
    ${holder_name}              Get From Dictionary         ${tender_data.data.assetHolder}     name
    ${holder_id}                Get From Dictionary         ${tender_data.data.assetHolder.identifier}     id
    ${holder_legalName}         Get From Dictionary         ${tender_data.data.assetHolder.identifier}     legalName
    ${holder_scheme}            Get From Dictionary         ${tender_data.data.assetHolder.identifier}     scheme
    Switch Browser      my_custom_alias
    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_privatization_asset/add')]/button     20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_privatization_asset/add')]/button
    Sleep  1
    Wait Until Page Contains Element     css=[data-qa='info_title']       20
    Input Text                           css=[data-qa='info_title']                     ${title}
    Input Text                           css=[data-qa='info_descr']                     ${description}
    Input Text                           css=[data-qa='decision_title']                 ${decisions_title}
    Input Text                           xpath=(//div[contains(@class, 'react-datepicker__input')]//input)[last()]         ${decisions_date}
    Input Text                           css=[data-qa='decision_num']                   ${decisions_id}
    Input Text                           css=[data-qa='holder_legal_name']              ${holder_name}
    Input Text                           css=[data-qa='holder_srn']                     ${holder_id}
    Click Element                        css=[data-qa='holder_scheme']
    Click Element                        xpath=//div[contains(@data-qa, 'holder_scheme')]//div[text()='UA-EDR']
    Click Element                        css=[data-qa='holder_address_country']
    Click Element                        xpath=//div[contains(@data-qa, 'holder_address_country')]//div[text()='${holder_countryName}']
    ${holder_region}=   Run Keyword If   '${holder_region}' != 'місто Київ'    remove string     ${holder_region}   область
    ...    ELSE IF  '${holder_region}' != 'містоКиїв'    remove string     ${holder_region}    місто
    ...    ELSE    remove string     ${holder_region}    місто
    ${holder_region}=    Replace String   ${holder_region}   ${space}  ${empty}
    Click Element                        css=[data-qa='holder_address_region']
    Click Element                        xpath=//div[contains(@data-qa, 'holder_address_region')]//div[text()='${holder_region}']
    Input Text                           css=[data-qa='holder_address_postal_code']           ${holder_postalCode}
    Input Text                           css=[data-qa='holder_address_locality']              ${holder_region}
    Input Text                           css=[data-qa='holder_address_street']                ${holder_streetAddress}
    Input Text                           css=[data-qa='holder_contact_name']                  ${holder_name}
    Input Text                           css=[data-qa='holder_contact_phone']                 ${holder_telephone}
    ${items}=   Get From Dictionary   ${tender_data.data}   items
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//button[contains(@data-qa, 'add_item')]/span)[last()]
    \  Додати актив МП    ${items[${index}]}
    Click Element                        css=[data-qa='btn_create']
    capture page screenshot
    Sleep   5
    Wait Until Page Contains Element        css=[href*='state_privatization_asset/edit']    20
    Click Element       css=[href*='state_privatization_asset/edit']
    Sleep   2
    Wait Until Page Contains Element        css=[data-qa='btn_change_status']   20
    Click Element       css=[data-qa='btn_change_status']
    Sleep   10
    Reload page
    Sleep   2
    ${tender_uaid}=     Get Text        css=[data-qa='qa_uid']
    ${tender_uaid}=    Run Keyword If   '${tender_uaid}' == 'не вказано'    Run Keywords
    ...    Sleep  20
    ...    AND    Reload page
    ...    AND    Sleep  3
    ${tender_uaid}=    Get Text        css=[data-qa='qa_uid']
    ${access_token}=    Get Variable Value    ${tender_uaid.access.token}
    Set To Dictionary   ${USERS.users['${username}']}    access_token=${access_token}
    [Return]    ${tender_uaid}


Додати актив МП
    [Arguments]  ${items}
    ${item_descr}               Get From Dictionary         ${items}             description
    ${item_quantity}            Get From Dictionary         ${items}             quantity
    ${item_quantity}=           Convert To String           ${item_quantity}
    ${item_unit_name}           Get From Dictionary         ${items.unit}        name
    ${unit}=                    convert_prom_code_to_common_string      ${item_unit_name}
    ${item_status_registr}      Get From Dictionary         ${items.registrationDetails}     status
    ${item_status_registr} =    convert_registration_details   ${item_status_registr}
    ${item_country}             Get From Dictionary         ${items.address}     countryName
    ${item_locality}            Get From Dictionary         ${items.address}     locality
    ${item_postal}              Get From Dictionary         ${items.address}     postalCode
    ${item_region}              Get From Dictionary         ${items.address}     region
    ${item_address}             Get From Dictionary         ${items.address}     streetAddress
    ${cav_id}                   Get From Dictionary         ${items.classification}     id
    ${cav_description}          Get From Dictionary         ${items.classification}     description
    capture page screenshot
    Input Text                           xpath=(//input[@data-qa='item_descr'])[last()]                     ${item_descr}
    Input Text                           xpath=(//input[@data-qa='item_quantity'])[last()]                  ${item_quantity}
    Click Element                        xpath=(//div[@data-qa='item_unit'])[last()]
    Click Element                        xpath=(//div[@data-qa='item_unit']//*[text()='${unit}'])[last()]
    sleep  5
    Click Element                        xpath=(//div[@data-qa='item_classifier_cpvcavps'])[last()]
    Sleep  2
    Click Element                        css=div[class*='dialog__open'] > [data-qa='classifier_popup'] input[data-qa='tree_search_input']
    Input Text                           css=div[class*='dialog__open'] > [data-qa='classifier_popup'] input[data-qa='tree_search_input']   ${cav_id}
    Sleep  1
    Press Key                            css=div[class*='dialog__open'] > [data-qa='classifier_popup'] input[data-qa='tree_search_input']         \\13
    Sleep  3
    Click Element                        xpath=(//mark[text()='${cav_id}']//parent::*//parent::*//parent::*//parent::*//parent::*//*[@data-qa='tree_select'])[last()]
    Click Element                        css=div[class*='dialog__open'] > [data-qa='classifier_popup'] button[data-qa='ok']
    Click Element                        xpath=(//div[@data-qa='item_registration_status'])[last()]
    Click Element                        xpath=(//div[@data-qa="item_registration_status"]//*[text()="${item_status_registr}"])[last()]
    sleep   1
    Click Element                        xpath=(//div[@data-qa='item_address_country'])[last()]
    Click Element                        xpath=(//div[@data-qa='item_address_country']//div[text()='${item_country}'])[last()]
    sleep   1
    ${item_region}=   Run Keyword If   '${item_region}' != 'місто Київ'    remove string     ${item_region}   область
    ...    ELSE IF  '${item_region}' != 'містоКиїв'    remove string     ${item_region}    місто
    ...    ELSE    remove string     ${item_region}    місто
    ${item_region}=    Replace String   ${item_region}   ${space}  ${empty}
    Click Element                        xpath=(//div[@data-qa='item_address_region'])[last()]
    Click Element                        xpath=(//div[@data-qa='item_address_region']//div[text()='${item_region}'])[last()]
    sleep   1
    Input Text                           xpath=(//input[@data-qa='item_address_postal_code'])[last()]       ${item_postal}
    Input Text                           xpath=(//input[@data-qa='item_address_locality'])[last()]          ${item_region}
    Input Text                           xpath=(//input[@data-qa='item_address_street'])[last()]            ${item_address}


Пошук об’єкта МП по ідентифікатору
    [Arguments]   ${username}   ${tender_uaid}
    log to console    ${tender_uaid}
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].default_page}
    sleep    3
    ${href}=    Get Location
    Run Keyword If  '${href}' in 'https://zakupki.dz-test.net/signin'  Run Keywords
    ...   Input Text      ${login_sign_in}          ${USERS.users['${username}'].login}
    ...   AND    Input Text      ${password_sign_in}       ${USERS.users['${username}'].password}
    ...   AND    Click Button    id=submit_button
    ...   AND    Sleep   2
    Go to   ${USERS.users['${username}'].default_page}
    sleep   3
    Wait Until Page Contains Element      css=[data-qa="search_form_input"]     20
    Input Text         css=[data-qa="search_form_input"]     ${tender_uaid}
    Sleep  2
    Click Element     css=[data-qa="search_form_search_button"]
    Wait Until Keyword Succeeds     180      10          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=(//*[@data-qa='result_row'][1])
    Click Element     xpath=(//*[@data-qa='result_row'][1]//*[@data-qa='asset_title']//a)
    Sleep  2


Оновити сторінку з об'єктом МП
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser    my_custom_alias
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}

Отримати інформацію із об'єкта МП
    [Arguments]   ${username}   ${tender_uaid}   ${field_name}
    ${return_value}=    Run Keyword If    '${field_name}' == 'assetID'
    ...  Get Text   css=[data-qa="qa_uid"]
    ...  ELSE IF  '${field_name}' == 'date'                                     Get Element Attribute   xpath=//div[contains(@class, 'qa_created_date')]@data-qa
    ...  ELSE IF  '${field_name}' == 'rectificationPeriod.endDate'              Get Element Attribute   xpath=//div[contains(@class, "qa_rectification_date")]@data-qa2
    ...  ELSE IF  '${field_name}' == 'dateModified'                             Get Element Attribute   xpath=//div[contains(@class, "qa_modified_date")]@data-qa
    ...  ELSE IF  '${field_name}' == 'status'                                   Get Text   css=[data-qa="qa_status_text"]
    ...  ELSE IF  '${field_name}' == 'title'                                    Get Text   xpath=//h1
    ...  ELSE IF  '${field_name}' == 'description'                              Get Text   css=[data-qa="asset_description"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].title'                       Get Text   css=[data-qa="qa_solutions_text"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionDate'                Get Element Attribute   xpath=//div[contains(@class, 'qa_decision_date')]@data-qa
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionID'                  Get Text   css=[data-qa="qa_numer_solutions"]
    ...  ELSE IF  '${field_name}' == 'assetHolder.name'                         Get Text   css=.qa_holder_name
    ...  ELSE IF  '${field_name}' == 'assetHolder.identifier.scheme'            Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'assetHolder.identifier.id'                Get Text   css=.qa_holder_srn
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.scheme'         Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'documents[0].documentType'                Get Text   css=[data-qa="doc_type"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.id'             Get Text   css=[data-qa="merchant_srn"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.legalName'      Get Text   css=[data-qa="merchant_name"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.name'         Get Text   css=[data-qa="main_contact_name"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.telephone'    Get Text   css=[data-qa="main_contact_phone"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.email'        Get Text   css=[data-qa="main_contact_email"]
    ...  ELSE IF  '${field_name}' == 'decisions[1].title'                       Get Text   css=[data-qa="qa_solutions_text"]
    ...  ELSE IF  '${field_name}' == 'decisions[1].decisionDate'                Get Element Attribute   xpath=//div[contains(@class, "qa_decision_date")]@data-qa
    ...  ELSE IF  '${field_name}' == 'decisions[1].decisionID'                  Get Text   xpath=(//div[@data-qa="qa_numer_solutions"])[2]
    ...  ELSE IF  '${field_name}' == 'rectificationPeriod.endDate'              Get Element Attribute       xpath=//div[contains(@class, "qa_rectification_date")]@data-qa2
    capture page screenshot
    ${return_value}=  Run Keyword If  '${field_name}' == 'status'   convert_prom_code_to_common_string   ${return_value}
    ...   ELSE IF   '${field_name}' == 'documents[0].documentType'   convert_document_type      ${return_value}
    ...   ELSE      convert_prom_string_to_common_string     ${return_value}
    [Return]  ${return_value}


Отримати інформацію з активу об'єкта МП
    [Arguments]   ${username}   ${tender_uaid}   ${item_id}   ${field_name}
    ${return_value}=    Run Keyword If    '${field_name}' == 'description'
    ...   Get Text   xpath=//div[@data-qa='item_descr'][contains(text(), '${item_id}')]
    ...   ELSE IF  '${field_name}' == 'classification.scheme'                    Get Element Attribute   xpath=//span[@data-qa="primary_classifier"]@data-type
    ...   ELSE IF  '${field_name}' == 'classification.id'                        Get Element Attribute   xpath=//span[@data-qa="primary_classifier"]@data-code
    ...   ELSE IF  '${field_name}' == 'unit.name'                                Get Element Attribute   xpath=//td[contains(@class, 'qa_item_count')]@data-unit
    ...   ELSE IF  '${field_name}' == 'quantity'                                 Get Element Attribute   xpath=//td[contains(@class, 'qa_item_count')]@data-qa
    ...   ELSE IF  '${field_name}' == 'registrationDetails.status'               Get Text   css=[data-qa="registration_status"]
    ${return_value}=  Run Keyword If  '${field_name}' == 'registrationDetails.status'   revert_registration_details      ${return_value}
    ...   ELSE IF  '${field_name}' == 'classification.scheme'    convert_prom_code_to_common_string    ${return_value}
    ...   ELSE IF  '${field_name}' == 'quantity'     convert to number     ${return_value.replace(',', '.')}
    ...   ELSE      convert_prom_string_to_common_string     ${return_value}
    capture page screenshot
    [Return]  ${return_value}


Завантажити ілюстрацію в об'єкт МП
    [Arguments]  ${username}    ${tender_uaid}    ${filepath}
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element      css=[href*='state_privatization_asset/edit'] span    30
    Click Element     css=[href*='state_privatization_asset/edit'] span
    Choose File       css=[data-qa="upload_file"]       ${filepath}
    Wait Until Page Contains Element      xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  5
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()='Ілюстрації'])[last()]
    Sleep  3
    Click Element     css=[data-qa="btn_save"]

Завантажити документ в об'єкт МП з типом
    [Arguments]  ${username}    ${tender_uaid}    ${filepath}   ${documentType}
    capture page screenshot
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element      css=[href*='state_privatization_asset/edit'] span    30
    Click Element     css=[href*='state_privatization_asset/edit'] span
    Choose File       css=[data-qa="upload_file"]       ${filepath}
    ${documentType}=  Run Keyword If  '${documentType}' == 'notice'     convert_prom_code_to_common_string    ${documentType}
    ...     ELSE     revert_document_type        ${documentType}
    Wait Until Page Contains Element      xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  5
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()="${documentType}"])[last()]
    Sleep  3
    Click Element     css=[data-qa="btn_save"]

Внести зміни в об'єкт МП
    [Arguments]    ${username}    ${tender_uaid}   ${fieldname}    ${fieldvalue}
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element      css=[href*='state_privatization_asset/edit'] span    30
    Click Element     css=[href*='state_privatization_asset/edit'] span
    ${return_value}=    Run Keyword If    '${field_name}' == 'title'
    ...  Input Text   css=[data-qa="info_title"]    ${fieldvalue}
    ...  ELSE IF  '${field_name}' == 'description'      Input Text   css=[data-qa="info_descr"]     ${fieldvalue}
    Click Element     css=[data-qa="btn_save"]

Внести зміни в актив об'єкта МП
    [Arguments]    ${username}    ${item_id}    ${tender_uaid}    ${fieldname}    ${fieldvalue}
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    capture page screenshot
    Wait Until Page Contains Element      css=[href*='state_privatization_asset/edit'] span    30
    Click Element     css=[href*='state_privatization_asset/edit'] span
    Sleep   2
    Wait Until Page Contains Element      css=[data-qa='item_quantity']
    Sleep   2
    ${fieldvalue}       convert to string     ${fieldvalue}
    Input Text   css=[data-qa='item_quantity']   ${fieldvalue}
    Sleep   2
    Click Element     css=[data-qa="btn_save"]

Отримати кількість активів в об'єкті МП
    [Arguments]    ${username}    ${tender_uaid}
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    ${count}=    Get matching xpath count  xpath=//tr[@data-qa="item_rows"]
    [Return]    ${count}

Додати актив до об'єкта МП
    [Arguments]    ${username}    ${tender_uaid}     ${item}
    prom.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
    Wait Until Page Contains Element      css=[href*='state_privatization_asset/edit'] span    30
    Click Element     css=[href*='state_privatization_asset/edit'] span
    Click Element     xpath=(//button[@data-qa="add_item"])[last()]
    Run KeyWord   Додати актив МП   ${item}
    Click Element     css=[data-qa="btn_save"]


Отримати документ
    [Arguments]  ${username}  ${tender_uaid}  ${document_name}
    capture page screenshot
    Wait Until Keyword Succeeds     130      10          Run Keywords
        ...   Sleep  2
        ...   AND     Reload Page
        ...   AND     Sleep  2
        ...   AND     Wait Until Element Is Visible       xpath=(//div//*[contains(text(), "${document_name}")])
    Mouse Over          xpath=(//div//*[contains(text(), "${document_name}")])
    Sleep   1
    Click Element       xpath=(//div//*[contains(text(), "${document_name}")]//..//button)
    Sleep   2
    ${doc_name}=            Get Text                    xpath=(//div//*[contains(text(), "${document_name}")])
    ${home_dir}             Get Environment Variable    HOME
    move_uploaded_file      ${doc_name}     ${home_dir}     ${OUTPUT_DIR}
    Sleep  2
    [Return]   ${doc_name}

#------------------------------------------------------------------------------
Завантажити документ для видалення об'єкта МП
    [Arguments]   ${username}   ${tender_uaid}      ${filepath}
    Switch Browser    my_custom_alias
    Sleep  1
    Wait Until Page Contains Element        css=[data-qa='cancel_']             20
    Click Element                           css=[data-qa='cancel_']
    Wait Until Page Contains Element        css=[data-qa='upload_file']         20
    Choose File                             css=[data-qa='upload_file']         ${filepath}
    Wait Until Page Contains Element        css=[data-qa='delete_file']         20
    Click Element                           css=[data-qa='ok']
    Wait Until Page Contains Element        css=[data-qa='qa_status_text']      20
    ${status_text}=    Get Text             css=[data-qa='qa_status_text']
    ${status_text}=    Run Keyword If    '${status_text}' == 'Опубліковано. Очікування інформаційного повідомлення.'    Run Keywords
    ...    Sleep  10
    ...    AND    Reload page
    ...    AND    Sleep  3


Видалити об'єкт МП
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser      my_custom_alias
    Sleep   1


Створити лот
    [Arguments]   ${username}   ${tender_data}      ${tender_uaid}
    Switch Browser    my_custom_alias
    ${decisions_date}=          Get From Dictionary         ${tender_data.data.decisions[0]}        decisionDate
    ${decisions_date}=          convert_iso_date_to_prom    ${decisions_date}
    ${decisions_id}=            Get From Dictionary         ${tender_data.data.decisions[0]}        decisionID
    prom.Пошук об’єкта МП по ідентифікатору   ${username}   ${tender_uaid}
    capture page screenshot
    Wait Until Page Contains Element     css=[data-qa='edit_button']     20
    Click Element                        css=[data-qa='edit_button']
    Sleep  2
    Wait Until Page Contains Element     css=[data-qa='info_title']       20
    Input Text                           xpath=(//div[contains(@class, 'react-datepicker__input')]//input)[last()]         ${decisions_date}
    Input Text                           css=[data-qa='decision_num']                   ${decisions_id}
    Click Element                        css=[data-qa='btn_save']
    Sleep  5
    Wait Until Page Contains Element     css=[data-qa='link_lot']     20
    Click Element                        css=[data-qa='link_lot']
    Sleep  3
    ${tender_uaid}=              Get Text                   css=[data-qa="qa_uid"]
    [Return]  ${tender_uaid}


Додати умови проведення аукціону
    [Arguments]   ${username}  ${tender_data}  ${index}  ${tender_uaid}
    Switch Browser    my_custom_alias
    Run Keyword If    '${index}' == '0'
    ...  Заповнити аукціон   ${tender_data}
    ...  ELSE       Заповнити кількість днів    ${tender_data}


Заповнити аукціон
    [Arguments]     ${tender_data}
    ${start_date}=              Get From Dictionary         ${tender_data.auctionPeriod}            startDate
    ${conver_date}=             iso_date                    ${start_date}
    ${bank_description}=        Get From Dictionary         ${tender_data.bankAccount.accountIdentification[0]}                description
    ${bank_id}=                 Get From Dictionary         ${tender_data.bankAccount.accountIdentification[0]}                id
    ${bank_scheme}=             Get From Dictionary         ${tender_data.bankAccount.accountIdentification[0]}                scheme
    ${bank_name}=               Get From Dictionary         ${tender_data.bankAccount}                                         bankName
    ${guarantee_ampunt}=        Get From Dictionary         ${tender_data.guarantee}                amount
    ${guarantee_ampunt}=        Convert To String           ${guarantee_ampunt}
    ${guarantee_currency}=      Get From Dictionary         ${tender_data.guarantee}                currency
    ${step_amount}=             Get From Dictionary         ${tender_data.minimalStep}              amount
    ${step_amount}=             Convert To String           ${step_amount}
    ${step_currency}=           Get From Dictionary         ${tender_data.minimalStep}              currency
    ${step_tax}=                Get From Dictionary         ${tender_data.minimalStep}              valueAddedTaxIncluded
    ${fee_amount}=              Get From Dictionary         ${tender_data.registrationFee}          amount
    ${fee_amount}=              Convert To String           ${fee_amount}
    ${fee_currency}=            Get From Dictionary         ${tender_data.registrationFee}          currency
    ${value_amount}             Get From Dictionary         ${tender_data.value}                    amount
    ${value_amount}=            Convert To String           ${value_amount}
    ${value_currency}           Get From Dictionary         ${tender_data.value}                    currency
    ${value_tax}                Get From Dictionary         ${tender_data.value}                    valueAddedTaxIncluded

    Wait Until Page Contains Element     css=[data-qa='edit_button']     20
    Click Element                        css=[data-qa='edit_button']
    Sleep  1
    Input Text                           css=[data-qa='auction_start_date']             ${conver_date}
    Click Element                        css=[data-qa='guarantee_price']
    sleep   1
    Click Element                        xpath=(//div[@data-qa='currency'])[last()]
    Click Element                        xpath=(//div[@data-qa="currency"]//*[text()="гривня"])[last()]
    sleep   1
    Input Text                           css=[data-qa='start_auction_price']            ${value_amount}
    Input Text                           css=[data-qa='amount_percent']                 ${step_amount}
    Input Text                           css=[data-qa='guarantee_price']                ${guarantee_ampunt}
    Input Text                           css=[data-qa='registration_price']             ${fee_amount}
    Input Text                           css=[data-qa='auction_steps']                  1
    Input Text                           css=[data-qa='account_bank_name']              ${bank_name}
    Input Text                           css=[data-qa='account_srn']                    ${bank_id}
    Input Text                           css=[data-qa='account_mfo']                    ${bank_scheme}
    Input Text                           css=[data-qa='account_number']                 ${bank_description}
    capture page screenshot


Заповнити кількість днів
    [Arguments]     ${tender_data}
    ${month}=                   Get From Dictionary         ${tender_data}            tenderingDuration
    Sleep  1
    ${month}=       Run Keyword If    '${month}' == 'P1M'
    ...   set variable      30
    Input Text                           css=[data-qa='days']                           ${month}
    sleep   1
    capture page screenshot
    Click Element                        css=[data-qa='save_lot']


Оновити сторінку з лотом
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser    my_custom_alias
    prom.Пошук лота МП по ідентифікатору    ${username}    ${tender_uaid}


Пошук лоту по ідентифікатору
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser    my_custom_alias
    prom.Пошук лота МП по ідентифікатору    ${username}    ${tender_uaid}


Пошук лота МП по ідентифікатору
    [Arguments]   ${username}   ${tender_uaid}
    log to console    ${tender_uaid}
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].default_page}
    Sleep    3
    Wait Until Page Contains Element     css=[href*='state_privatization_lot']     20
    Click Element                        css=[href*='state_privatization_lot']
    Sleep    3
    ${href}=    Get Location
    Run Keyword If  '${href}' in 'https://zakupki.dz-test.net/signin'  Run Keywords
    ...   Input Text      ${login_sign_in}          ${USERS.users['${username}'].login}
    ...   AND    Input Text      ${password_sign_in}       ${USERS.users['${username}'].password}
    ...   AND    Click Button    id=submit_button
    ...   AND    Sleep   2
    Go to   ${USERS.users['${username}'].default_page}
    Sleep    3
    Wait Until Page Contains Element     css=[href*='state_privatization_lot']     20
    Click Element                        css=[href*='state_privatization_lot']
    Sleep    3
    Wait Until Page Contains Element      css=[data-qa="search_form_input"]     20
    Input Text         css=[data-qa="search_form_input"]     ${tender_uaid}
    Sleep  2
    Click Element     css=[data-qa="search_form_search_button"]
    Wait Until Keyword Succeeds     180      10          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=(//*[@data-qa='result_row'][1])
    Click Element     xpath=(//*[@data-qa='result_row'][1]//*[@data-qa='lot_title']//a)
    Sleep  2


Отримати інформацію із лоту
    [Arguments]   ${username}   ${tender_uaid}   ${field_name}
    capture page screenshot
    Reload Page
    Sleep   2
    Click Element     css=[data-qa="link_lot"]
    Sleep   3
    ${return_value}=    Run Keyword If    '${field_name}' == 'assetID'
    ...  Get Text   css=[data-qa="qa_uid"]
    ...  ELSE IF  '${field_name}' == 'date'                                     Get Element Attribute   xpath=//div[contains(@class, 'qa_created_date')]@data-qa
    ...  ELSE IF  '${field_name}' == 'rectificationPeriod.endDate'              Get Element Attribute   xpath=//div[contains(@class, "qa_rectification_date")]@data-qa2
    ...  ELSE IF  '${field_name}' == 'dateModified'                             Get Element Attribute   xpath=//div[contains(@class, "qa_modified_date")]@data-qa
    ...  ELSE IF  '${field_name}' == 'status'                                   Get Text   css=[data-qa="qa_status_text"]
    ...  ELSE IF  '${field_name}' == 'title'                                    Get Text   xpath=//h1
    ...  ELSE IF  '${field_name}' == 'description'                              Get Text   css=[data-qa="asset_description"]
    ...  ELSE IF  '${field_name}' == 'assetHolder.name'                         Get Text   css=.qa_holder_name
    ...  ELSE IF  '${field_name}' == 'assetHolder.identifier.scheme'            Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'assetHolder.identifier.id'                Get Text   css=[data-qa="qa_holder_srn"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.scheme'         Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'documents[0].documentType'                Get Text   css=[data-qa="doc_type"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.id'             Get Text   css=.qa_holder_srn
    ...  ELSE IF  '${field_name}' == 'assetCustodian.identifier.legalName'      Get Text   css=[data-qa="merchant_name"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.name'         Get Text   css=[data-qa="main_contact_name"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.telephone'    Get Text   css=[data-qa="main_contact_phone"]
    ...  ELSE IF  '${field_name}' == 'assetCustodian.contactPoint.email'        Get Text   css=[data-qa="main_contact_email"]
    ...  ELSE IF  '${field_name}' == 'lotID'                                    Get Text   css=[data-qa="qa_uid"]
    ...  ELSE IF  '${field_name}' == 'lotHolder.name'                           Get Text   css=.qa_holder_name
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.scheme'              Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.id'                  Get Text   css=.qa_holder_srn
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.scheme'           Get Text   css=[data-qa="qa_url"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.id'               Get Text   css=[data-qa="merchant_srn"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.legalName'        Get Text   css=[data-qa="merchant_name"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.name'           Get Text   css=[data-qa="main_contact_name"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.telephone'      Get Text   css=[data-qa="main_contact_phone"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.email'          Get Text   css=[data-qa="main_contact_email"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].title'                       Get Text   xpath=(//div[@data-qa='qa_solutions_text'])[1]
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionDate'                Get Element Attribute   xpath=(//div[contains(@class, 'qa_decision_date')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionID'                  Get Text   xpath=(//div[@data-qa="qa_numer_solutions"])[1]
    ...  ELSE IF  '${field_name}' == 'decisions[1].title'                       Get Text   xpath=(//div[@data-qa='qa_solutions_text'])[2]
    ...  ELSE IF  '${field_name}' == 'decisions[1].decisionDate'                Get Element Attri bute   xpath=(//div[contains(@class, "qa_decision_date")])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'decisions[1].decisionID'                  Get Text   xpath=(//div[@data-qa="qa_numer_solutions"])[2]
    ...  ELSE IF  '${field_name}' == 'auctions[0].procurementMethodType'        Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_method_type')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].procurementMethodType'        Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_method_type')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].procurementMethodType'        Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_method_type')])[3]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].status'                       Get Text                    xpath=(//div[contains(@class, 'qa_auction_method_type')])[1]
    ...  ELSE IF  '${field_name}' == 'auctions[1].status'                       Get Text                    xpath=(//div[contains(@class, 'qa_auction_method_type')])[2]
    ...  ELSE IF  '${field_name}' == 'auctions[2].status'                       Get Text                    xpath=(//div[contains(@class, 'qa_auction_method_type')])[3]
    ...  ELSE IF  '${field_name}' == 'auctions[0].tenderAttempts'               Set variable      1
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderAttempts'               Set variable      2
    ...  ELSE IF  '${field_name}' == 'auctions[2].tenderAttempts'               Set variable      3
    ...  ELSE IF  '${field_name}' == 'auctions[0].value.amount'                 Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_amount')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].value.amount'                 Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_amount')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].value.amount'                 Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_amount')])[3]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].minimalStep.amount'           Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_step')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].minimalStep.amount'           Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_step')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].minimalStep.amount'           Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_step')])[3]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].guarantee.amount'             Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_guarantee')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].guarantee.amount'             Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_guarantee')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].guarantee.amount'             Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_guarantee')])[3]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].registrationFee.amount'       Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_registration')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].registrationFee.amount'       Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_registration')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].registrationFee.amount'       Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_registration')])[3]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].auctionPeriod.startDate'      Get Element Attribute       xpath=(//div[contains(@class, "qa_auction_date")])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].tenderingDuration'            Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_period')])[1]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderingDuration'            Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_period')])[2]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[2].tenderingDuration'            Get Element Attribute       xpath=(//div[contains(@class, 'qa_auction_period')])[3]@data-qa
    ${return_value}=  Run Keyword If  '${field_name}' == 'status'               convert_prom_code_to_common_string      ${return_value}
    ...   ELSE IF   '${field_name}' == 'documents[0].documentType'              convert_document_type                   ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].status'                     convert_prom_code_to_common_string      ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].status'                     convert_prom_code_to_common_string      ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].status'                     convert_prom_code_to_common_string      ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].value.amount'               CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].value.amount'               CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].value.amount'               CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].minimalStep.amount'         CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].minimalStep.amount'         CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].minimalStep.amount'         CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].guarantee.amount'           CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].guarantee.amount'           CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].guarantee.amount'           CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].registrationFee.amount'     CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].registrationFee.amount'     CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].registrationFee.amount'     CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[0].tenderAttempts'             CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[1].tenderAttempts'             CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].tenderAttempts'             CONVERT TO NUMBER                       ${return_value}
    ...   ELSE IF   '${field_name}' == 'auctions[2].procurementMethodType'      convert_prom_code_to_common_string      ${return_value}
    ...   ELSE      convert_prom_string_to_common_string                        ${return_value}
    [Return]  ${return_value}


Завантажити ілюстрацію в лот
    [Arguments]  ${username}    ${tender_uaid}    ${filepath}
    capture page screenshot
    prom.Пошук лота МП по ідентифікатору    ${username}    ${tender_uaid}
    capture page screenshot
    Click Element     css=[data-qa="link_lot"]
    Wait Until Page Contains Element      css=[data-qa="edit_button"]    30
    Click Element     css=[data-qa="edit_button"]
    Choose File       xpath=(//*[@data-qa='upload_all_documents']//*[@data-qa='upload_file'])       ${filepath}
    Wait Until Page Contains Element      xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  5
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()='Ілюстрації'])[last()]
    Sleep  3
    prom.Завантажити документ про зміни     ${username}    ${tender_uaid}
    capture page screenshot
    Click Element     css=[data-qa="save_lot"]


Завантажити документ в лот з типом
    [Arguments]  ${username}    ${tender_uaid}    ${filepath}    ${documentType}
    prom.Пошук лота МП по ідентифікатору    ${username}    ${tender_uaid}
    Click Element     css=[data-qa="link_lot"]
    Wait Until Page Contains Element      css=[data-qa="edit_button"]    30
    Click Element     css=[data-qa="edit_button"]
    Choose File       xpath=(//*[@data-qa='upload_all_documents']//*[@data-qa='upload_file'])       ${filepath}
    ${documentType}=        revert_document_type        ${documentType}
    Wait Until Page Contains Element      xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  5
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()="${documentType}"])[last()]
    Sleep  3
    capture page screenshot
    prom.Завантажити документ про зміни     ${username}    ${tender_uaid}
    Click Element     css=[data-qa="save_lot"]
    capture page screenshot


Завантажити документ про зміни
    [Arguments]  ${username}    ${tender_uaid}
    ${filepath}=        create_random_file
    Choose File       xpath=(//*[@data-qa='upload_all_documents']//*[@data-qa='upload_file'])       ${filepath}
    Wait Until Page Contains Element      xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  5
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()='Рішення про внесення змін до інформаційного повідомлення'])[last()]
    Sleep  3
    Click Element     xpath=(//div[contains(@data-qa, 'document_type')])[last()]
    Sleep  3
    Click Element     xpath=(//div[text()='Рішення про внесення змін до інформаційного повідомлення'])[last()]
    Sleep  3



Завантажити документ для видалення лоту
    [Arguments]   ${username}   ${tender_uaid}      ${filepath}
    Switch Browser    my_custom_alias
    prom.Завантажити документ для видалення об'єкта МП   ${username}   ${tender_uaid}      ${filepath}


Видалити лот
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser      my_custom_alias
    Sleep   1


Отримати інформацію з активу лоту
    [Arguments]   ${username}   ${tender_uaid}    ${item_id}    ${field_name}
    Run Keyword If    '${field_name}' == 'description'
    ...  Get Element Attribute   xpath=//div[contains(@class, 'qa_created_date')]@data-qa
    ...  ELSE IF  '${field_name}' == 'classification.scheme'                    Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'classification.id'                        Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'unit.name'                                Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'quantity'                                 Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'registrationDetails.status'               Click Element     css=[data-qa="link_asset"]
    ...  ELSE IF  '${field_name}' == 'auctions[0].procurementMethodType'        Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'auctions[0].status'                       Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderAttempts'               Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'value.amount'                             Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'minimalStep.amount'                       Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'auctions[0].guarantee.amount'             Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'auctions[0].registrationFee.amount'       Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderingDuration'            Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'rectificationPeriod.endDate'              Click Element     css=[data-qa="link_asset"]
    ...  ELSE IF  '${field_name}' == 'title'                                    Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'description'                              Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotHolder.name'                           Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.scheme'              Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.id'                  Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.scheme'           Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.id'               Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.legalName'        Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.name'           Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.telephone'      Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.email'          Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].title'                       Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionDate'                Click Element     css=[data-qa="link_lot"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionID'                  Click Element     css=[data-qa="link_lot"]
    Sleep  2
    capture page screenshot
    ${return_value}=    Run Keyword If    '${field_name}' == 'description'
    ...  Get Text       xpath=//div[contains(text(), '${item_id}')]//parent::*[@data-qa='item_descr'][last()]
    ...  ELSE IF  '${field_name}' == 'classification.scheme'                    Get Element Attribute       xpath=//div[contains(text(), '${item_id}')]//parent::*//span[@data-qa='primary_classifier'][last()]@data-type
    ...  ELSE IF  '${field_name}' == 'classification.id'                        Get Element Attribute       xpath=//div[contains(text(), '${item_id}')]//parent::*//span[@data-qa='primary_classifier'][last()]@data-code
    ...  ELSE IF  '${field_name}' == 'unit.name'                                Get Element Attribute       xpath=//div[contains(text(), '${item_id}')]//parent::*//parent::*//td[contains(@class, 'qa_item_count')][last()]@data-unit
    ...  ELSE IF  '${field_name}' == 'quantity'                                 Get Element Attribute       xpath=//div[contains(text(), '${item_id}')]//parent::*//parent::*//td[contains(@class, 'qa_item_count')][last()]@data-qa
    ...  ELSE IF  '${field_name}' == 'registrationDetails.status'               Get Text                    xpath=//div[contains(text(), '${item_id}')]//parent::*//parent::*//div[@data-qa= 'registration_status']
    ...  ELSE IF  '${field_name}' == 'auctions[0].procurementMethodType'        Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_method_type')]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].status'                       Get Text                    xpath=//div[contains(@class, 'qa_auction_method_type')]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderAttempts'               Get matching xpath count    xpath=//tr[@data-qa="item_rows"]
    ...  ELSE IF  '${field_name}' == 'value.amount'                             Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_amount')]@data-qa
    ...  ELSE IF  '${field_name}' == 'minimalStep.amount'                       Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_step')]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].guarantee.amount'             Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_guarantee')]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[0].registrationFee.amount'       Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_registration')]@data-qa
    ...  ELSE IF  '${field_name}' == 'auctions[1].tenderingDuration'            Get Element Attribute       xpath=//div[contains(@class, 'qa_auction_period')]@data-qa
    ...  ELSE IF  '${field_name}' == 'rectificationPeriod.endDate'              Get Element Attribute       xpath=//div[contains(@class, "qa_rectification_date")]@data-qa2
    ...  ELSE IF  '${field_name}' == 'title'                                    Get Text                    xpath=//h1
    ...  ELSE IF  '${field_name}' == 'lotHolder.name'                           Get Text                    xpath=//div[contains(@class, 'qa_holder_name')]
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.scheme'              Get Text                    xpath=//div[contains(@class, 'qa_holder_address')]
    ...  ELSE IF  '${field_name}' == 'lotHolder.identifier.id'                  Get Text                    xpath=//div[contains(@class, 'merchant_srn')]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.scheme'           Get Text                    css=[data-qa="merchant_name"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.id'               Get Text                    css=[data-qa="qa_holder_srn"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.identifier.legalName'        Get Text                    css=[data-qa="merchant_address"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.name'           Get Text                    css=[data-qa="main_contact_name"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.telephone'      Get Text                    css=[data-qa="main_contact_phone"]
    ...  ELSE IF  '${field_name}' == 'lotCustodian.contactPoint.email'          Get Text                    css=[data-qa="main_contact_email"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].title'                       Get Text                    css=[data-qa="qa_solutions_text"]
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionDate'                Get Element Attribute       xpath=//div[contains(@class, 'qa_decision_date')]@data-qa
    ...  ELSE IF  '${field_name}' == 'decisions[0].decisionID'                  Get Text                    css=[data-qa="qa_numer_solutions"]
    ${return_value}=  Run Keyword If  '${field_name}' == 'auctions[0].status'   convert_prom_code_to_common_string   ${return_value}
    ...   ELSE IF   '${field_name}' == 'documents[0].documentType'      convert_document_type                   ${return_value}
    ...   ELSE IF   '${field_name}' == 'classification.scheme'          convert_prom_code_to_common_string      ${return_value}
    ...   ELSE IF   '${field_name}' == 'quantity'                       convert_to_float                        ${return_value}
    ...   ELSE IF   '${field_name}' == 'registrationDetails.status'     revert_registration_details             ${return_value}
    ...   ELSE      convert_prom_string_to_common_string     ${return_value}
    [Return]    ${return_value}


Завантажити документ в умови проведення аукціону
    [Arguments]   ${username}   ${tender_uaid}  ${filepath}  ${documentType}  ${auction_index}
    capture page screenshot
    prom.Завантажити документ в лот з типом     ${username}   ${tender_uaid}  ${filepath}  ${documentType}


Внести зміни в лот
    [Arguments]   ${username}   ${tender_uaid}    ${field_name}    ${field_value}
    capture page screenshot
    prom.Пошук лоту по ідентифікатору    ${username}    ${tender_uaid}
    capture page screenshot
    Wait Until Page Contains Element      css=[data-qa="edit_button"]    30
    Click Element     css=[data-qa="edit_button"]
    Sleep   2
    ${return_value}=    Run Keyword If    '${field_name}' == 'title'
    ...  Input Text   css=[data-qa="info_title"]    ${field_value}
    ...  ELSE IF    '${field_name}' == 'description'      Input Text   css=[data-qa="info_descr"]     ${field_value}
    prom.Завантажити документ про зміни     ${username}    ${tender_uaid}
    Click Element     css=[data-qa="save_lot"]
    Sleep   3


Внести зміни в умови проведення аукціону
    [Arguments]   ${username}   ${tender_uaid}    ${field_name}    ${field_value}   ${auction_index}
    capture page screenshot
    ${field_value}=       convert to string     ${field_value}
    Reload Page
    Sleep   3
    Wait Until Page Contains Element      css=[data-qa="edit_button"]    30
    Click Element     css=[data-qa="edit_button"]
    Sleep   2
    ${return_value}=    Run Keyword If    '${field_name}' == 'value.amount'
    ...  Input Text   css=[data-qa="start_auction_price"]    ${field_value}
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'         Input Text   css=[data-qa="amount_percent"]         ${field_value}
    ...  ELSE IF    '${field_name}' == 'guarantee.amount'           Input Text   css=[data-qa="guarantee_price"]        ${field_value}
    ...  ELSE IF    '${field_name}' == 'registrationFee.amount'     Input Text   css=[data-qa="registration_price"]     ${field_value}
    ...  ELSE IF    '${field_name}' == 'auctionPeriod.startDate'    Input Text   css=[data-qa="auction_start_date"]     ${field_value}
    prom.Завантажити документ про зміни     ${username}    ${tender_uaid}
    Click Element     css=[data-qa="save_lot"]
    capture page screenshot
    Sleep  3


Внести зміни в актив лоту
    [Arguments]   ${username}   ${item_id}    ${tender_uaid}    ${field_name}    ${field_value}
    Wait Until Page Contains Element      css=[data-qa="edit_button"]    30
    Click Element     css=[data-qa="edit_button"]
    Sleep   2
    ${field_value}=       convert to string     ${field_value}
    ${return_value}=    Run Keyword If    '${field_name}' == 'quantity'
    ...  Input Text       xpath=//*[contains(@value, '${item_id}')]//parent::*//parent::*//parent::*//*[@data-qa='item_quantity']     ${field_value}
    Sleep   2
    capture page screenshot
    prom.Завантажити документ про зміни     ${username}    ${tender_uaid}
    Click Element     css=[data-qa="save_lot"]
    Sleep   2
