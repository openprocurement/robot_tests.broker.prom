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
    ${adapted_data}=     Run keyword if    '${role_name}' == 'viewer'
    ...    adapt_viewer   ${tender_data}
    ...    ELSE IF  '${role_name}' == 'tender_owner'        adapt_owner             ${tender_data}
    ...    ELSE IF  '${role_name}' == 'provider'            adapt_provider          ${tender_data}
    ...    ELSE                                             adapt_provider1         ${tender_data}
    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    Set Global Variable      ${procurement_method_type}
    ${KeyIslot}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data.lots[0]}            title
    Set Global Variable      ${KeyIslot}
    [Return]  ${adapted_data}

Login
    [Arguments]  @{ARGUMENTS}
    Click Element   ${sign_in}
    Sleep   1
    Clear Element Text   name=email
    Input Text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
    Input Text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Button    id=submit_button
    Sleep   2

Подписание ЕЦП
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Wait Until Element Is Visible       css=#CAsServersSelect
    capture page screenshot
    click element    css=#CAsServersSelect
    sleep  3
    CLICK ELEMENT    xpath=//*[contains(text(), 'АЦСК ТОВ "КС"')]
    sleep  4
    click element    css=#CAsServersSelect
    sleep  2
    ${file_path}=    get_ecp_key    src/robot_tests.broker.prom/Key-6.dat
    Choose File       css=#PKeyFileInput      ${file_path}
    sleep  3
    Input Text    css=#PKeyPassword    1234
    sleep  3
    Click Element  css=#PKeyReadButton
    sleep  8
    Wait Until Element Is Visible   xpath=//p[@id='PKStatusInfo' and contains(text(), 'Ключ успішно завантажено')]
    sleep  2
    capture page screenshot
    Click Element  css=#SignDataButton
    sleep  40
    reload page
    capture page screenshot

Створити план
    [Arguments]   ${username}    ${plan_data}
    go to  ${USERS.users['${username}'].state_plan_page}
    sleep  1
    Click Element   xpath=(//a[contains(@href, 'state_plan/add')])[1]
    Sleep  2
    ${procurement_method_type}=         Get From Dictionary             ${plan_data.data.tender}           procurementMethodType
    Set Global Variable      ${procurement_method_type}
    Wait Until Page Contains Element        css=#state_plan_purchase_method_type_dd    20
    CLICK ELEMENT       css=#state_plan_purchase_method_type_dd
    sleep  2
    log to console  ------------------------------
    log to console  ${procurement_method_type}
    log to console  ------------------------------
    ${name}=   Run Keyword If   '${procurement_method_type}' == 'aboveThresholdEU'          створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'openeu'                        створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA'              створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA.defense'      створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'reporting'                     створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation'                   створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation_quick'             створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueUA'         створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueEU'         створити план для процедури                 ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'closeFrameworkAgreementUA'     Створити план closeFrameworkAgreementUA     ${username}    ${plan_data}      ${procurement_method_type}
    ...      ELSE IF        '${procurement_method_type}' == 'esco'                          Створити план esco                          ${username}    ${plan_data}
    ...      ELSE IF        '${procurement_method_type}' == 'centralizedProcurement'        Click Element    xpath=(//li[@data-value="centralizedProcurement"])[last()]

    CLICK ELEMENT  css=#submit_button
    sleep  10
    ${tender_uaid}=      Очікування tuid    очікування...    css=.qa_plan_uid
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       css=.qa_ecp_button
    sleep  1
    Click Element     css=.qa_ecp_button
    capture page screenshot
    prom.Подписание ЕЦП
    ${tender_uaid}=     get text     css=.qa_plan_uid
    ${access_token}=    Get Variable Value    ${tender_uaid.access.token}
    Set To Dictionary   ${USERS.users['${username}']}    access_token=${access_token}

    log to console  ****plan_id*****
    log to console  ${tender_uaid}
    log to console  ****************
    [Return]    ${tender_uaid}

створити план для процедури
    [Arguments]   ${username}    ${plan_data}   ${procurement_method_type}
    log to console  *(*(*(*((
    log to console   ${plan_data}
    log to console  *(*(*(*((
    ${description}=                     Get From Dictionary                     ${plan_data.data.budget}                        description
    ${amount}=                          Get From Dictionary                     ${plan_data.data.budget}                        amount
    ${classification}=                  Get From Dictionary                     ${plan_data.data.classification}                id

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'              Click Element    xpath=(//li[@data-value="aboveThresholdEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                Click Element    xpath=(//li[@data-value="belowThreshold"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'openeu'                        Click Element    xpath=(//li[@data-value="aboveThresholdEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA'              Click Element    xpath=(//li[@data-value="aboveThresholdUA"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA.defense'      Click Element    xpath=(//li[@data-value="aboveThresholdUA_defense"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'reporting'                     Click Element    xpath=(//li[@data-value="reporting"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation'                   Click Element    xpath=(//li[@data-value="negotiation"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation_quick'             Click Element    xpath=(//li[@data-value="negotiation_quick"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueUA'         Click Element    xpath=(//li[@data-value="competitiveDialogueUA"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueEU'         Click Element    xpath=(//li[@data-value="competitiveDialogueEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'centralizedProcurement'        Click Element    xpath=(//li[@data-value="centralizedProcurement"])[last()]

    SLEEP  1
    Input Text          css=[id="description"]                 ${description}
    sleep  1
    ${amount}=          Convert To String                      ${amount}
    Input Text          css=[id="amount"]                      ${amount}
    sleep  1
    Click Element       css=div[data-classifier-form-input-name*='primary_classifier_id'] a
    sleep  1
    input text          css=.qa_search_input                   ${classification}
    sleep  1
    Click Element       css=[class="b-checkbox__input"]
    sleep  2
    Click Element       css=.qa_submit
    sleep  1
    Click Element       xpath=(//a[contains(@data-url, '/add_item')])[last()]
    sleep  1

    #Добавление айтемов их обычно 2
    ${items}=   Get From Dictionary    ${plan_data.data}    items
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@data-url, '/add_item')])[last()]
    \  Додати айтем плана    ${items[${index}]}

    Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    sleep  1

    #Добавление Джерала их обычно 3
    ${breakdowns}=                Get From Dictionary             ${plan_data.data.budget}     breakdown
    ${number_of_breakdowns}=  Get Length  ${breakdowns}
    set global variable    ${number_of_breakdowns}
    :FOR  ${index}  IN RANGE  ${number_of_breakdowns}
    \  Run Keyword If  '${index}' != '0'   Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    \  Додати джерело плана    ${breakdowns[${index}]}
    SLEEP  1

Внести зміни в план
    [Arguments]   ${username}    ${tender_uaid}   ${field_name}     ${field_value}

    Wait Until Element Is Visible    xpath=//a[contains(@class, 'qa_edit_button')]
    click element   xpath=//a[contains(@class, 'qa_edit_button')]

    ${value}=    Run Keyword If                '${field_name}' == 'items[0].quantity'    convert to string   ${field_value}
    ${return_value}=     Run Keyword If                 '${field_name}' == 'budget.description'             input text   css=#description    ${field_value}
    ...  ELSE IF    '${field_name}' == 'items[0].quantity'                                  input text   css=#state_purchases_items_list-0-quantity    ${value}
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryDate.endDate'                      Get Text     css=#state_purchases_items_list-0-quantity
    sleep  2
    click element  css=#submit_button
    [Return]  ${return_value}

Додати предмет закупівлі в план
    [Arguments]   ${username}    ${tender_uaid}   ${plan_data}
    Wait Until Element Is Visible    xpath=//a[contains(@class, 'qa_edit_button')]
    click element   xpath=//a[contains(@class, 'qa_edit_button')]
    sleep  1
    Click Element     xpath=(//a[contains(@data-url, '/add_item')])[last()]
    sleep  1
    Додати айтем плана    ${plan_data}

    sleep  2
    click element  css=#submit_button

Очікування tuid
    [Arguments]   ${old_status}   ${locator}
    : FOR    ${i}    IN RANGE   1   60
    \   ${status_text}=        Get Text        ${locator}
    \   Exit For Loop If      '${status_text}' != '${old_status}'
    \   Sleep  10
    \   Reload Page
    \   Sleep  2
    [Return]    ${status_text}

Додати айтем плана
    [Arguments]   ${items}
    ${item_classification_description}=                 Get From Dictionary             ${items.classification}                      description
    ${item_classification_id}=                          Get From Dictionary             ${items.classification}                      id
    ${item_classification_scheme}=                      Get From Dictionary             ${items.classification}                      scheme
    ${item_description}=        Get From Dictionary             ${items}                      description
    ${item_description_en}=     Get From Dictionary             ${items}                      description_en
    ${item_description_ru}=     Get From Dictionary             ${items}                      description_ru
    ${item_quantity}=           Get From Dictionary             ${items}                      quantity
    ${item_quantity}=           Convert To String               ${item_quantity}
    ${unit_code}=               Get From Dictionary             ${items.unit}                 code
    ${unit_name}=               Get From Dictionary             ${items.unit}                 name

    ${endDate}=                       Get From Dictionary                     ${items.deliveryDate}           endDate
    ${endDate}=                       convert_iso_date_to_prom_without_time   ${endDate}



    capture page screenshot
    #Заполнение тела айтема ниже
    sleep  1
    Input Text    xpath=(//input[contains(@id, 'descr')])[last()]    ${item_description}
    sleep  1
    Input Text    xpath=(//input[contains(@id, 'quantity')])[last()]    ${item_quantity}
    sleep  1
    Click Element   xpath=(//div[contains(@id, 'unit_id_dd')])[last()]
    ${name}=   Run Keyword If   '${unit_name}' == 'штуки'        Click Element    xpath=(//li[@data-value="6"])[last()]
    ...      ELSE IF        '${unit_name}' == 'упаковка'         Click Element    xpath=(//li[@data-value="81"])[last()]
    ...      ELSE IF        '${unit_name}' == 'кілограми'        Click Element    xpath=(//li[@data-value="1"])[last()]
    ...      ELSE IF        '${unit_name}' == 'набір'            Click Element    xpath=(//li[@data-value="75"])[last()]
    ...      ELSE IF        '${unit_name}' == 'лот'              Click Element    xpath=(//li[@data-value="77"])[last()]
    ...      ELSE           '${unit_name}' == 'pct'              Click Element    xpath=(//li[@data-value="249"])[last()]
    SLEEP  1
    input text          css=#state_purchases_items_list-0-date_delivery_end     ${endDate}
    sleep  2
    click element       css=#state_purchases_items_list-0-date_delivery_end
    sleep  2
    Click Element     xpath=(//div[@data-classifier-code="dk021"]//span)[last()]
    sleep  1
    input text  css=.qa_search_input                        ${item_classification_id}
    sleep  1
    Click Element  css=[class="b-checkbox__input"]
    sleep  2

    Click Element  css=.qa_submit
    sleep  1

Видалити предмет закупівлі плану
    [Arguments]   ${username}     ${tender_uaid}     ${item_id}    ${lot_id}=Empty
    Wait Until Element Is Visible    xpath=//a[contains(@class, 'qa_edit_button')]
    click element   xpath=//a[contains(@class, 'qa_edit_button')]
    sleep  1
    capture page screenshot
    click element  xpath=//button[contains(@class, 'js-delete-state-plan-item')]/..//input[contains(@value, '${item_id}')]
    sleep  2
    click element  css=#submit_button

Додати джерело плана
    [Arguments]   ${breakdowns}
    ${breakdowns_description}=          Get From Dictionary             ${breakdowns}                      description
    ${breakdowns_title}=                Get From Dictionary             ${breakdowns}                      title
    ${breakdowns_amount}=               Get From Dictionary             ${breakdowns.value}                amount
    ${breakdowns_currency}=             Get From Dictionary             ${breakdowns.value}                currency
    sleep  2
    Click Element         xpath=(//div[contains(@id, 'title_dd')])[last()]
    sleep  2
    ${title}=   Run Keyword If   '${breakdowns_title}' == 'state'       Click Element    xpath=(//li[@data-value="state"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'crimea'           Click Element    xpath=(//li[@data-value="crimea"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'local'            Click Element    xpath=(//li[@data-value="local"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'own'              Click Element    xpath=(//li[@data-value="own"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'fund'             Click Element    xpath=(//li[@data-value="fund"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'loan'             Click Element    xpath=(//li[@data-value="loan"])[last()]
    ...      ELSE IF        '${breakdowns_title}' == 'other'            Click Element    xpath=(//li[@data-value="other"])[last()]
    ${breakdown_amount}=    Convert To String                           ${breakdowns_amount}
    sleep  1
    Input Text            xpath=(//input[contains(@id, 'value')])[last()]        ${breakdown_amount}
    SLEEP  1
    Input Text             xpath=(//textarea[contains(@name, 'description')])[last()]     ${breakdowns_description}
    sleep  1
    capture page screenshot

Пошук плана для провайдера
    [Arguments]    ${tender_uaid}
    Wait Until Page Contains Element      css=[data-qa="search_input"]
    Input Text         css=[data-qa="search_input"]   ${tender_uaid}
    Click Button    css=[data-qa="search_button"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    Wait Until Element Is Visible       xpath=(//a[@data-qa="tender_title"])[1]
    Click Element     xpath=(//a[@data-qa="tender_title"])[1]
    sleep  1

Пошук плана для Овнера
    [Arguments]    ${tender_uaid}
    Wait Until Page Contains Element      css=#search
    Input Text         css=#search   ${tender_uaid}
    Sleep  2
    Click Element     css=[type="submit"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    Wait Until Element Is Visible       xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
    Click Element     xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
    sleep   1

Пошук плану по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    log to console  ${tender_uaid}
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].state_plan_page}
    sleep  2
    Run Keyword If   '${username}' == 'Prom_Provider'   prom.Пошук плана для провайдера   ${tender_uaid}

    Run Keyword If   '${username}' == 'Prom_Owner' or '${username}' == 'Prom_Viewer'    prom.Пошук плана для Овнера    ${tender_uaid}

    log to console    ${tender_uaid}
    Sleep  2

Оновити сторінку з планом
    [Arguments]   ${username}    ${tender_uaid}
    Switch Browser    my_custom_alias
    sleep  1
    Reload Page
    sleep  2

Створити тендер
    [Arguments]    ${username}    ${tender_data}    ${plan_id}

    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    Set Global Variable      ${procurement_method_type}
    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'              Створити aboveThresholdEU                           ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA'              Створити aboveThresholdUA                           ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                Створити belowThreshold                             ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA.defense'      Створити aboveThresholdUA.defense                   ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'reporting'                     Створити reporting                                  ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation'                   Створити negotiation                                ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation_quick'             Створити тендер для типу закупівлі                  ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueUA'         Створити competitiveDialogueUA                      ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueEU'         Створити competitiveDialogueEU                      ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'closeFrameworkAgreementUA'     Створити closeFrameworkAgreementUA                  ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'centralizedProcurement'        Створити тендер для типу закупівлі                  ${username}     ${tender_data}     ${plan_id}
    ...      ELSE IF        '${procurement_method_type}' == 'esco'                          Створити esco                                       ${username}     ${tender_data}     ${plan_id}

    sleep  3
    click element     css=.qa_submit_tender
    sleep  5
    capture page screenshot
    ${tender_uaid}=      Очікування tuid    очікування...    css=.qa_state_purchase_ua_id
    log to console  ^**^*^*^*^*^*^*^**^*^
    log to console  ${tender_uaid}
    log to console  ^**^*^*^*^*^*^*^**^*^
    [Return]    ${tender_uaid}

Створити aboveThresholdEU
    [Arguments]    ${username}    ${tender_data}    ${plan_id}
    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${title_ru}=                        Get From Dictionary         ${tender_data.data}                                         title_ru
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${description_ru}=                  Get From Dictionary         ${tender_data.data}                                         description_ru
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${endDate}=                         Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${endDate}=                         convert_iso_date_to_prom      ${endDate}
    ${startDate}=                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            startDate
    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    ${availableLanguage}=               Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            availableLanguage
    ${name_en}=                         Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            name_en
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone

    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_title_en}=                   Get From Dictionary         ${tender_data.data.lots[0]}                                 title_en
    ${lots_title_ru}=                   Get From Dictionary         ${tender_data.data.lots[0]}                                 title_ru
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}

    ${features}                         Get From Dictionary         ${tender_data.data}                                         features

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones

    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'              Click Element    xpath=//span[text()='Відкриті торги з публікацією англійською мовою']
    SLEEP  2
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    click element  css=.qa_procurement_category_choices
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}

    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'       Clear Element Text  css=.qa_phone_in_en
    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'       input text  css=.qa_phone_in_en    ${telephone_en}
    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'       sleep  1
    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'       input text  css=.qa_email_in_en    ${email_en}

    ### Контакнтые данные на Англ  ###
    click element  xpath=//div[contains(@class, 'qa_contact_lis')]//div[contains(@class, 'qa_language')]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     xpath=//input[contains(@class, 'qa_contact_name undefined')]          ${test_name}

    input text  xpath=//input[contains(@class, 'qa_name_in_en')]    ${name_en}
    sleep  1
    CLICK ELEMENT  xpath=(//div[contains(@class, 'qa_select_contact_language')])[2]
    sleep  1
    Run Keyword If          '${availableLanguage}' == 'en'              Click Element    xpath=(//li[text()='English'])[2]
    ...      ELSE IF        '${availableLanguage}' == 'ru'              Click Element    xpath=(//li[text()='русский'])[2]

    Clear Element Text  css=.qa_phone_in_en
    input text  css=.qa_phone_in_en    ${telephone_en}
    sleep  1
    input text  css=.qa_email_in_en    ${email_en}

    #################Інформація про закупівлю на разных языках #############################

    input text     css=.qa_tender_title          ${title}
    sleep  2
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_title')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_title undefined')]         ${title_en}
    sleep  1
    input text     css=.qa_tender_description    ${description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_description')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_description undefined')]    ${description_en}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    SLEEP  1
    input text     css=.qa_multilot_end_period_adjustments       ${endDate}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    #############################Добавление features(Нецінові критерії)#######################################

    ${number_of_features}=      Get Length                        ${features}
    set global variable                                           ${number_of_features}
    :FOR  ${index}  IN RANGE  ${number_of_features}
    \  Додати нецінові критерії    ${features[${index}]}  ${procurement_method_type}

    #############################Добавление лота#######################################

    input text  css=.qa_lot_title                                    ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_title')])[last()]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]      ${lots_title}
    sleep  2
    input text  css=.qa_lot_description   ${lots_description}
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_description')])[last()]

    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]   ${lots_description}

    input text  css=.qa_multilot_tender_lot_bugdet        ${lots_amount}

    input text  css=.qa_multilot_tender_step_auction_rate            ${lots_minimalstep}


    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}   ${number_of_milestones}

    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити aboveThresholdUA
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}
    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdUA'       Click Element    xpath=(//span[text()='Відкриті торги'])[last()]
    sleep  2
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    # заполняем тендер
    input text     css=.qa_multilot_title                       ${title}
    sleep  2
    input text     css=.qa_multilot_descr                       ${description}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    sleep  2
    input text      css=.qa_multilot_end_period_adjustments     ${tender_end}
    sleep  2
    # заполняем лот
    input text  css=.qa_multilot_tender_lot_name                ${lots_title}
    sleep  1
    input text  css=.qa_multilot_tender_lot_descr               ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet              ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate       ${lots_minimalstep}

    #############################Добавление features(Нецінові критерії)#######################################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}
    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Нецінові критерії
    [Arguments]   ${features}
    ${number_of_features}=      Get Length                  ${features}
    set global variable                                     ${number_of_features}
    :FOR  ${index}  IN RANGE  ${number_of_features}
    \  Додати нецінові критерії    ${features[${index}]}    ${procurement_method_type}

Створити negotiation
    [Arguments]    ${username}    ${tender_data}    ${plan_id}
    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${title_ru}=                        Get From Dictionary         ${tender_data.data}                                         title_ru
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${description_ru}=                  Get From Dictionary         ${tender_data.data}                                         description_ru
    ${cause}=                           Get From Dictionary         ${tender_data.data}                                         cause
    ${cause}=                           convert_negotiation_cause_type      ${cause}
    ${cause_description}=               Get From Dictionary         ${tender_data.data}                                         causeDescription
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${value_amount}=                    Convert To String           ${value_amount}
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    ${email}=                           Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${telephone}=                       Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${contact_name}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            name

    ${identifier_id}=                   Get From Dictionary         ${tender_data.data.procuringEntity.identifier}              id
    ${legal_name}=                      Get From Dictionary         ${tender_data.data.procuringEntity.identifier}              legalName
    ${zip_code}=                        Get From Dictionary         ${tender_data.data.procuringEntity.address}                 postalCode
    ${region}=                          Get From Dictionary         ${tender_data.data.procuringEntity.address}                 region
    ${locality}=                        Get From Dictionary         ${tender_data.data.procuringEntity.address}                 locality
    ${street_address}=                  Get From Dictionary         ${tender_data.data.procuringEntity.address}                 streetAddress

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones

    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Click Element    xpath=//span[text()='Переговорна процедура']
    SLEEP  2
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  2
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  2
    click element   css=.qa_drop_down_rationale
    sleep  1
    click element  xpath=//li[text()='${cause}']
    sleep  1
    input text    xpath=(//textarea[contains(@class, 'qa_textarea_rationale')])[1]    ${cause_description}
    sleep  1
    input text    css=.qa_input_name    ${title}
    sleep  1
    input text    css=.qa_textarea_description     ${description}
    capture page screenshot
    sleep  1
    input text  css=.qa_multilot_tender_lot_name     ${title}

    Run Keyword If  '${tax}' == 'True'       click element   xpath=(//input[contains(@class, 'qa_checkbox_pdv')])[1]
    sleep  1
    input text   css=.qa_multilot_tender_lot_bugdet     ${value_amount}

    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}

    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

    sleep  1

    ################## Інформація про учасника переговорів #########################

    input text  css=.qa_input_winner_srn   ${identifier_id}
    sleep  1
    input text  css=.qa_input_winner_company_name   ${legal_name}
    sleep  1
    input text  css=.qa_input_winner_zip   ${zip_code}
    sleep  1
    click element  css=.qa_drop_down_winner_region
    ${region}=   Run Keyword If   '${region}'      convert_delivery_address     ${region}
    Click Element   xpath=(//li[contains(text(), '${region}')])[last()]
    sleep  1
    input text  css=.qa_input_winner_locality   ${locality}
    sleep  1
    input text  css=.qa_winner_address   ${street_address}
    sleep  1
    click element  css=.qa_checkbox_data_verified
    sleep  1
    input text  css=.qa_winner_amount   ${value_amount}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  xpath=(//input[contains(@class, 'qa_checkbox_pdv')])[2]
    sleep  1
    input text  css=.qa_winner_name   ${contact_name}
    sleep  1
    input text  css=.qa_winner_phone  ${telephone}
    sleep  1
    click element  css=.qa_qualification
    sleep  1
    capture page screenshot

Створити reporting
    [Arguments]    ${username}    ${tender_data}    ${plan_id}
    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${title_ru}=                        Get From Dictionary         ${tender_data.data}                                         title_ru
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${description_ru}=                  Get From Dictionary         ${tender_data.data}                                         description_ru
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${value_amount}=                    Convert To String           ${value_amount}
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    ${email}=                           Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${telephone}=                       Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${contact_name}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            name

    ${identifier_id}=                   Get From Dictionary         ${tender_data.data.procuringEntity.identifier}              id
    ${legal_name}=                      Get From Dictionary         ${tender_data.data.procuringEntity.identifier}              legalName
    ${zip_code}=                        Get From Dictionary         ${tender_data.data.procuringEntity.address}                 postalCode
    ${region}=                          Get From Dictionary         ${tender_data.data.procuringEntity.address}                 region
    ${locality}=                        Get From Dictionary         ${tender_data.data.procuringEntity.address}                 locality
    ${street_address}=                  Get From Dictionary         ${tender_data.data.procuringEntity.address}                 streetAddress

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones

    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Click Element    xpath=//span[text()='Звіт про укладений договір']
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  2
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  2
    input text    css=.qa_input_name    ${title}
    sleep  1
    input text    css=.qa_textarea_description     ${description}
    capture page screenshot
    sleep  1
    log to console  --0-0-0-0-0-0-0-=-0=-09-898098
    log to console   ${tax}
    log to console  --0-0-0-0-0-0-0-=-0=-09-898098

    input text   css=.qa_input_cost     ${value_amount}
    sleep  1
    Run Keyword If  '${tax}' == 'True'     click element   xpath=(//input[contains(@class, 'qa_checkbox_pdv')])[1]

    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}     ${number_of_milestones}

    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

    sleep  1

    ################## Інформація про учасника переговорів #########################

    input text  css=.qa_input_winner_srn   ${identifier_id}
    sleep  1
    input text  css=.qa_input_winner_company_name   ${legal_name}
    sleep  1
    input text  css=.qa_input_winner_zip   ${zip_code}
    sleep  1
    click element  css=.qa_drop_down_winner_region
    ${region}=   Run Keyword If   '${region}'      convert_delivery_address     ${region}
    Click Element   xpath=(//li[contains(text(), '${region}')])[last()]
    sleep  1
    input text  css=.qa_input_winner_locality   ${locality}
    sleep  1
    input text  css=.qa_winner_address   ${street_address}
    sleep  1
    click element  css=.qa_checkbox_data_verified
    sleep  1
    input text  css=.qa_winner_amount   ${value_amount}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  xpath=(//input[contains(@class, 'qa_checkbox_pdv')])[2]
    sleep  1
    input text  css=.qa_winner_name   ${contact_name}
    sleep  1
    input text  css=.qa_winner_phone  ${telephone}
    sleep  1
    capture page screenshot

Створити belowThreshold
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    log to console  .
    log to console  ${tender_data}
    log to console  Створити belowThreshold
    log to console  ${plan_id}
    log to console  ---------------------

    ${KeyIslot}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data.lots[0]}            title
    Set Global Variable      ${KeyIslot}
    Run Keyword If     ${KeyIslot}                      Створити belowThreshold multi       ${username}     ${tender_data}     ${plan_id}
    Run Keyword If     '${KeyIslot}' == 'False'         Створити belowThreshold single      ${username}     ${tender_data}     ${plan_id}

Створити belowThreshold multi
    [Arguments]   ${username}     ${tender_data}     ${plan_id}

    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}

    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${enquiry_end}                      Get From Dictionary         ${tender_data.data.enquiryPeriod}                           endDate
    ${enquiry_end}                      convert_iso_date_to_prom    ${enquiry_end}
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2
    Click Element    xpath=(//span[text()='Допорогова закупівля'])[last()]
    sleep  2
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    # заполняем тендер
    input text     css=.qa_multilot_title                       ${title}
    sleep  2
    input text     css=.qa_multilot_descr                       ${description}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    sleep  1
    input text      css=.qa_multilot_end_period_adjustments     ${enquiry_end}
    sleep  2
    input text      css=.qa_multilot_end_proposals              ${tender_end}
    sleep  2
    # заполняем лот
    input text  css=.qa_multilot_tender_lot_name                ${lots_title}
    sleep  1
    input text  css=.qa_multilot_tender_lot_descr               ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet              ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate       ${lots_minimalstep}

    ################Добавление milestones(Додати умови оплати)##################
    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}
    sleep  2

    #############################Добавление Items###############################
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити belowThreshold single
    [Arguments]   ${username}     ${tender_data}     ${plan_id}

    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${value_amount}=                    convert to string           ${value_amount}
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded

    ${step_amount}=                     Get From Dictionary         ${tender_data.data.minimalStep}                             amount
    ${step_amount}=                     convert to string           ${step_amount}
    ${min_tax}=                         Get From Dictionary         ${tender_data.data.minimalStep}                             valueAddedTaxIncluded

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${enquiry_end}                      Get From Dictionary         ${tender_data.data.enquiryPeriod}                           endDate
    ${enquiry_end}                      convert_iso_date_to_prom    ${enquiry_end}
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${tender_str}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            startDate
    ${tender_str}                       convert_iso_date_to_prom    ${tender_str}

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Click Element    xpath=(//span[text()='Допорогова закупівля'])[last()]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    # заполняем тендер
    input text     css=.qa_multilot_title                       ${title}
    sleep  2
    input text     css=.qa_multilot_descr                       ${description}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    sleep  1
    input text   css=#qa_currency_input         ${value_amount}
    sleep  2
    input text   css=.qa_singlelot_tender_step_auction_rate        ${step_amount}

    input text      css=.qa_singlelot_end_period_adjustments     ${enquiry_end}
    sleep  2
    click element   css=.qa_singlelot_end_period_adjustments
    sleep  1
    input text      css=.qa_multilot_start_proposals            ${tender_str}
    click element       css=.qa_multilot_start_proposals
    sleep  1
    input text      css=.qa_multilot_end_proposals              ${tender_end}
    click element      css=.qa_multilot_end_proposals
    sleep  2

    ################Добавление milestones(Додати умови оплати)##################
    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}
    sleep  2


    #############################Добавление Items###############################
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити aboveThresholdUA.defense
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    ${mainprocurementcategory}=         Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}
    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdUA.defense'       Click Element    xpath=(//span[text()='Переговорна процедура для потреб оборони'])[last()]
    sleep  4
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

 #######################заповнюємо контактні дані###############################
    click element  xpath=//div[contains(@class, 'qa_contact_lis')]//div[contains(@class, 'qa_language')]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     css=.qa_contact_name             ${test_name}
    sleep  1
    input text  css=.qa_name_in_en                  ${test_name}
    sleep  1
    Clear Element Text  css=.qa_phone_in_en
    input text  css=.qa_phone_in_en                 ${telephone_en}
    sleep  1
    input text  css=.qa_email_in_en                 ${email_en}

    ######################заповнюємо тендер#####################################
    input text     css=.qa_tender_title                                                     ${title}
    sleep  2
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_title')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_title undefined')]          ${title_en}
    sleep  1
    input text     css=.qa_tender_description                                               ${description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_description')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_description undefined')]    ${description_en}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    SLEEP  1
    input text     css=.qa_multilot_end_period_adjustments                                  ${tender_end}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    ############################заповнюємо лот##################################
    input text  css=.qa_lot_title                                                           ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_title')])[last()]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]                ${lots_title}
    sleep  2
    input text  css=.qa_lot_description                                                     ${lots_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_description')])[last()]
    sleep  1
    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]          ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet                                          ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate                                   ${lots_minimalstep}

    #####################Добавление features(Нецінові критерії)#################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    ################Добавление milestones(Додати умови оплати)##################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати     ${milestones[${index}]}    ${number_of_milestones}
    sleep  2

    #############################Добавление Items###############################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити competitiveDialogueUA
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    ${mainprocurementcategory}=         Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}
    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'competitiveDialogueUA'       Click Element    xpath=(//span[text()='Конкурентний діалог'])[last()]
    sleep  4
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    ######################заповнюємо тендер#####################################
    input text     css=.qa_multilot_title                                               ${title}
    sleep  1
    input text     css=.qa_multilot_descr                                               ${description}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    sleep  1
    input text     css=.qa_multilot_end_period_adjustments                              ${tender_end}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    ############################заповнюємо лот##################################
    input text  css=.qa_multilot_tender_lot_name                                        ${lots_title}
    sleep  1
    input text  css=.qa_multilot_tender_lot_descr                                       ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet                                      ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate                               ${lots_minimalstep}

    #####################Добавление features(Нецінові критерії)#################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    ################Добавление milestones(Додати умови оплати)##################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}   ${number_of_milestones}
    sleep  2

    #############################Добавление Items###############################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити competitiveDialogueEU
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    log to console  Створити competitiveDialogueEU
    log to console  ${tender_data}
    log to console  ${plan_id}
    log to console  ---------------------
    ${mainprocurementcategory}=         Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}
    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'competitiveDialogueEU'       Click Element    xpath=(//span[text()='Конкурентний діалог з публікацією англійською мовою'])[last()]
    sleep  4
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

 #######################заповнюємо контактні дані###############################
    click element  xpath=//div[contains(@class, 'qa_contact_lis')]//div[contains(@class, 'qa_language')]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     css=.qa_contact_name             ${test_name}
    sleep  1
    input text  css=.qa_name_in_en                  ${test_name}
    sleep  1
    Clear Element Text  css=.qa_phone_in_en
    input text  css=.qa_phone_in_en                 ${telephone_en}
    sleep  1
    input text  css=.qa_email_in_en                 ${email_en}

    ######################заповнюємо тендер#####################################
    input text     css=.qa_tender_title                                                     ${title}
    sleep  2
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_title')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_title undefined')]          ${title_en}
    sleep  1
    input text     css=.qa_tender_description                                               ${description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_description')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_description undefined')]    ${description_en}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  css=.qa_multilot_tax_included
    sleep  1
    input text     css=.qa_multilot_end_period_adjustments                                  ${tender_end}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    ############################заповнюємо лот##################################
    input text  css=.qa_lot_title                                                           ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_title')])[last()]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]                ${lots_title}
    sleep  2
    input text  css=.qa_lot_description                                                     ${lots_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_description')])[last()]
    sleep  1
    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]          ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet                                          ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate                                   ${lots_minimalstep}

    #####################Добавление features(Нецінові критерії)#################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    ################Добавление milestones(Додати умови оплати)##################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}
    sleep  2

    #############################Добавление Items###############################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити esco
    [Arguments]   ${username}     ${tender_data}     ${plan_id}
    log to console  ${tender_data}
    log to console  ${plan_id}
    log to console  ---------------------
    ${mainprocurementcategory}=         Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${mbudiscountrate}=                 Get From Dictionary         ${tender_data.data}                                         NBUdiscountRate
    ${fundingkind}=                     Get From Dictionary         ${tender_data.data}                                         fundingKind
    ${minimalsteppercentage}=           Get From Dictionary         ${tender_data.data.lots[0]}                                 minimalStepPercentage
    ${yearlyPaymentsPercentageRange}=   Get From Dictionary         ${tender_data.data.lots[0]}                                 yearlyPaymentsPercentageRange

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'esco'   Click Element    xpath=(//span[text()='Публічні закупівлі енергосервісу'])[last()]
    sleep  4
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

 #######################заповнюємо контактні дані###############################
    click element  xpath=//div[contains(@class, 'qa_contact_lis')]//div[contains(@class, 'qa_language')]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     css=.qa_contact_name             ${test_name}
    sleep  1
    input text  css=.qa_name_in_en                  ${test_name}
    sleep  1
    Clear Element Text  css=.qa_phone_in_en
    input text  css=.qa_phone_in_en                 ${telephone_en}
    sleep  1
    input text  css=.qa_email_in_en                 ${email_en}

    ######################заповнюємо тендер#####################################
    input text      css=.qa_tender_title                                                        ${title}
    sleep  2
    click element   xpath=(//div[contains(@class, 'qa_language_qa_tender_title')])[last()]
    sleep  3
    input text      xpath=//textarea[contains(@class, 'qa_tender_title undefined')]             ${title_en}
    sleep  1
    input text      css=.qa_tender_description                                                  ${description}
    sleep  1
    click element   xpath=(//div[contains(@class, 'qa_language_qa_tender_description')])[last()]
    sleep  3
    input text      xpath=//textarea[contains(@class, 'qa_tender_description undefined')]       ${description_en}
    sleep  1
    ${nbudiscountrate}=       convert_esco_data     ${mbudiscountrate}
    ${nbu}=       convert to string     ${nbudiscountrate}
    input text      css=.qa_singlelot_tender_nbu_discount_rate                                  ${nbu}
    sleep  1
    click element   css=.qa_singlelot_tender_funding_kind
    sleep  1
    Run Keyword If  '${fundingkind}' == 'budget'   click element   xpath=//li[text()= 'фінансування з бюджетних коштів']
    ...  ELSE    click element   xpath=//li[text()= 'фінансування виключно за рахунок Учасника']
    sleep  2
    input text      css=.qa_multilot_end_period_adjustments                                     ${tender_end}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    #####################Добавление features(Нецінові критерії)#################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    ############################заповнюємо лот##################################
    input text  css=.qa_lot_title                                                               ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_title')])[last()]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]                    ${lots_title}
    sleep  2
    input text  css=.qa_lot_description                                                         ${lots_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_description')])[last()]
    sleep  1
    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]              ${lots_description}
    sleep  1
    ${minimalsteppercentage}=      convert_esco_data      ${minimalsteppercentage}
    ${steppercentage}=      convert to string      ${minimalsteppercentage}
    input text   css=.qa_singlelot_tender_minimal_step_percentage                               ${steppercentage}
    sleep  1
    ${yearlyPaymentsPercentageRange}=      convert_esco_data   ${yearlyPaymentsPercentageRange}
    ${yearlyPayments}=      convert to string   ${yearlyPaymentsPercentageRange}
    input text     css=.qa_singlelot_tender_yearly_payments_percentage_range                    ${yearlyPayments}
    click element   css=.qa_delete_link_milestone
    sleep  2

    #############################Добавление Items###############################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера еско   ${items[${index}]}   ${tender_data}

Створити closeFrameworkAgreementUA
    [Arguments]    ${username}     ${tender_data}     ${plan_id}
    log to console   ${tender_data}

    ${mainprocurementcategory}=         Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_en}=                        Get From Dictionary         ${tender_data.data}                                         title_en
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}
    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones
    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items
    ${tender_end}                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${tender_end}                       convert_iso_date_to_prom    ${tender_end}
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${maxawardscount}=                  Get From Dictionary         ${tender_data.data}                                         maxAwardsCount
    ${agreementduration}=               Get From Dictionary         ${tender_data.data}                                         agreementDuration

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2
    Click Element    xpath=(//span[text()='Укладення рамкової угоди'])[last()]
    sleep  4
    click element  xpath=(//input[@type='checkbox'])[1]
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}
    sleep  1
    click element  css=.qa_procurement_category_choices
    sleep  2
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

 #######################заповнюємо контактні дані###############################
    click element  xpath=//div[contains(@class, 'qa_contact_lis')]//div[contains(@class, 'qa_language')]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     css=.qa_contact_name             ${test_name}
    sleep  1
    input text  css=.qa_name_in_en                  ${test_name}
    sleep  1
    Clear Element Text  css=.qa_phone_in_en
    input text  css=.qa_phone_in_en                 ${telephone_en}
    sleep  1
    input text  css=.qa_email_in_en                 ${email_en}

    ######################заповнюємо тендер#####################################
    input text     css=.qa_tender_title                                                     ${title}
    sleep  2
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_title')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_title undefined')]          ${title_en}
    sleep  1
    input text     css=.qa_tender_description                                               ${description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_tender_description')])[last()]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_description undefined')]    ${description_en}
    sleep  3
    Run Keyword If  '${tax}' != 'True'   click element  css=.qa_multilot_tax_included
    SLEEP  1
    input text     css=.qa_multilot_end_period_adjustments                                  ${tender_end}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2
    input text      css=.qa_multilot_term_agreement                                          '44'
    sleep  1
    input text      css=.qa_multilot_participants_agreement                                 ${maxawardscount}
    sleep  1
    ############################заповнюємо лот##################################
    input text  css=.qa_lot_title                                                           ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_title')])[last()]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]                ${lots_title}
    sleep  2
    input text  css=.qa_lot_description                                                     ${lots_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_lot_description')])[last()]
    sleep  1
    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]          ${lots_description}
    sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet                                          ${lots_amount}
    sleep  1
    input text  css=.qa_multilot_tender_step_auction_rate                                   ${lots_minimalstep}

    #####################Добавление features(Нецінові критерії)#################

    ${KeyIsfeatures}=    Run Keyword And Return Status          Dictionary Should Contain Key           ${tender_data.data}            features
    ${features}=   Run Keyword If    ${KeyIsfeatures}           Get From Dictionary                     ${tender_data.data}            features
    Run Keyword If   '${KeyIsfeatures}' == 'True'               Нецінові критерії                       ${features}

    ################Добавление milestones(Додати умови оплати)##################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати     ${milestones[${index}]}    ${number_of_milestones}
    sleep  2

    #############################Добавление Items###############################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}   ${tender_data}

Створити план closeFrameworkAgreementUA
    [Arguments]  ${username}    ${plan_data}    ${procurement_method_type}
    ${description}=                     Get From Dictionary                             ${plan_data.data.budget}                        description
    ${amount}=                          Get From Dictionary                             ${plan_data.data.budget}                        amount
    ${classification}=                  Get From Dictionary                             ${plan_data.data.classification}                id
    ${startDate}=                       Get From Dictionary                             ${plan_data.data.tender.tenderPeriod}           startDate
    ${period_startDate}                 Get From Dictionary                             ${plan_data.data.budget.period}                 startDate
    ${period_startDate}                 convert_period_to_closeframeworkagreement       ${period_startDate}
    ${period_endDate}                   Get From Dictionary                             ${plan_data.data.budget.period}                 endDate
    ${period_endDate}                   convert_period_to_closeframeworkagreement       ${period_endDate}
    ${startDate}=                       convert_iso_date_to_prom_without_time           ${startDate}

    log to console   ${plan_data}
    Click Element    xpath=(//li[@data-value="closeFrameworkAgreementUA"])[last()]
    SLEEP  1
    input text          css=[id="year_from"]                   ${period_startDate}
    sleep  1
    input text          css=[id="year_to"]                     ${period_endDate}
    sleep  1
    Input Text          css=[id="description"]                 ${description}
    sleep  1
    ${amount}=          Convert To String                      ${amount}
    Input Text          css=[id="amount"]                      ${amount}
    sleep  1
    Click Element       css=div[data-classifier-form-input-name*='primary_classifier_id'] a
    sleep  1
    input text          css=.qa_search_input                   ${classification}
    sleep  1
    Click Element       css=[class="b-checkbox__input"]
    sleep  2
    Click Element       css=.qa_submit
    sleep  1
    Click Element       xpath=(//a[contains(@data-url, '/add_item')])[last()]
    sleep  1

    #Добавление айтемов их обычно 2
    ${items}=   Get From Dictionary    ${plan_data.data}    items
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@data-url, '/add_item')])[last()]
    \  Додати айтем плана    ${items[${index}]}

    Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    sleep  1

    #Добавление Джерала их обычно 3
    ${breakdowns}=                Get From Dictionary             ${plan_data.data.budget}     breakdown
    ${number_of_breakdowns}=  Get Length  ${breakdowns}
    set global variable    ${number_of_breakdowns}
    :FOR  ${index}  IN RANGE  ${number_of_breakdowns}
    \  Run Keyword If  '${index}' != '0'   Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    \  Додати джерело плана    ${breakdowns[${index}]}
    SLEEP  1

Додати айтем тендера еско
    [Arguments]   ${items}   ${tender_data}
    ${procurement_method_type}=                 Get From Dictionary                         ${tender_data.data}               procurementMethodType

    ${item_classification_description}=         Get From Dictionary                         ${items.classification}           description
    ${item_classification_id}=                  Get From Dictionary                         ${items.classification}           id
    ${item_classification_scheme}=              Get From Dictionary                         ${items.classification}           scheme
    ${delivery_country}=                        Get From Dictionary                         ${items.deliveryAddress}          countryName
    ${delivery_country_en}=                     Get From Dictionary                         ${items.deliveryAddress}          countryName_en
    ${delivery_country_ru}=                     Get From Dictionary                         ${items.deliveryAddress}          countryName_ru
    ${delivery_locality}=                       Get From Dictionary                         ${items.deliveryAddress}          locality
    ${delivery_postalCode}=                     Get From Dictionary                         ${items.deliveryAddress}          postalCode
    ${delivery_region}=                         Get From Dictionary                         ${items.deliveryAddress}          region
    ${delivery_street}=                         Get From Dictionary                         ${items.deliveryAddress}          streetAddress
    ${item_description}=                        Get From Dictionary                         ${items}                          description
    ${item_description_en}=                     Get From Dictionary                         ${items}                          description_en
    ${item_description_ru}=                     Get From Dictionary                         ${items}                          description_ru

    input text    xpath=(//textarea[contains(@class, 'qa_item_description')])[last()]               ${item_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language_qa_item_description')])[last()]
    sleep   1
    input text    xpath=(//textarea[contains(@class, 'qa_item_description undefined')])[last()]     ${item_description_en}
    sleep  1
    click element   xpath=(//a[contains(@class, 'qa_multilot_tender_dk_classifier')])[last()]
    sleep  1
    input text      css=.qa_classifier_popup .qa_search_input                                       ${item_classification_id}
    sleep  1
    click element   css=.qa_classifier_popup [type="checkbox"]
    sleep  1
    CLICK ELEMENT   css=.qa_classifier_popup .qa_submit span
    sleep  2
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_address')])[last()]         ${delivery_street}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_locality')])[last()]        ${delivery_locality}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_zip_code')])[last()]        ${delivery_postalCode}
    sleep  1
    click element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]
    sleep  1
    ${delivery_region}=   Run Keyword If   '${delivery_region}'      convert_delivery_address     ${delivery_region}
    Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]//li[contains(text(), '${delivery_region}')]

Створити план esco
    [Arguments]    ${username}    ${plan_data}
    log to console  ${plan_data}
    ${description}=                     Get From Dictionary             ${plan_data.data.budget}                description
    ${classification}=                  Get From Dictionary             ${plan_data.data.classification}        id

    Click Element    xpath=(//li[@data-value="esco"])[last()]
    sleep  4
    Input Text          css=[id="description"]                 ${description}
    Click Element       css=div[data-classifier-form-input-name*='primary_classifier_id'] a
    sleep  1
    input text          css=.qa_search_input                   ${classification}
    sleep  1
    Click Element       css=[class="b-checkbox__input"]
    sleep  2
    Click Element       css=.qa_submit
    sleep  1
    Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    sleep  1
    Click Element       xpath=(//a[contains(@data-url, '/add_esco_item')])[last()]
    sleep  1

    #Добавление айтемов их обычно 2
    ${items}=   Get From Dictionary    ${plan_data.data}    items
    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@data-url, '/add_esco_item')])[last()]
    \  Додати айтем плана еско    ${items[${index}]}

    #Добавление Джерала их обычно 3
    ${breakdowns}=                Get From Dictionary             ${plan_data.data.budget}     breakdown
    ${number_of_breakdowns}=  Get Length  ${breakdowns}
    set global variable    ${number_of_breakdowns}
    :FOR  ${index}  IN RANGE  ${number_of_breakdowns}
    \  Run Keyword If  '${index}' != '0'   Click Element    xpath=(//span[contains(text(), 'Додати джерело')])[last()]
    \  Додати джерело плана    ${breakdowns[${index}]}

Додати айтем плана еско
    [Arguments]   ${items}
    ${item_classification_description}=                 Get From Dictionary             ${items.classification}             description
    ${item_classification_id}=                          Get From Dictionary             ${items.classification}             id
    ${item_classification_scheme}=                      Get From Dictionary             ${items.classification}             scheme
    ${item_description}=                                Get From Dictionary             ${items}                            description
    capture page screenshot
    #Заполнение тела айтема
    sleep  1
    Input Text    xpath=(//input[contains(@id, 'descr')])[last()]    ${item_description}
    sleep  1
    Click Element     xpath=(//div[@data-classifier-code="dk021"]//span)[last()]
    sleep  1
    input text  css=.qa_search_input                        ${item_classification_id}
    sleep  1
    Click Element  css=[class="b-checkbox__input"]
    sleep  2
    Click Element  css=.qa_submit
    sleep  1

Створити тендер для типу закупівлі
    [Arguments]    ${username}    ${tender_data}    ${plan_id}
    log to console  ---------------------
    log to console  ${plan_id}
    log to console  ---------------------
    ${mainprocurementcategory}          Get From Dictionary         ${tender_data.data}                                         mainProcurementCategory
    ${title}=                           Get From Dictionary         ${tender_data.data}                                         title
    ${title_ru}=                        Get From Dictionary         ${tender_data.data}                                         title_ru
    ${description}=                     Get From Dictionary         ${tender_data.data}                                         description
    ${description_en}=                  Get From Dictionary         ${tender_data.data}                                         description_en
    ${description_ru}=                  Get From Dictionary         ${tender_data.data}                                         description_ru
    ${value_amount}=                    Get From Dictionary         ${tender_data.data.value}                                   amount
    ${currency}=                        Get From Dictionary         ${tender_data.data.value}                                   currency
    ${tax}=                             Get From Dictionary         ${tender_data.data.value}                                   valueAddedTaxIncluded
    ${endDate}=                         Get From Dictionary         ${tender_data.data.tenderPeriod}                            endDate
    ${endDate}=                         convert_iso_date_to_prom      ${endDate}
    ${startDate}=                       Get From Dictionary         ${tender_data.data.tenderPeriod}                            startDate
    ${procurement_method_type}=         Get From Dictionary         ${tender_data.data}                                         procurementMethodType
    ${email_en}=                        Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            email
    ${telephone_en}=                    Get From Dictionary         ${tender_data.data.procuringEntity.contactPoint}            telephone

    ${lots_title}=                      Get From Dictionary         ${tender_data.data.lots[0]}                                 title
    ${lots_title_ru}=                   Get From Dictionary         ${tender_data.data.lots[0]}                                 title_ru
    ${lots_description}=                Get From Dictionary         ${tender_data.data.lots[0]}                                 description
    ${lots_amount}=                     Get From Dictionary         ${tender_data.data.lots[0].value}                           amount
    ${lots_amount}=                     Convert To String           ${lots_amount}
    ${lots_minimalStep}=                Get From Dictionary         ${tender_data.data.lots[0].minimalStep}                     amount
    ${lots_minimalstep}=                Convert To String           ${lots_minimalstep}

    ${features}                         Get From Dictionary         ${tender_data.data}                                         features

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones

    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items

    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdUA'              Click Element    xpath=//span[text()='Відкриті торги']
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                Click Element    xpath=//span[text()='Допорогова закупівля']
    ...      ELSE IF        '${procurement_method_type}' == 'reporting'                     Click Element    xpath=//span[text()='Звіт про укладений договір']
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation'                   Click Element    xpath=//span[text()='Переговорна процедура']
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation_quick'             Click Element    xpath=//span[text()='Переговорна процедура, скорочена']
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueUA'         Click Element    xpath=//span[text()='Конкурентний діалог']
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueEU'         Click Element    xpath=//span[text()='Конкурентний діалог з публікацією англійською мовою']
    ...      ELSE IF        '${procurement_method_type}' == 'closeFrameworkAgreementUA'     Click Element    xpath=//span[text()='Конкурентний діалог з публікацією англійською мовою']
    ...      ELSE IF        '${procurement_method_type}' == 'centralizedProcurement'        Click Element    xpath=//span[text()='Укладення рамкової угоди']

    SLEEP  2
    click element  xpath=//input[@type='checkbox']
    sleep  2
    click element  css=.qa_procurement_category_choices
    sleep  2
    input text   css=.qa_plan_tuid    ${plan_id}

    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    sleep  3

    #################Інформація про закупівлю на разных языках #############################

    input text     css=.qa_multilot_title       ${title}
    sleep  2
    input text     css=.qa_multilot_descr       ${description}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   select checkbox  css=.qa_multilot_tax_included

    input text     css=.qa_multilot_end_period_adjustments       ${endDate}
    sleep  2
    click element   css=.qa_multilot_end_period_adjustments
    sleep  2

    #############################Добавление features(Нецінові критерії)#####################

    ${number_of_features}=      Get Length                        ${features}
    set global variable                                           ${number_of_features}
    :FOR  ${index}  IN RANGE  ${number_of_features}
    \  Додати нецінові критерії    ${features[${index}]}    ${procurement_method_type}


    #############################Добавление лота#######################################

    input text  css=.qa_multilot_tender_lot_name                                    ${lots_title}
    sleep  1
    input text  css=.qa_multilot_tender_lot_descr   ${lots_description}
    Sleep  1
    input text  css=.qa_multilot_tender_lot_bugdet        ${lots_amount}
    input text  css=.qa_multilot_tender_step_auction_rate            ${lots_minimalstep}

    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}    ${number_of_milestones}

    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}    ${tender_data}

Додати нецінові критерії
    [Arguments]   ${features}  ${procurement_method_type}

    ${code}=                    Get From Dictionary    ${features}                code
    ${description}=             Get From Dictionary    ${features}                description
    ${title}=                   Get From Dictionary    ${features}                title
    ${title_en}=                Get From Dictionary    ${features}                title_en
    ${title_ru}=                Get From Dictionary    ${features}                title_ru
    ${featureOf}=               Get From Dictionary    ${features}                featureOf

    ${enum}=                    Get From Dictionary    ${features}                enum
    sleep  2
    Click Element     xpath=(//div[@class='qa_all_block']//a[contains(@class, 'qa_multilot_add_one_more_feature')])[last()]
    capture page screenshot
    sleep  4
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']    Wait Until Page Contains Element    xpath=(//input[contains(@class, 'qa_feature_title ')])[last()]
    ...  ELSE     Wait Until Page Contains Element     xpath=(//input[contains(@class, 'qa_multilot_feature_input_name')])[last()]
    sleep  1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   input text    xpath=(//input[contains(@class, 'qa_feature_title ')])[last()]  ${title}
    ...  ELSE    input text    xpath=(//input[contains(@class, 'qa_multilot_feature_input_name')])[last()]   ${title}
    sleep   1
    capture page screenshot
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  sleep   2
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  click element    xpath=(//div[contains(@class, 'qa_language_qa_feature_title')])[last()]
    capture page screenshot
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  sleep   2
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  input text    xpath=(//input[contains(@class, 'qa_feature_title ')])[last()]  ${title_en}
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  sleep   2
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  input text    xpath=(//textarea[contains(@class, 'qa_feature_description ')])[last()]   ${description}
    ...  ELSE   input text    xpath=(//input[contains(@class, 'qa_multilot_feature_input_hint')])[last()]   ${description}
    sleep   1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   click element    xpath=(//div[contains(@class, 'qa_language_qa_feature_description')])[last()]
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   input text    xpath=(//textarea[contains(@class, 'qa_feature_description ')])[last()]   ${description}
    sleep  4
    capture page screenshot
    #############################Добавление features(вагу нецінового критерія)#######################################

    ${number_of_enum}=              Get Length                      ${enum}
    set global variable                                             ${number_of_enum}
    :FOR  ${index}  IN RANGE  ${number_of_enum}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_multilot_add_options')])[last()]
    \  Додаты вагу нецінового критерія    ${enum[${index}]}    ${procurement_method_type}

Додаты вагу нецінового критерія
    [Arguments]   ${enum}   ${procurement_method_type}

    log to console  -+_+_+_+_+_
    log to console  ${procurement_method_type}
    log to console  -+_+_+_+_+_

    ${title}=                    Get From Dictionary    ${enum}                title
    ${value}=                    Get From Dictionary    ${enum}                value

    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   input text    xpath=(//input[contains(@class, 'qa_option_title')])[last()]  ${title}
    ...  ELSE    input text  xpath=(//input[contains(@class, 'qa_multilot_option')])[last()]   ${title}
    sleep   1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   click element    xpath=(//div[contains(@class, 'qa_language_qa_option_title')])[last()]
    sleep   1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']   input text    xpath=(//input[contains(@class, 'qa_option_title')])[last()]  ${title}
    sleep   1
    ${value_input}=    covert_features    ${value}

    input text  xpath=(//input[contains(@class, 'qa_multilot_weight_options')])[last()]    ${value_input}
    sleep  2
    capture page screenshot

Додати умови оплати
    [Arguments]   ${milestones}    ${number_of_milestones}
    ${title}=           Get From Dictionary    ${milestones}                title
    ${code}=            Get From Dictionary    ${milestones}                code
    ${days}=            Get From Dictionary    ${milestones.duration}       days
    ${type}=            Get From Dictionary    ${milestones.duration}       type
    ${percentage}=      Get From Dictionary    ${milestones}                percentage

    ${KeyIsPresent}=    Run Keyword And Return Status       Dictionary Should Contain Key       ${milestones}      description
    ${description}=     Run Keyword If      ${KeyIsPresent}     Get From Dictionary             ${milestones}      description

    Click Element         xpath=(//div[contains(@class, 'qa_milestone_title')])[last()]
    sleep  2

    ${title}=   Run Keyword If   '${title}' == 'executionOfWorks'                   Click Element    xpath=(//li[text()="виконання робіт"])[last()]
    ...      ELSE IF             '${title}' == 'signingTheContract'                 Click Element    xpath=(//li[text()="підписання договору"])[last()]
    ...      ELSE IF             '${title}' == 'deliveryOfGoods'                    Click Element    xpath=(//li[text()="поставка товару"])[last()]
    ...      ELSE IF             '${title}' == 'endDateOfTheReportingPeriod'        Click Element    xpath=(//li[text()="дата закінчення звітного періоду"])[last()]
    ...      ELSE IF             '${title}' == 'submissionDateOfApplications'       Click Element    xpath=(//li[text()="дата подання заявки"])[last()]
    ...      ELSE IF             '${title}' == 'submittingServices'                 Click Element    xpath=(//li[text()="надання послуг"])[last()]
    ...      ELSE IF             '${title}' == 'dateOfInvoicing'                    Click Element    xpath=(//li[text()="дата виставлення рахунку"])[last()]
    ...      ELSE IF             '${title}' == 'anotherEvent'                       Click Element    xpath=(//li[text()="інша подія"])[last()]
    sleep  2
    click element   xpath=(//div[contains(@class, 'qa_milestone_code')])[last()]
    sleep  2
    ${code}=  Run Keyword If    '${code}' == 'postpayment'              Click Element    xpath=(//li[text()="післяоплата"])[last()]
    ...      ELSE IF            '${code}' == 'prepayment'               Click Element    xpath=(//li[text()="аванс"])[last()]
    sleep  2
    input text   xpath=(//input[contains(@class, 'qa_milestone_duration_days')])[last()]    ${days}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_milestone_duration_type')])[last()]
    sleep  2
    ${type}=  Run Keyword If   '${type}' == 'calendar'               Click Element    xpath=(//li[text()="календарні"])[last()]
    ...      ELSE IF           '${type}' == 'working'                Click Element    xpath=(//li[text()="робочі"])[last()]
    ...      ELSE IF           '${type}' == 'banking'                Click Element    xpath=(//li[text()="банківські"])[last()]
    sleep  1
    ${one}=    set variable   1
    RUN KEYWORD IF   '${number_of_milestones}' == '${one}'    input text  xpath=(//input[contains(@class, 'qa_milestone_percentage')])[last()]    100
    ...   ELSE    input text  xpath=(//input[contains(@class, 'qa_milestone_percentage')])[last()]    ${percentage}
    sleep  1
    Run Keyword If   "${description}" != "None"     input text    xpath=(//textarea[contains(@class, 'qa_milestone_description')])[last()]    ${description}

Додати айтем тендера
    [Arguments]   ${items}   ${tender_data}

    ${procurement_method_type}=                 Get From Dictionary                         ${tender_data.data}               procurementMethodType

    ${item_classification_description}=         Get From Dictionary                         ${items.classification}           description
    ${item_classification_id}=                  Get From Dictionary                         ${items.classification}           id
    ${item_classification_scheme}=              Get From Dictionary                         ${items.classification}           scheme
    ${delivery_country}=                        Get From Dictionary                         ${items.deliveryAddress}          countryName
    ${delivery_country_en}=                     Get From Dictionary                         ${items.deliveryAddress}          countryName_en
    ${delivery_country_ru}=                     Get From Dictionary                         ${items.deliveryAddress}          countryName_ru
    ${delivery_locality}=                       Get From Dictionary                         ${items.deliveryAddress}          locality
    ${delivery_postalCode}=                     Get From Dictionary                         ${items.deliveryAddress}          postalCode
    ${delivery_region}=                         Get From Dictionary                         ${items.deliveryAddress}          region
    ${delivery_street}=                         Get From Dictionary                         ${items.deliveryAddress}          streetAddress
    ${delivery_end}=                            Get From Dictionary                         ${items.deliveryDate}             endDate
    ${delivery_end}=                            convert_iso_date_to_prom_without_time_two   ${delivery_end}
    ${delivery_start}=                          Get From Dictionary                         ${items.deliveryDate}             startDate
    ${delivery_start}=                          convert_iso_date_to_prom_without_time_two   ${delivery_start}
    ${item_description}=                        Get From Dictionary                         ${items}                          description
    ${item_description_en}=                     Get From Dictionary                         ${items}                          description_en
    ${item_description_ru}=                     Get From Dictionary                         ${items}                          description_ru
    ${item_quantity}=                           Get From Dictionary                         ${items}                          quantity
    ${item_quantity}=                           Convert To String                           ${item_quantity}
    ${unit_code}=                               Get From Dictionary                         ${items.unit}                     code
    ${unit_name}=                               Get From Dictionary                         ${items.unit}                     name

    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']    input text    xpath=(//textarea[contains(@class, 'qa_item_description')])[last()]          ${item_description}
    ...      ELSE      input text    xpath=(//textarea[contains(@class, 'qa_multilot_tender_descr_product')])[last()]   ${item_description}
    sleep  1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  click element  xpath=(//div[contains(@class, 'qa_language_qa_item_description')])[last()]
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  sleep   1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'esco', 'closeFrameworkAgreementUA']  input text    xpath=(//textarea[contains(@class, 'qa_item_description undefined')])[last()]   ${item_description_en}
    sleep  1
    input text    xpath=(//input[contains(@class, 'qa_multilot_tender_quantity_product')])[last()]      ${item_quantity}
    sleep  1
    Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]
    sleep  2
    ${name}=   Run Keyword If   '${unit_name}' == 'штуки'            Click Element    xpath=(//li[text()='штуки'])[last()]
    ...      ELSE IF            '${unit_name}' == 'упаковка'         Click Element    xpath=(//li[text()='упаковка'])[last()]
    ...      ELSE IF            '${unit_name}' == 'кілограми'        Click Element    xpath=(//li[text()='кілограми'])[last()]
    ...      ELSE IF            '${unit_name}' == 'набір'            Click Element    xpath=(//li[text()='набір'])[last()]
    ...      ELSE IF            '${unit_name}' == 'лот'              Click Element    xpath=(//li[text()='лот'])[last()]
    ...      ELSE               '${unit_name}' == 'pct'              Click Element    xpath=(//li[text()='ампула'])[last()]
    sleep  1
    click element   xpath=(//a[contains(@class, 'qa_multilot_tender_dk_classifier')])[last()]
    sleep  1
    input text      css=.qa_classifier_popup .qa_search_input          ${item_classification_id}
    sleep  1
    click element   css=.qa_classifier_popup [type="checkbox"]
    sleep  1
    CLICK ELEMENT   css=.qa_classifier_popup .qa_submit span
    sleep  2
    input text     xpath=(//input[contains(@class, 'qa_multilot_tender_start_period_delivery')])[last()]    ${delivery_start}
    sleep  2
    click element    xpath=(//input[contains(@class, 'qa_multilot_tender_start_period_delivery')])[last()]
    sleep  2
    input text     xpath=(//input[contains(@class, 'qa_multilot_tender_end_period_delivery')])[last()]      ${delivery_end}
    sleep  2
    click element    xpath=(//input[contains(@class, 'qa_multilot_tender_end_period_delivery')])[last()]
    sleep  2
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_address')])[last()]         ${delivery_street}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_locality')])[last()]        ${delivery_locality}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_zip_code')])[last()]        ${delivery_postalCode}
    sleep  1
    click element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]
    sleep  1
    ${delivery_region}=   Run Keyword If   '${delivery_region}'      convert_delivery_address     ${delivery_region}
    Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]//li[contains(text(), '${delivery_region}')]
    sleep  1

Пошук тендера для провайдера
    [Arguments]    ${tender_uaid}
    Wait Until Page Contains Element      css=[data-qa="search_input"]
    Input Text         css=[data-qa="search_input"]   ${tender_uaid}
    Click Button    css=[data-qa="search_button"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  3
    Wait Until Element Is Visible       xpath=(//a[@data-qa="tender_title"])[1]
    Click Element     xpath=(//a[@data-qa="tender_title"])[1]
    sleep  1

Пошук тендера для Овнера
    [Arguments]    ${tender_uaid}
    Wait Until Page Contains Element      css=#search
    Input Text         css=#search   ${tender_uaid}
    Sleep  2
    Click Element     css=[type="submit"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    Wait Until Element Is Visible       xpath=(//tr[contains(@class, 'qa_purchase_result')]//div[contains(@class, 'qa_name')]//a)[1]
    Click Element     xpath=(//tr[contains(@class, 'qa_purchase_result')]//div[contains(@class, 'qa_name')]//a)[1]
    sleep   1

Пошук тендера по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    log to console  ${tender_uaid}
    log to console  --------------------------
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].default_page}
    sleep  2
    Run Keyword If   '${username}' == 'Prom_Provider'    prom.Пошук тендера для провайдера  ${tender_uaid}
    Run Keyword If   '${username}' == 'Prom_Provider1'   prom.Пошук тендера для провайдера  ${tender_uaid}

    Run Keyword If   '${username}' == 'Prom_Owner' or '${username}' == 'Prom_Viewer'    prom.Пошук тендера для Овнера    ${tender_uaid}

    log to console    ${tender_uaid}
    Sleep  2

Оновити сторінку з тендером
    [Arguments]    ${username}    ${tender_uaid}
    prom.Пошук тендера по ідентифікатору     ${username}    ${tender_uaid}

Отримати інформацію із плану
    [Arguments]      ${username}    ${tender_uaid}     ${field_name}

    ${return_value}=     Run Keyword If                 '${field_name}' == 'tender.procurementMethodType'             Get Text   css=.qa_procedure_type
    ...  ELSE IF    '${field_name}' == 'status'                                                         Get Text   css=[class="b-status"]
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.id'                                  Get Text   xpath=//span[@data-qa="qa_merch_EDRPOU_value"]
    ...  ELSE IF    '${field_name}' == 'procuringEntity.name'                                           Get Text   xpath=//span[@data-qa="qa_merch_name_value"]
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.legalName'                           Get Text   xpath=//span[@data-qa="qa_merch_name_value"]
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.scheme'                              set variable   UA-EDR
    ...  ELSE IF    '${field_name}' == 'budget.amount'                                                  get element attribute   xpath=//span[@class="qa_budget_amount"]@data-qa-amount
    ...  ELSE IF    '${field_name}' == 'budget.description'                                             Get Text   xpath=//span[@data-qa="state_plan_description"]
    ...  ELSE IF    '${field_name}' == 'budget.currency'                                                set variable   UAH
    ...  ELSE IF    '${field_name}' == 'classification.description'                                     get element attribute   xpath=//span[contains(@class, 'qa_code_dk')]@data-qa-name
    ...  ELSE IF    '${field_name}' == 'classification.scheme'                                          Get Text   css=.qa_classifier_dk
    ...  ELSE IF    '${field_name}' == 'classification.id'                                              get element attribute   xpath=//span[contains(@class, 'qa_code_dk')]@data-qa-code
    ...  ELSE IF    '${field_name}' == 'items[0].description'                                           Get Text   xpath=(//span[@data-qa="qa-state-pos-desc"])[1]
    ...  ELSE IF    '${field_name}' == 'items[0].quantity'                                              Get Text   xpath=(//span[@data-qa="qa-state-pos-quantity"])[1]
    ...  ELSE IF    '${field_name}' == 'items[0].unit.name'                                             Get Text   xpath=(//span[@data-qa="qa-state-pos-unit"])[1]
    ...  ELSE IF    '${field_name}' == 'items[0].classification.description'                            Get Text   css=.qa_classifier_descr_primary
    ...  ELSE IF    '${field_name}' == 'items[0].classification.scheme'                                 Get Text   css=.qa_classifier_dk
    ...  ELSE IF    '${field_name}' == 'items[0].classification.id'                                     Get Text   css=.qa_classifier_descr_code
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryDate.endDate'                                  get element attribute   xpath=//td[contains(@class, 'qa_delivery_date')]@data-qa-delivery

    ${return_value}=   Run Keyword If    '${field_name}' == 'status'        convert_plan_status                        ${return_value}
    ...  ELSE IF    '${field_name}' == 'tender.procurementMethodType'       convert_plan_status                        ${return_value}
    ...  ELSE IF    '${field_name}' == 'budget.amount'       convert to number                        ${return_value}
    ...  ELSE IF    '${field_name}' == 'items[0].quantity'       convert to number                    ${return_value.replace(',', '.')}
    ...   ELSE     convert_prom_string_to_common_string                                    ${return_value}

    [Return]  ${return_value}

Отримати інформацію із лота тендера
    [Arguments]      ${field_name}

    ${return_value}=    Run Keyword If   '${procurement_method_type}' == 'belowThreshold'       Отримати інформацію із лота тендер belowThreshold      ${field_name}
    ...  ELSE IF    '${procurement_method_type}' == 'negotiation'          Отримати інформацію із лота тендера negotiation        ${field_name}
    ...  ELSE IF    '${procurement_method_type}' == 'reporting'          Отримати інформацію із лота тендера negotiation        ${field_name}
    ...  ELSE    Отримати інформацію із лота тендера для остальных      ${field_name}
    [Return]  ${return_value}

Отримати інформацію із лота тендера для остальных
    [Arguments]      ${field_name}
    log to console  ***Отримати інформацію із лота тендера для остальных***
    sleep  1
    reload page
    Wait Until Element Is Visible    css=.qa_lot_button
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10

    ${return_value}=     Run Keyword If     '${field_name}' == 'milestones[0].code'             Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                                     Get Text   css=.qa_minimum_bid_increment
    ...  ELSE IF    '${field_name}' == 'qualifications[0].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'qualifications[1].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'awards[0].status'                                       Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'minimalStepPercentage'                                  Get Element Attribute   xpath=//span[contains(@class, 'qa_minimal_step')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'lots[0].minimalStepPercentage'                          Get Element Attribute   xpath=//span[contains(@class, 'qa_minimal_step')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                            Get Text   xpath=//span[contains(@class, 'qa_funding_kind')]
    ...  ELSE IF    '${field_name}' == 'lots[0].fundingKind'                                    Get Text   xpath=//span[contains(@class, 'qa_funding_kind')]
    ...  ELSE IF    '${field_name}' == 'lots[0].yearlyPaymentsPercentageRange'                  Get Element Attribute   xpath=//span[contains(@class, 'qa_financial_step')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'yearlyPaymentsPercentageRange'                          Get Element Attribute   xpath=//span[contains(@class, 'qa_financial_step')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'awards[0].complaintPeriod.endDate'                      Get Element Attribute   xpath=//div[contains(@class, 'qa_qualification_end_date')]@data-qualification-date-end
    ...  ELSE IF    '${field_name}' == 'awards[1].complaintPeriod.endDate'                      Get Element Attribute   xpath=//div[contains(@class, 'qa_qualification_end_date')]@data-qualification-date-end
    ...  ELSE IF    '${field_name}' == 'awards[2].complaintPeriod.endDate'                      Get Element Attribute   xpath=//div[contains(@class, 'qa_qualification_end_date')]@data-qualification-date-end
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amountNet'                           Get Element Attribute   xpath=//div[@data-qa="award_amount"]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amount'                              Get Element Attribute   xpath=(//div[@data-qa="award_amount"])[1]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[1].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amountNet'                           Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amount'                              Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'auctionPeriod.startDate'                                Get Element Attribute    xpath=//dd[contains(@class, 'qa_date_time_auction')]//span[@class="qa_date_time_start"]@data-period-date-start
    ...  ELSE IF    '${field_name}' == 'lots[0].title'                                          get text   xpath=//span[contains(@class, 'qa_lot_title')]

    sleep  2
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Отримати інформацію із лота тендера negotiation
    [Arguments]      ${field_name}
    log to console  ^^^$^$^$^^$^$^$$^
    log to console   ${field_name}
    log to console  ^^^$^$^$^^$^$^$$^
    sleep  30
    reload page
    ${return_value}=     Run Keyword If                 '${field_name}' == 'milestones[0].code'             Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                                     Get Text   css=.qa_minimum_bid_increment
    ...  ELSE IF    '${field_name}' == 'qualifications[0].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'qualifications[1].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'awards[0].status'                                       Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amountNet'                           Get Element Attribute   xpath=//div[@data-qa="award_amount"]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amount'                              Get Element Attribute   xpath=(//div[@data-qa="award_amount"])[1]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[1].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amountNet'                           Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amount'                              Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'auctionPeriod.startDate'                                Get Element Attribute    xpath=//dd[contains(@class, 'qa_date_time_auction')]//span[@class="qa_date_time_start"]@data-period-date-start
    ...  ELSE IF    '${field_name}' == 'lots[0].title'                                          get text   xpath=//span[contains(@class, 'qa_lot_title')]
    sleep  2
    [Return]  ${return_value}

Отримати інформацію із лота тендер belowThreshold
    [Arguments]      ${field_name}
    Run Keyword If  '${KeyIslot}' == 'True'     CLICK ELEMENT    css=.qa_lot_button
    Run Keyword If  '${KeyIslot}' == 'True'     Wait Until Element Is Visible   css=.qa_lot_title     10
    ${return_value}=     Run Keyword If                 '${field_name}' == 'milestones[0].code'             Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].code'                                     Get Text   xpath=(//span[contains(@class, 'qa_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].title'                                    Get Text   xpath=(//span[contains(@class, 'qa_payment_after_the_event')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].percentage'                               Get Text   xpath=(//span[contains(@class, 'qa_amount_of_payment')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.days'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_days')])[3]
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[1]
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[2]
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.type'                            Get Text   xpath=(//span[contains(@class, 'qa_period_of_payment_type')])[3]
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                                     Get Text   css=.qa_minimum_bid_increment
    ...  ELSE IF    '${field_name}' == 'qualifications[0].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'qualifications[1].status'                               Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'awards[0].status'                                       Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amountNet'                           Get Element Attribute   xpath=//div[@data-qa="award_amount"]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amount'                              Get Element Attribute   xpath=(//div[@data-qa="award_amount"])[1]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[0].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[1].status'                                    Get Text   xpath=(//td[contains(@class, 'qa_status_award')])[2]
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amountNet'                           Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amount'                              Get Element Attribute    xpath=(//div[@data-qa="qa_user_award"])[2]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'auctionPeriod.startDate'                                Get Element Attribute    xpath=//dd[contains(@class, 'qa_date_time_auction')]//span[@class="qa_date_time_start"]@data-period-date-start
    ...  ELSE IF    '${field_name}' == 'lots[0].title'                                          get text   xpath=//span[contains(@class, 'qa_lot_title')]
    sleep  2
    Run Keyword If  '${KeyIslot}' == 'True'     CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Run Keyword If  '${KeyIslot}' == 'True'     Wait Until Element Is Visible   css=.qa_lot_button     10

    [Return]  ${return_value}

Отримати інформацію із тендера
    [Arguments]   ${username}   ${tender_uaid}   ${field_name}
    log to console  ***Отримати інформацію із тендера***
    log to console  ${field_name}
    ${return_value}=        Run Keyword If        '${field_name}' == 'awards[0].documents[0].title'                       click element  css=[title="Документи"]
    ${return_value}=        Run Keyword If        '${field_name}' == 'awards[0].documents[0].title'                       sleep  5
    ${return_value}=        Run Keyword If        '${field_name}' == 'title'                Get Text   xpath=(//h1)[1]
    ...  ELSE IF    '${field_name}' == 'description'                                        Get Text   xpath=(//p[@class])[3]
    ...  ELSE IF    '${field_name}' == 'tenderID'                                           Get Text   css=.qa_tender_id
    ...  ELSE IF    '${field_name}' == 'mainProcurementCategory'                            Get Text   css=.qa_procurement_category_choices
    ...  ELSE IF    '${field_name}' == 'procurementMethodType'                              get text   css=.qa_purchase_procedure
    ...  ELSE IF    '${field_name}' == 'maxAwardsCount'                                     get text   css=.qa_participants_agreement
    ...  ELSE IF    '${field_name}' == 'value.valueAddedTaxIncluded'                        Get Text   xpath=(//span[contains(@class, 'qa_vat')])[2]
    ...  ELSE IF    '${field_name}' == 'value.currency'                                     Get Text   css=.qa_code
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                        Get Text   css=.qa_funding_kind
    ...  ELSE IF    '${field_name}' == 'value.amount'                                       Get Text   css=.qa_buget
    ...  ELSE IF    '${field_name}' == 'tenderPeriod.startDate'                             Get Element Attribute    xpath=//dd[contains(@class, ' qa_date_submission_of_proposals')]//span[contains(@class, 'qa_date_time_start')]@data-period-date-start
    ...  ELSE IF    '${field_name}' == 'tenderPeriod.endDate'                               Get Element Attribute    xpath=//dd[contains(@class, ' qa_date_submission_of_proposals')]//span[contains(@class, 'qa_date_time_end')]@data-period-date-end
    ...  ELSE IF    '${field_name}' == 'features[0].title'                                  Get Text   xpath=//p[@class="h-mb-10"]
    ...  ELSE IF    '${field_name}' == 'features[0].description'                            Get Text   xpath=(//span[@class='qa_state_feature_desc'])[1]
    ...  ELSE IF    '${field_name}' == 'procuringEntity.name'                               Get Text   xpath=(//div[contains(@class, 'qa_company_dd')]//p)[2]
    ...  ELSE IF    '${field_name}' == 'enquiryPeriod.startDate'                            Get Element Attribute   xpath=//dd[contains(@class, ' qa_date_period_clarifications')]//span[contains(@class, 'qa_end_clarifications')]@qa_date_period_enquire_start
    ...  ELSE IF    '${field_name}' == 'enquiryPeriod.endDate'                              Get Element Attribute   xpath=//dd[contains(@class, ' qa_date_period_clarifications')]//span[contains(@class, 'qa_end_clarifications')]@qa_date_period_clarifications
    ...  ELSE IF    '${field_name}' == 'qualificationPeriod.endDate'                        Отримати qualificationPeriod.endDate
    ...  ELSE IF    '${field_name}' == 'milestones[0].code'                                 Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[1].code'                                 Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[2].code'                                 Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[0].title'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[1].title'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[2].title'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[0].percentage'                           Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[1].percentage'                           Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[2].percentage'                           Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.days'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.days'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.days'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.type'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.type'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.type'                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                                 Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'status'                                             Get Text   xpath=//span[@class="qa_tender_status"]
    ...  ELSE IF    '${field_name}' == 'qualifications[0].status'                           Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'qualifications[1].status'                           Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'causeDescription'                                   Get Text   css=.qa_state_purchase_cause_description
    ...  ELSE IF    '${field_name}' == 'cause'                                              Get Text   css=.qa_state_purchase_cause_title
    ...  ELSE IF    '${field_name}' == 'procuringEntity.address.countryName'                Get Text   css=.qa_state_merchant_address_country_name
    ...  ELSE IF    '${field_name}' == 'procuringEntity.address.locality'                   Get Text   css=.qa_state_merchant_address_locality
    ...  ELSE IF    '${field_name}' == 'procuringEntity.address.postalCode'                 Get Text   css=.qa_state_merchant_address_postal_code
    ...  ELSE IF    '${field_name}' == 'procuringEntity.address.region'                     Get Text   css=.qa_state_merchant_address_region
    ...  ELSE IF    '${field_name}' == 'procuringEntity.address.streetAddress'              Get Text   css=.qa_state_merchant_address_street
    ...  ELSE IF    '${field_name}' == 'procuringEntity.contactPoint.name'                  Get Text   css=.qa_contact_name
    ...  ELSE IF    '${field_name}' == 'procuringEntity.contactPoint.telephone'             Get Text   css=.qa_contact_phone
    ...  ELSE IF    '${field_name}' == 'procuringEntity.contactPoint.url'                   Get Text   css=.qa_state_merchant_site
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.legalName'               Get Text   css=.qa_state_merchant_name
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.scheme'                  set variable  	UA-EDR
    ...  ELSE IF    '${field_name}' == 'procuringEntity.identifier.id'                      Get Text   css=.qa_state_merchant_EDRPOU
    ...  ELSE IF    '${field_name}' == 'items[0].description'                               Get Text   xpath=(//div[contains(@class, 'qa_item_description')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].description'                               Get Text   xpath=(//div[contains(@class, 'qa_item_description')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].classification.scheme'                     set variable  ДК021
    ...  ELSE IF    '${field_name}' == 'items[1].classification.scheme'                     set variable  ДК021
    ...  ELSE IF    '${field_name}' == 'items[0].classification.id'                         Get Text   xpath=(//span[@class='qa_classifier_descr_code'])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].classification.id'                         Get Text   xpath=(//span[@class='qa_classifier_descr_code'])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].classification.description'                Get Text   xpath=(//span[@class='qa_classifier_descr_primary'])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].classification.description'                Get Text   xpath=(//span[@class='qa_classifier_descr_primary'])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].quantity'                                  Get Text   xpath=(//span[@class='qa_item_quantity'])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].quantity'                                  Get Text   xpath=(//span[@class='qa_item_quantity'])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryDate.endDate'                      Get Element Attribute   xpath=(//span[contains(@class, 'qa_date_time_end')])[1]@data-period-date-end
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryDate.endDate'                      Get Element Attribute   xpath=(//span[contains(@class, 'qa_date_time_end')])[2]@data-period-date-end
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryAddress.countryName'               Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_country_name')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryAddress.countryName'               Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_country_name')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryAddress.postalCode'                Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_postal_code')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryAddress.postalCode'                Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_postal_code')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryAddress.region'                    Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_region')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryAddress.region'                    Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_region')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryAddress.locality'                  Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_locality')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryAddress.locality'                  Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_locality')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].deliveryAddress.streetAddress'             Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_street_address')])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].deliveryAddress.streetAddress'             Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_street_address')])[2]
    ...  ELSE IF    '${field_name}' == 'items[0].unit.name'                                 Get Text   xpath=(//span[@class='qa_item_unit'])[1]
    ...  ELSE IF    '${field_name}' == 'items[1].unit.name'                                 Get Text   xpath=(//span[@class='qa_item_unit'])[2]
    ...  ELSE IF    '${field_name}' == 'awards[0].status'                                   Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].contactPoint.name'           Get Text   xpath=(//span[contains(@class, 'qa_delivery_address_street_address')])[2]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].address.countryName'         Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_country_name')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].address.locality'            Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_locality')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].address.postalCode'          Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_postal_code')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].address.region'              Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_region')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].address.streetAddress'       Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_street')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].contactPoint.telephone'      set variable  +380881112233
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].contactPoint.name'           set variable   Тестовий Учасник 1
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].contactPoint.email'          Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_street')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].identifier.scheme'           set variable  	UA-EDR
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].identifier.legalName'        Get Text   xpath=//div[contains(@class, 'qa_award_item ')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].identifier.id'               Get Text   xpath=//span[contains(@class, 'qa_state_merchant_address_street')]
    ...  ELSE IF    '${field_name}' == 'awards[0].suppliers[0].name'                        Get Text   xpath=//div[contains(@class, 'qa_award_item ')]
    ...  ELSE IF    '${field_name}' == 'awards[0].value.valueAddedTaxIncluded'              Get Text   xpath=(//span[contains(@class, 'qa_vat')])[1]
    ...  ELSE IF    '${field_name}' == 'awards[0].value.currency'                           Get Text   xpath=(//span[contains(@class, 'qa_code')])[1]
    ...  ELSE IF    '${field_name}' == 'awards[0].value.amount'                             Get Element Attribute   xpath=(//div[@data-qa="award_amount"])[1]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'awards[0].documents[0].title'                       Get Text   xpath=(//div[contains(@class, 'qa_classifier_popup')]//a[contains(@class, 'qa_file_name')])[1]
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amountNet'                       Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amount'                          Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'contracts[0].status'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'contracts[1].status'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amountNet'                       Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amount'                          Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'documents[0].title'                                 Get Text   xpath=(//a[contains(@class, 'qa_file_name')])[1]
    ...  ELSE IF    '${field_name}' == 'budget.amount'                                      get element attribute   xpath=//span[@class="qa_budget_amount"]@data-qa-amount
    ...  ELSE IF    '${field_name}' == 'NBUdiscountRate'                                    Get Element Attribute    xpath=//span[contains(@class, 'qa_nbu_rate')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'complaintPeriod.endDate'                            get element attribute  xpath=(//span[contains(@class, "qa_date_time_end")])[1]@data-period-date-end
    ...  ELSE IF    '${field_name}' == 'minimalStepPercentage'                              Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'lots[0].minimalStepPercentage'                      Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'lots[0].title'                                      Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                        Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'lots[0].fundingKind'                                Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'yearlyPaymentsPercentageRange'                      Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'lots[0].yearlyPaymentsPercentageRange'              Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'enquiryPeriod.clarificationsUntil'                  get element attribute  xpath=//span[contains(@class, 'qa_date_period_answer')]@qa_date_clarifications_until
    ...  ELSE IF    '${field_name}' == 'contracts[0].dateSigned'                            get element attribute  xpath=//span[contains(@class, 'qa_date_tender_terms')]@data-qa-date
    ...  ELSE IF    '${field_name}' == 'awards[0].complaintPeriod.endDate'                  Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'awards[1].complaintPeriod.endDate'                  Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'awards[2].complaintPeriod.endDate'                  Отримати інформацію із лота тендера      ${field_name}
    ...  ELSE IF    '${field_name}' == 'auctionPeriod.startDate'                            Отримати інформацію із лота тендера      ${field_name}
    reload page
    sleep  1
    ${return_value}=   Run Keyword If    '${field_name}' == 'mainProcurementCategory'       convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'procurementMethodType'                              convert_procurementmethodtype                   ${return_value}
    ...  ELSE IF    '${field_name}' == 'value.valueAddedTaxIncluded'                        convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'maxAwardsCount'                                     convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'value.currency'                                     convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'value.amount'                                       convert to number                               ${return_value.replace(" ", "").replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                        convert_fundingkind                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].value.amount'                               convert to number                               ${return_value.replace(" ", "").replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'lots[0].value.currency'                             convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].value.valueAddedTaxIncluded'                convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].minimalStep.currency'                       convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].minimalStep.valueAddedTaxIncluded'          convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[0].code'                                 get_milestones_code                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[1].code'                                 get_milestones_code                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[2].code'                                 get_milestones_code                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[0].title'                                get_milestones_title                            ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[1].title'                                get_milestones_title                            ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[2].title'                                get_milestones_title                            ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.days'                        convert to integer                              ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.days'                        convert to integer                              ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.days'                        convert to integer                              ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[0].percentage'                           convert to integer                              ${return_value.replace("%", "")}
    ...  ELSE IF    '${field_name}' == 'milestones[1].percentage'                           convert to integer                              ${return_value.replace("%", "")}
    ...  ELSE IF    '${field_name}' == 'milestones[2].percentage'                           convert to integer                              ${return_value.replace("%", "")}
    ...  ELSE IF    '${field_name}' == 'milestones[0].duration.type'                        get_milestones_duration_type                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[1].duration.type'                        get_milestones_duration_type                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'milestones[2].duration.type'                        get_milestones_duration_type                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'items[0].unit.name'                                 convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'status'                                             convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'qualifications[0].status'                           convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'qualifications[1].status'                           convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[0].status'                                convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[1].status'                                convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                                 convert to number                               ${return_value.replace(" ", "").replace(',', '.').replace(u'грн', '')}
    ...  ELSE IF    '${field_name}' == 'cause'                                              revert_negotiation_cause_type                   ${return_value}
    ...  ELSE IF    '${field_name}' == 'items[0].quantity'                                  convert to number                               ${return_value.replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'items[1].quantity'                                  convert to number                               ${return_value.replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'awards[0].status'                                   convert_tender_status                           ${return_value}
    ...  ELSE IF    '${field_name}' == 'awards[0].value.amount'                             convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amountNet'                       convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amountNet'                       convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[0].value.amount'                          convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'contracts[1].value.amount'                          convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'budget.amount'                                      convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'awards[0].value.valueAddedTaxIncluded'              convert_prom_string_to_common_string            ${return_value}
    ...  ELSE IF    '${field_name}' == 'NBUdiscountRate'                                    convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                        convert_fundingkind                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].fundingKind'                                convert_fundingkind                             ${return_value}
    ...  ELSE IF    '${field_name}' == 'minimalStepPercentage'                              convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].minimalStepPercentage'                      convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'yearlyPaymentsPercentageRange'                      convert to number                               ${return_value}
    ...  ELSE IF    '${field_name}' == 'lots[0].yearlyPaymentsPercentageRange'              convert to number                               ${return_value}
    ...  ELSE        convert_prom_string_to_common_string       ${return_value}
    [Return]  ${return_value}

Отримати інформацію із предмету
    [Arguments]   ${username}   ${tender_uaid}   ${item_id}   ${field_name}
    sleep  4
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    ${return_value}=     Run Keyword If                 '${field_name}' == 'description'             Get Text   xpath=//div[contains(text(), '${item_id}')][contains(@class, 'qa_item_description')]
    ...  ELSE IF    '${field_name}' == 'deliveryDate.startDate'                    Get Element Attribute   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_date_time_start')]@data-period-date-start
    ...  ELSE IF    '${field_name}' == 'deliveryDate.endDate'                      Get Element Attribute   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_date_time_end')]@data-period-date-end
    ...  ELSE IF    '${field_name}' == 'deliveryAddress.countryName'               Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_delivery_address_country_name')]
    ...  ELSE IF    '${field_name}' == 'deliveryAddress.postalCode'                Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_delivery_address_postal_code')]
    ...  ELSE IF    '${field_name}' == 'deliveryAddress.region'                    Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_delivery_address_region')]
    ...  ELSE IF    '${field_name}' == 'deliveryAddress.locality'                  Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_delivery_address_locality')]
    ...  ELSE IF    '${field_name}' == 'deliveryAddress.streetAddress'             Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_delivery_address_street_address')]
    ...  ELSE IF    '${field_name}' == 'classification.scheme'                     Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[@class='qa_classifier_dk']
    ...  ELSE IF    '${field_name}' == 'classification.description'                Get Text   xpath=//div[contains(text(), '${item_id}')]/..//span[@class='qa_classifier_descr_primary']
    ...  ELSE IF    '${field_name}' == 'classification.id'                         Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[@class='qa_classifier_descr_code']
    ...  ELSE IF    '${field_name}' == 'unit.name'                                 Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[contains(@class, 'qa_item_unit')]
    ...  ELSE IF    '${field_name}' == 'quantity'                                  Get Text   xpath=//div[contains(text(), '${item_id}')]/../..//span[@class='qa_item_quantity']
    ${return_value}=   Run Keyword If    '${field_name}' == 'unit.name'         convert_prom_string_to_common_string                                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'classification.scheme'                  convert_prom_string_to_common_string                                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'quantity'                               convert to number                        ${return_value.replace(',', '.')}
    ...  ELSE        convert_prom_string_to_common_string       ${return_value}
    sleep  3
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Отримати інформацію із лоту
    [Arguments]   ${username}   ${tender_uaid}   ${lot_id}   ${field_name}
    sleep  4
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    log to console   ${field_name}
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    ${return_value}=     Run Keyword If            '${field_name}' == 'title'       Get Text   css=.qa_lot_title
    ...  ELSE IF    '${field_name}' == 'description'                                Get Text   css=.qa_lot_description
    ...  ELSE IF    '${field_name}' == 'value.amount'                               Get Text   xpath=//dl[contains(@class, 'qa_inform')]//span[@class='qa_buget']
    ...  ELSE IF    '${field_name}' == 'value.currency'                             Get Text   css=.qa_code
    ...  ELSE IF    '${field_name}' == 'value.valueAddedTaxIncluded'                Get Text   xpath=(//span[contains(@class, 'qa_vat')])[2]
    ...  ELSE IF    '${field_name}' == 'minimalStep.currency'                       Get Text   css=.qa_code
    ...  ELSE IF    '${field_name}' == 'minimalStep.valueAddedTaxIncluded'          Get Text   xpath=(//span[contains(@class, 'qa_vat')])[2]
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                         Get Text   css=.qa_minimum_bid_increment
    ...  ELSE IF    '${field_name}' == 'minimalStepPercentage'                      Get Element Attribute   xpath=//span[contains(@class, 'qa_minimal_step')]@data-qa-value
    ...  ELSE IF    '${field_name}' == 'fundingKind'                                Get Text   xpath=//span[contains(@class, 'qa_funding_kind')]
    ...  ELSE IF    '${field_name}' == 'yearlyPaymentsPercentageRange'              Get Element Attribute   xpath=//span[contains(@class, 'qa_financial_step')]@data-qa-value
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    log to console   ${return_value}
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    ${return_value}=   Run Keyword If    '${field_name}' == 'unit.name'       convert_prom_string_to_common_string                                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'quantity'                           convert to number                        ${return_value.replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'value.amount'                       convert to number                        ${return_value.replace(' ', '').replace(',', '.')}
    ...  ELSE IF    '${field_name}' == 'minimalStep.amount'                 convert to number                        ${return_value.replace(" ", "").replace(',', '.').replace(u'грн', '')}
    ...  ELSE IF    '${field_name}' == 'fundingKind'                        convert_fundingkind                      ${return_value}
    ...  ELSE IF    '${field_name}' == 'minimalStepPercentage'              convert to number                        ${return_value}
    ...  ELSE IF    '${field_name}' == 'yearlyPaymentsPercentageRange'      convert to number                        ${return_value}
    ...  ELSE        convert_prom_string_to_common_string       ${return_value}
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    log to console   ${return_value}
    log to console  %%%%%%%%%%%%%%%%%%%%%%%
    sleep  3
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Отримати інформацію із нецінового показника
    [Arguments]   ${username}   ${tender_uaid}   ${feature_id}  ${field_name}
    sleep  4
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    ${return_value}=     Run Keyword If            '${field_name}' == 'title'       Get Text   xpath=(//p[@class="h-mb-10"])[last()]
    ...  ELSE IF    '${field_name}' == 'description'                                Get Text   xpath=(//span[@class='qa_state_feature_desc'])[last()]
    ...  ELSE IF    '${field_name}' == 'featureOf'                                  set variable       tenderer
    ${return_value}=   Run Keyword If    '${field_name}' == 'unit.name'       convert_prom_string_to_common_string                                    ${return_value}
    ...  ELSE IF    '${field_name}' == 'quantity'                           convert to number                        ${return_value.replace(',', '.')}
    ...  ELSE        convert_prom_string_to_common_string       ${return_value}
    sleep  3
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Отримати інформацію із документа
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
    log to console   ${field}
    ${return_value}=        Run Keyword And Return If                      '${field}' == 'title'                         Get Text   css=.qa_file_name
    ...  ELSE IF    '${field}' == 'documentOf'                      set variable     tender
    [Return]  ${return_value}

Отримати документ
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
    sleep  2
    Click Element   xpath=//a[contains(text(), '${doc_id}')]
    Sleep   3
    ${file_name}=   Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@id
    ${url}=   Get Element Attribute    xpath=//div[contains(@id, '${file_name}')]//a@href
    download_file   ${url}  ${file_name.split('/')[-1]}  ${OUTPUT_DIR}
    [Return]  ${file_name.split('/')[-1]}

Задати запитання на тендер
    [Arguments]  ${username}   ${tender_uaid}   ${question}
    ${title}=        Get From Dictionary  ${question.data}  title
    ${description}=  Get From Dictionary  ${question.data}  description
    Wait Until Page Contains Element        id=qa_question_and_answer
    Click Element                           id=qa_question_and_answer
    Sleep   15
    Click Element                           css=.qa_ask_a_question
    Wait Until Page Contains Element        name=title    20
    Input Text                              name=title                 ${title}
    sleep  2
    Input Text                              xpath=//textarea[@name='description']           ${description}
    sleep  2
    Click Element                           id=submit_button
    Wait Until Page Contains Element        css=.qa_ask_a_question     30
    capture page screenshot

Отримати інформацію із запитання
    [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
    log to console  ${field_name}

    Wait Until Page Contains Element        css=[id="qa_question_and_answer"]  30
    Click Element                           css=[id="qa_question_and_answer"]
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Visible       xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]])

    ${status}=  Run Keyword And Return Status    Element Should Be Visible   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')])
    Run Keyword If   '${status}' == 'False'   Click Element   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//p[contains(@class, 'qa_message_title')])
    Sleep  3
    ${return_value}=      Run Keyword If   '${field_name}' == 'title'   Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//p[contains(@class, 'qa_message_title')])
    ...     ELSE IF  '${field_name}' == 'answer'                        Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//*[contains(@class, 'answer')])[last()]
    ...     ELSE IF  '${field_name}' == 'questions[0].answer'           Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//*[contains(@class, 'answer')])[last()]
    ...     ELSE IF  '${field_name}' == 'questions[0].description'      Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')])
    ...     ELSE IF  '${field_name}' == 'questions[0].title'            Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//p[contains(@class, 'qa_message_title')])
    ...     ELSE    Get Text   xpath=(//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')])
    [Return]  ${return_value}

Отримати посилання на аукціон для глядача
    [Arguments]    ${username}  ${tender_uaid}   ${lot_id}=${Empty}
    log to console  ~~~~~~+++~~~
    log to console  ${tender_uaid}
    log to console  ~~~~~~+++~~~
    CLICK ELEMENT    css=.qa_lot_button
    sleep  5
    ${return_value}=    Get Text     xpath=(//a[contains(@href, 'https://auction-staging.prozorro.gov.ua/tenders')])[2]
    log to console  *^&^&^*^*&^*%^&%&%$*%*%
    log to console    ${return_value}
    log to console  *^&^&^*^*&^*%^&%&%$*%*%
    sleep  2
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Отримати посилання на аукціон для учасника
    [Arguments]    ${username}  ${tender_uaid}   ${lot_id}=${Empty}
    log to console  ^%^%^%^%^%^%^%^%
    log to console  ${tender_uaid}
    log to console  ^%^%^%^%^%^%^%^%
    CLICK ELEMENT    css=.qa_lot_button
    sleep  5
    ${return_value}=   Get Text   xpath=(//a[contains(@href, 'https://auction-staging.prozorro.gov.ua/tenders')])[2]
    log to console  *^&^&^*^*&^*2234234%^&%&%$*%*%
    log to console    ${return_value}
    log to console  *^&^&^*^*&^234324*%^&%&%$*%*%
    sleep  2
    CLICK ELEMENT    xpath=(//a[contains(@href, "state_purchase/view")])[2]
    Wait Until Element Is Visible   css=.qa_lot_button     10
    [Return]  ${return_value}

Подати цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${bid}  ${lots_ids}=None  ${features_ids}=None
    log to console   ----------------------------
    log to console   ${bid}
    log to console   ----------------------------
    log to console  -=-=-=-=-=-_+__+_=-=-=--=-=-
    log to console    ${procurement_method_type}
    log to console  -=-=-=-=-=-_+__+_=-=-=--=-=-
    ${return_value}=   Run Keyword If    '${procurement_method_type}' == 'esco'     Додати лот у esco     ${bid}    ${lots_ids}
    ...  ELSE IF    '${procurement_method_type}' == 'belowThreshold'    Додати лот у belowThreshold   ${bid}    ${lots_ids}
    ...  ELSE      Додати лот у звичайну процедуру     ${bid}    ${lots_ids}

Додати лот у звичайну процедуру
    [Arguments]   ${bid}   ${lots_ids}
    capture page screenshot
    ${lots}=   Get From Dictionary       ${bid.data}    lotValues
    ${number_of_lot}=  Get Length       ${lots}
    set global variable    ${number_of_lot}
    :FOR  ${index}  IN RANGE  ${number_of_lot}
    \  Додати lot ставку    ${lots[${index}]}    ${lots_ids[0]}
    capture page screenshot

Додати лот у esco
    [Arguments]   ${bid}    ${lots_ids}
    capture page screenshot
    ${lots}=   Get From Dictionary       ${bid.data}    lotValues
    ${number_of_lot}=  Get Length       ${lots}
    set global variable    ${number_of_lot}
    :FOR  ${index}  IN RANGE  ${number_of_lot}
    \  Додаты lot в ставку esco    ${lots[${index}]}    ${lots_ids[0]}
    capture page screenshot

Додати лот у belowThreshold
    [Arguments]   ${bid}    ${lots_ids}
    log to console  --------------$$$444$$$$-------
    log to console  ${KeyIslot}
    log to console  --------------$$$444$$$$-------

    Run Keyword If      ${KeyIslot}                     Додати лот у звичайну процедуру         ${bid}   ${lots_ids}
    Run Keyword If     '${KeyIslot}' == 'False'         Додати лот у belowThreshold singl       ${bid}   ${lots_ids}

Додати лот у belowThreshold singl
    [Arguments]   ${bid}    ${lots_ids}
    log to console  @@@@
    log to console  ${bid}
    log to console  @@@@
    Додати lot ставку    ${bid}    ${lots_ids[0]}

Додати lot ставку
    [Arguments]   ${lots}    ${lots_ids}
    ${amount}=                                  Get From Dictionary             ${lots.value}                      amount
    ${valueAddedTaxIncluded}=                   Get From Dictionary             ${lots.value}                      valueAddedTaxIncluded

    Click Element       xpath=(//a[contains(@class, 'qa_add_new_offer')]//span)[last()]
    Wait Until Page Contains Element     css=[data-qa="add_file"]    10
    ${chbx_rule}=   Run Keyword And Return Status           Element Should Be Enabled   css=[data-qa="chbx_rule"]
    Run Keyword If   '${chbx_rule}' == 'True'               Click Element               css=[data-qa="chbx_rule"]
    sleep  2
    ${chbx_qualification}=   Run Keyword And Return Status      Element Should Be Enabled     css=[data-qa="chbx_qualification"]
    Run Keyword If   '${chbx_qualification}' == 'True'          Click Element                 css=[data-qa="chbx_qualification"]
    sleep  2
    ${bid_amount_str}=     convert to string    ${amount}
    click element       xpath=//span[contains(text(), '${lots_ids}')]/..//button[@data-qa="participate"]
    Wait Until Page Contains Element     css=[data-qa="lot_price"]    10
    input Text          xpath=//span[contains(text(), '${lots_ids}')]/..//input[@data-qa="lot_price"]    ${bid_amount_str}
    capture page screenshot
    Click Element       css=[data-qa="submit_payment"]
    sleep  3
    capture page screenshot
    ${pop_up}=  Run Keyword And Return Status    Element Should Be Visible     xpath=//button[@data-qa="ok"]
    Run Keyword If    '${pop_up}' == 'True'    Click Element       xpath=//button[@data-qa="ok"]
    Sleep   90
    reload page

Додаты lot в ставку esco
    [Arguments]   ${lots}    ${lots_ids}
    ${yearlyPaymentsPercentage}=                Get From Dictionary             ${lots.value}                                       yearlyPaymentsPercentage
    ${valueAddedTaxIncluded}=                   Get From Dictionary             ${lots.value}                                       valueAddedTaxIncluded
    ${days}=                                    Get From Dictionary             ${lots.value.contractDuration}                      days
    ${years}=                                   Get From Dictionary             ${lots.value.contractDuration}                      years

    Click Element       xpath=(//a[contains(@class, 'qa_add_new_offer')]//span)[last()]
    Wait Until Page Contains Element     css=[data-qa="add_file"]    10
    sleep  1
    ${chbx_rule}=   Run Keyword And Return Status      Element Should Be Enabled   css=[data-qa="chbx_rule"]
    Run Keyword If   '${chbx_rule}' == 'True'    Click Element     css=[data-qa="chbx_rule"]
    sleep  2
    ${chbx_qualification}=   Run Keyword And Return Status    Element Should Be Enabled     css=[data-qa="chbx_qualification"]
    Run Keyword If   '${chbx_qualification}' == 'True'      Click Element     css=[data-qa="chbx_qualification"]
    sleep  2
    click element       xpath=//p[contains(text(), '${lots_ids}')]/..//button[@data-qa="participate"]
    Wait Until Page Contains Element     css=[data-qa="number_days"]    10
    sleep  1
    input text      css=[data-qa="number_days"]     ${days}
    sleep  1
    click element   xpath=//div[@data-qa="duration_years"]
    sleep  1
    click element   xpath=//div[@data-qa="dd_lists"][text()='${years}']
    sleep  1
    ${yearlyPaymentsPercentage}=    convert to string     ${yearlyPaymentsPercentage}
    input text      xpath=//input[@data-qa="yearly_range"]     ${yearlyPaymentsPercentage}
    capture page screenshot
    sleep  1
    ${annual}=   Get From Dictionary       ${lots.value}    annualCostsReduction
    ${number_of_annual}=  Get Length       ${annual}
    set global variable    ${number_of_annual}
    :FOR  ${index}  IN RANGE  ${number_of_annual}
    \  Добавить annualCostsReduction    ${annual[${index}]}   ${index}
    capture page screenshot

    Click Element       css=[data-qa="submit_payment"]
    sleep  3
    capture page screenshot
    ${pop_up}=  Run Keyword And Return Status    Element Should Be Visible     xpath=//button[@data-qa="ok"]
    Run Keyword If    '${pop_up}' == 'True'    Click Element       xpath=//button[@data-qa="ok"]
    Sleep   90
    reload page

Добавить annualCostsReduction
    [Arguments]   ${annual}     ${index}

    ${annual}=    convert to string    ${annual}
    ${input_line}=   Run Keyword And Return Status       Element Should Be Visible   xpath=(//input[@data-qa="reduction_input"])[${index + 1}]
    sleep  1
    run keyword if  '${input_line}' == 'True'  input text  xpath=(//input[@data-qa="reduction_input"])[${index + 1}]    ${annual}

Отримати інформацію із пропозиції
    [Arguments]   ${username}   ${tender_uaid}   ${field}

    capture page screenshot
    Wait Until Page Contains Element      xpath=(//span[@class="qa_offer_amount"])[1]     10
    ${return_value}=        Run Keyword If    '${field}' == 'lotValues[0].value.amount'       Get Text   xpath=(//span[@class="qa_offer_amount"])[1]
    ...  ELSE IF    '${field}' == 'status'                                 Get Text   css=.qa_state_offer_status

    ${return_value}=        Run Keyword If    '${field}' == 'lotValues[0].value.amount'       convert to number         ${return_value.replace(" ", "").replace(',', '.')}
    ...  ELSE IF    '${field}' == 'status'         convert_tender_status                           ${return_value}
    ...  ELSE        convert_prom_string_to_common_string       ${return_value}
    sleep  3
    reload page

    [Return]    ${return_value}

Завантажити документ в ставку
    [Arguments]  ${username}  ${path}  ${tender_uaid}  ${doc_type}=documents  ${doc_name}=${None}
    log to console  =-=-=-=-=-=-=-=
    log to console  ${tender_uaid}
    log to console  =-=-=-=-=-=-=-=
    capture page screenshot
    Wait Until Page Contains Element      css=.qa_edit_offer     10
    Sleep   5
    Click Element       css=.qa_edit_offer
    sleep   2
    Click Element       xpath=(//span[@data-qa="skip_unskip"])[1]
    Sleep   3
    Wait Until Page Contains Element     css=[data-qa="add_file"]
    Choose File         css=[data-qa="add_file"]   ${path}
    Sleep   10
    click element       xpath=(//div[@data-qa="file_type"])[last()]
    Sleep   2
    Run Keyword If      '${doc_type}' == 'financial_documents'          click element     xpath=(//div[@data-qa="dd_lists"]//div[text()='Цінова пропозиція'])[last()]
    ...     ELSE IF     '${doc_type}' == 'documents'                    click element     xpath=(//div[@data-qa="dd_lists"]//div[text()='Цінова пропозиція'])[last()]
    ...     ELSE IF     '${doc_type}' == 'qualification_documents'      click element     xpath=(//div[@data-qa="dd_lists"]//div[text()='Документи, що підтверджують кваліфікацію'])[last()]
    ...     ELSE IF     '${doc_type}' == 'eligibility_documents'        click element     xpath=(//div[@data-qa="dd_lists"]//div[text()='Документи, що підтверджують відповідність'])[last()]
    ...     ELSE     click element       xpath=(//div[@data-qa="dd_lists"]//div[text()='Цінова пропозиція'])[last()]
    sleep   2
    Click Element       css=[data-qa="submit_payment"]
    sleep  4
    reload page

Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
    log to console  _)_)_)_)_)_)_)_)_)_
    log to console  ${docid}
    log to console  _)_)_)_)_)_)_)_)_)_
    Wait Until Page Contains Element      css=.qa_edit_offer     10
    Sleep   5
    Click Element       css=.qa_edit_offer
    sleep   2
    Click Element       xpath=(//span[@data-qa="skip_unskip"])[1]
    Sleep   3
    Wait Until Page Contains Element     css=[data-qa="add_file"]
    Choose File         xpath=//span[contains(text(), '${docid}')]/../../../..//input[@name="files"]   ${path}
    Sleep   10
    Click Element       css=[data-qa="submit_payment"]
    sleep  4
    reload page

Змінити документацію в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${doc_data}  ${docid}
    log to console  $!$!$!$!$!$!$!$!
    log to console  ${doc_data}
    log to console  $!$!$!$!$!$!$!$!
    log to console  ${docid}
    log to console  $!$!$!$!$!$!$!$!

Змінити цінову пропозицію
    [Arguments]  ${username}  ${tender_uaid}  ${field}   ${value}

    run keyword if  '${procurement_method_type}' == 'esco'    Змінити цінову пропозицію esco   ${username}  ${tender_uaid}  ${field}   ${value}
    ...  ELSE     Змінити цінову пропозицію all   ${username}  ${tender_uaid}  ${field}   ${value}

Змінити цінову пропозицію all
    [Arguments]  ${username}  ${tender_uaid}  ${field}   ${value}
    log to console  ~~~~~~~~~~~~~~~~~~~~~~~~
    log to console  ${field}
    log to console  ~~~~~~~~~~~~~~~~~~~~~~~~
    log to console  ${value}
    log to console  ~~~~~~~~~~~~~~~~~~~~~~~~
    sleep       10
    ${value}=    convert to string  ${value}
    Wait Until Page Contains Element      css=.qa_edit_offer     10
    Sleep   5
    Click Element       css=.qa_edit_offer
    sleep   2
    Click Element       xpath=(//span[@data-qa="skip_unskip"])[1]
    Sleep   3
    clear element text     xpath=//input[@data-qa="lot_price"]
    sleep  1
    input text      xpath=//input[@data-qa="lot_price"]    ${value}
    Sleep   1
    Click Element       css=[data-qa="submit_payment"]
    Sleep   3
    ${pop_up}=  Run Keyword And Return Status    Element Should Be Visible     xpath=//button[@data-qa="ok"]
    Run Keyword If    '${pop_up}' == 'True'    Click Element       xpath=//button[@data-qa="ok"]
    Sleep   90
    reload page

Змінити цінову пропозицію esco
    [Arguments]  ${username}  ${tender_uaid}  ${field}   ${value}
    log to console  ~~~~~~~~~~esco~~~~~~~~~~~~~~
    log to console  ${field}
    log to console  ~~~~~~~~~esco~~~~~~~~~~~~~~~
    log to console  ${value}
    log to console  ~~~~~~~~~esco~~~~~~~~~~~~~~~
    sleep       10
    ${value}=    convert to string  ${value}
    Wait Until Page Contains Element      css=.qa_edit_offer     10
    Sleep   5
    Click Element       css=.qa_edit_offer
    sleep   2
    Click Element       xpath=(//span[@data-qa="skip_unskip"])[1]
    Sleep   3
    capture page screenshot
    Click Element       css=[data-qa="submit_payment"]
    Sleep   3
    ${pop_up}=  Run Keyword And Return Status    Element Should Be Visible     xpath=//button[@data-qa="ok"]
    Run Keyword If    '${pop_up}' == 'True'    Click Element       xpath=//button[@data-qa="ok"]
    Sleep   90
    reload page

Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    capture page screenshot
    sleep   1
    Wait Until Page Contains Element        xpath=//a[contains(@href, '/state_purchase/edit')]//span
    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    sleep   2
    Wait Until Page Contains Element     css=.qa_procurement_category_choices
    Choose File     xpath=(//input[contains(@class, 'qa_state_offer_add_field')])[1]     ${filepath}
    sleep   5

    capture page screenshot
    click element   css=.qa_submit_tender
    sleep   2
    Wait Until Keyword Succeeds     150      10          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       css=.zk-upload-files__file-id

Змінити лот
    [Arguments]  ${username}   ${tender_uaid}   ${lot_id}   ${fieldname}    ${fieldvalue}
    log to console  ------=-=-=-=-=-=-=-=23-4=2-
    log to console   ${fieldname}
    log to console  ------=-=-=-=-=-=-=-=23-4=2-
    log to console   ${fieldvalue}
    log to console  ------=-=-=-=-=-=-=-=23-4=2-
    sleep  1
    Wait Until Page Contains Element        xpath=//a[contains(@href, '/state_purchase/edit')]//span
    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    Wait Until Page Contains Element     xpath=//input[contains(@class, 'qa_multilot_tender_lot_bugdet')]           10
    ${return_value}=     Run Keyword If      '${fieldname}' == 'value.amount'           convert to string     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'value.amount'        clear element text     xpath=//input[contains(@class, 'qa_multilot_tender_lot_bugdet')]
    sleep  1
    Run Keyword If      '${fieldname}' == 'value.amount'        input text     xpath=//input[contains(@class, 'qa_multilot_tender_lot_bugdet')]    ${return_value}
    Run Keyword If      '${fieldname}' == 'value.amount'     input text    xpath=//input[contains(@class, 'qa_multilot_tender_step_auction_rate')]     "55555.55"
    capture page screenshot
    ${return_value}=     Run Keyword If      '${fieldname}' == 'minimalStep.amount'     convert to string     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'minimalStep.amount'        clear element text     xpath=//input[contains(@class, 'qa_multilot_tender_step_auction_rate')]
    sleep  1
    Run Keyword If      '${fieldname}' == 'minimalStep.amount'        input text     xpath=//input[contains(@class, 'qa_multilot_tender_step_auction_rate')]    ${return_value}

    capture page screenshot
    sleep  2
    click element  css=.qa_submit_tender
    sleep  1

Внести зміни в тендер
    [Arguments]  ${username}   ${tender_uaid}   ${fieldname}   ${fieldvalue}
    log to console  ***Внести зміни в тендер***
    log to console   ${fieldname}
    log to console  $@$@$$$@$@$^^
    log to console   ${fieldvalue}
    log to console  $@$@$$$@$@$^^
    Wait Until Page Contains Element        xpath=//a[contains(@href, '/state_purchase/edit')]//span
    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    sleep  1
    Wait Until Page Contains Element     css=.qa_procurement_category_choices


    Run Keyword If   '${procurement_method_type}' == 'aboveThresholdEU'                 Внести зміни EN                             ${fieldname}   ${fieldvalue}
    ...    ELSE IF   '${procurement_method_type}' == 'aboveThresholdUA.defense'         Внести зміни EN                             ${fieldname}   ${fieldvalue}
    ...    ELSE IF   '${procurement_method_type}' == 'belowThreshold'                   Внести зміни belowThreshold                 ${fieldname}   ${fieldvalue}
    ...    ELSE IF   '${procurement_method_type}' == 'esco'                             Внести зміни esco                           ${fieldname}   ${fieldvalue}
    ...    ELSE IF   '${procurement_method_type}' == 'closeFrameworkAgreementUA'        Внести зміни closeFrameworkAgreementUA      ${fieldname}   ${fieldvalue}
    ...    ELSE   Внести зміни UA   ${fieldname}   ${fieldvalue}

    sleep  2
    click element  css=.qa_submit_tender
    sleep  10
    Wait Until Page Contains Element        xpath=//a[contains(@href, '/state_purchase/edit')]//span   10

Внести зміни closeFrameworkAgreementUA
    [Arguments]     ${fieldname}    ${fieldvalue}
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date                                       ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text      css=.qa_multilot_end_period_adjustments
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text              css=.qa_multilot_end_period_adjustments     ${end_date}

    Run Keyword If      '${fieldname}' == 'maxAwardsCount'              clear element text      css=.qa_multilot_participants_agreement
    Run Keyword If      '${fieldname}' == 'maxAwardsCount'              sleep  2
    Run Keyword If      '${fieldname}' == 'maxAwardsCount'              input text              css=.qa_multilot_participants_agreement     ${fieldvalue}

Внести зміни EN
    [Arguments]    ${fieldname}   ${fieldvalue}
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text     css=.qa_multilot_end_period_adjustments
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text     css=.qa_multilot_end_period_adjustments    ${end_date}

    Run Keyword If      '${fieldname}' == 'description'        clear element text     css=.qa_tender_description
    Run Keyword If      '${fieldname}' == 'description'        sleep  2
    Run Keyword If      '${fieldname}' == 'description'        input text     css=.qa_tender_description    ${fieldvalue}

Внести зміни UA
    [Arguments]    ${fieldname}   ${fieldvalue}
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text     css=.qa_multilot_end_period_adjustments
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text     css=.qa_multilot_end_period_adjustments    ${end_date}

    Run Keyword If      '${fieldname}' == 'description'        clear element text     css=.qa_multilot_descr
    Run Keyword If      '${fieldname}' == 'description'        sleep  2
    Run Keyword If      '${fieldname}' == 'description'        input text     css=.qa_multilot_descr    ${fieldvalue}

Внести зміни belowThreshold
    [Arguments]    ${fieldname}   ${fieldvalue}

    Run Keyword If  '${KeyIslot}' == 'True'    Зміни belowThreshold multi    ${fieldname}   ${fieldvalue}
    Run Keyword If  '${KeyIslot}' == 'False'   Зміни belowThreshold singl    ${fieldname}   ${fieldvalue}

Зміни belowThreshold singl
    [Arguments]    ${fieldname}   ${fieldvalue}
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text     css=.qa_multilot_end_proposals
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text     css=.qa_multilot_end_proposals    ${end_date}

    Run Keyword If      '${fieldname}' == 'description'        clear element text     css=.qa_multilot_descr
    Run Keyword If      '${fieldname}' == 'description'        sleep  2
    Run Keyword If      '${fieldname}' == 'description'        input text     css=.qa_multilot_descr    ${fieldvalue}

Зміни belowThreshold multi
    [Arguments]    ${fieldname}   ${fieldvalue}
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text     css=.qa_multilot_end_period_adjustments
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text     css=.qa_multilot_end_period_adjustments    ${end_date}

    Run Keyword If      '${fieldname}' == 'description'        clear element text     css=.qa_multilot_descr
    Run Keyword If      '${fieldname}' == 'description'        sleep  2
    Run Keyword If      '${fieldname}' == 'description'        input text     css=.qa_multilot_descr    ${fieldvalue}

Внести зміни esco
    [Arguments]    ${fieldname}   ${fieldvalue}
    log to console  *******##*****
    log to console   ${fieldname}
    log to console  *******##*****
    log to console   ${fieldvalue}
    log to console  *******##*****
    ${end_date}=     Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'     tender_end_date_esco     ${fieldvalue}
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        clear element text     css=.qa_multilot_end_period_adjustments
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        sleep  2
    Run Keyword If      '${fieldname}' == 'tenderPeriod.endDate'        input text     css=.qa_multilot_end_period_adjustments    ${end_date}

    Run Keyword If      '${fieldname}' == 'description'        clear element text     css=.qa_tender_description
    Run Keyword If      '${fieldname}' == 'description'        sleep  2
    Run Keyword If      '${fieldname}' == 'description'        input text     css=.qa_tender_description   ${fieldvalue}

Додати не ціновий показник на тендер
    [Arguments]  ${username}   ${tender_uaid}   ${feature}

    ${code}=                    Get From Dictionary    ${feature}                code
    ${description}=             Get From Dictionary    ${feature}                description
    ${title}=                   Get From Dictionary    ${feature}                title
    ${title_en}=                Get From Dictionary    ${feature}                title_en
    ${title_ru}=                Get From Dictionary    ${feature}                title_ru
    ${featureOf}=               Get From Dictionary    ${feature}                featureOf

    ${enum}=                    Get From Dictionary    ${feature}                enum

    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    sleep  3
    capture page screenshot

    sleep  2
    Click Element     xpath=(//div[@class='qa_all_block']//a[contains(@class, 'qa_multilot_add_one_more_feature')])[last()]
    capture page screenshot
    sleep  4
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   input text    xpath=(//input[contains(@class, 'qa_feature_title ')])[last()]  ${title}
    ...  ELSE    input text    xpath=(//input[contains(@class, 'qa_multilot_feature_input_name')])[last()]   ${title}
    sleep   2
    capture page screenshot
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   click element    xpath=(//div[contains(@class, 'qa_language_qa_feature_title')])[last()]
    capture page screenshot
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   sleep   2
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   input text    xpath=(//input[contains(@class, 'qa_feature_title ')])[last()]  ${title_en}
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   sleep   2
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   input text    xpath=(//textarea[contains(@class, 'qa_feature_description ')])[last()]   ${description}
    ...  ELSE   input text    xpath=(//input[contains(@class, 'qa_multilot_feature_input_hint')])[last()]   ${description}
    sleep   1
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   click element    xpath=(//div[contains(@class, 'qa_language_qa_feature_description')])[last()]
    Run Keyword If  '${procurement_method_type}' in ['aboveThresholdEU', 'aboveThresholdUA.defense', 'competitiveDialogueEU', 'closeFrameworkAgreementUA']   input text    xpath=(//textarea[contains(@class, 'qa_feature_description ')])[last()]   ${description}
    sleep  4
    capture page screenshot

    ${number_of_enum}=              Get Length                      ${enum}
    set global variable                                             ${number_of_enum}
    :FOR  ${index}  IN RANGE  ${number_of_enum}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_multilot_add_options')])[last()]
    \  Додаты вагу нецінового критерія    ${enum[${index}]}   ${procurement_method_type}

    click element  css=.qa_submit_tender
    sleep  10

Видалити неціновий показник
    [Arguments]   ${username}   ${tender_uaid}    ${feature_id}    ${obj_id}=Empty
    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    sleep  3
    capture page screenshot
    click element    xpath=//input[contains(@data-qa-value, '${feature_id}')]/../../../../../../..//span[contains(@class, 'qa_multilot_delete_index')]
    sleep  3
    click element  css=.qa_submit_tender

Відповісти на запитання
    [Arguments]   ${username}   ${tender_uaid}    ${answer_data}    ${question_id}
    Sleep   2
    Wait Until Page Contains Element      css=#qa_question_and_answer
    Click Element                         css=#qa_question_and_answer
    Wait Until Page Contains Element      xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]
    Click Element           xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]
    Sleep  3
    Input Text      xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//textarea[@name='answer']        ${answer_data.data.answer}
    Sleep  3
    Click Element   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//button[@type='submit']

Підтвердити кваліфікацію
    [Arguments]   ${username}   ${tender_uaid}    ${qualification_num}
    log to console  ***Підтвердити кваліфікацію***
    log to console   ${qualification_num}
    ${index}=    run keyword if  '${qualification_num}' == '0'   set variable  1
    ...   ELSE     set variable  2
    sleep  2
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Enabled       xpath=(//button[@id="approve_popup"])[last()]

    ${award}=  Run Keyword And Return Status  Element Should Be Enabled  xpath=(//table[contains(@class, 'qa_prequalification')]//td[contains(@class, 'qa_status_award')])[${index}]/..//button[@id="approve_popup"]
    Run Keyword If  '${award}' == 'True'  click element  xpath=(//table[contains(@class, 'qa_prequalification')]//td[contains(@class, 'qa_status_award')])[${index}]/..//button[@id="approve_popup"]
    ...  ELSE   click element   xpath=(//button[@id="approve_popup"])[last()]
    sleep  5
    click element   xpath=(//form[@class="qa_winner_popup"]//input[@id='self_qualified'])
    sleep  1
    click element   xpath=(//form[@class="qa_winner_popup"]//input[@id='self_eligible'])
    sleep  2
    click element  xpath=(//form[@class="qa_winner_popup"]//button[@id='submit_button'])
    sleep  4
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10

Відхилити кваліфікацію
    [Arguments]   ${username}   ${tender_uaid}    ${qualification_num}
    log to console  ***Відхилити кваліфікацію***
    log to console  ${qualification_num}
    ${index}=    run keyword if  '${qualification_num}' == '1'   set variable  1
    ...   ELSE     set variable  2
    sleep  2
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10

    click element  xpath=(//button[contains(@data-afip-url, "state_qualification/unsuccessful")])['${index}']
    sleep  3
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Visible       css=#state_qualification_status_form
    click element   xpath=//form[@id='state_qualification_status_form']//div[contains(@class, 'drop-down')]//div
    sleep  2
    click element  xpath=//form[@id='state_qualification_status_form']//input[@id="0"]
    sleep  2
    click element  xpath=//form[@id='state_qualification_status_form']//button[contains(@class, 'qa_submit_dd')]
    sleep  2
    ${ananas}=     set variable     description from test
    input text    xpath=//form[@id='state_qualification_status_form']//textarea[@name="description"]    ${ananas}
    sleep  4
    click element  xpath=//form[@id='state_qualification_status_form']//button[@id="submit_button"]
    sleep  2
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10

Скасувати кваліфікацію
    [Arguments]   ${username}   ${tender_uaid}    ${qualification_num}
    ${index}=    run keyword if  '${qualification_num}' == '0'   set variable  1
    ...   ELSE     set variable  2
    log to console  ***Скасувати кваліфікацію***
    log to console  ${index}
    log to console  @#@#@@#@#@
    sleep  2
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    reload page
    sleep  3
    click element  xpath=(//button[contains(@data-afip-url, "state_qualification/cancel")])[last()]
    sleep  2
    Wait Until Element Is Visible     xpath=//form[@id='state_qualification_cancel_form']//button[@id="submit_button"]
    click element  xpath=//form[@id='state_qualification_cancel_form']//button[@id="submit_button"]
    sleep  20
    reload page
    sleep  4
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10

Затвердити остаточне рішення кваліфікації
    [Arguments]   ${username}   ${tender_uaid}
    log to console  ***Затвердити остаточне рішення кваліфікації***
    sleep  2
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    Wait Until Element Is Visible     xpath=//a[contains(@data-afip-url , 'complete_prequalification')]
    click element  xpath=//a[contains(@data-afip-url , 'complete_prequalification')]
    sleep  2
    click element  xpath=//form[contains(@action, 'complete_prequalification')]//button[@id='submit_button']
    sleep  10
    reload page
    sleep  1
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10

Створити постачальника, додати документацію і підтвердити його
    [Arguments]   ${username}   ${tender_uaid}   ${supplier_data}   ${document}

    Run Keyword If          '${procurement_method_type}' == 'negotiation'       Створити постачальника negotiation    ${username}   ${tender_uaid}   ${supplier_data}   ${document}
    Run Keyword If          '${procurement_method_type}' == 'reporting'         Створити постачальника reporting      ${username}   ${tender_uaid}   ${supplier_data}   ${document}

Створити постачальника negotiation
    [Arguments]   ${username}   ${tender_uaid}   ${supplier_data}   ${document}
    ${locality}=                            Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         locality
    ${zip_code}=                            Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         postalCode
    ${region}=                              Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         region
    ${street_address}=                      Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         streetAddress
    ${name}=                                Get From Dictionary         ${supplier_data.data.suppliers[0]}                                                 name
    ${email}=                               Get From Dictionary         ${supplier_data.data.suppliers[0].contactPoint}                                    email
    ${telephone}=                           Get From Dictionary         ${supplier_data.data.suppliers[0].contactPoint}                                    telephone
    ${identifier_id}=                       Get From Dictionary         ${supplier_data.data.suppliers[0].identifier}                                      id
    ${legal_name}=                          Get From Dictionary         ${supplier_data.data.suppliers[0].identifier}                                      legalName
    ${value_amount}=                        Get From Dictionary         ${supplier_data.data.value}                                                        amount
    ${value_amount}=                        convert to string           ${value_amount}
    ${tax}=                                 Get From Dictionary         ${supplier_data.data.value}                                                        valueAddedTaxIncluded

    sleep  1
    Wait Until Page Contains Element        xpath=//a[contains(@href, '/state_purchase/edit')]//span
    click element     xpath=//a[contains(@href, '/state_purchase/edit')]//span
    sleep  3
    click element   xpath=(//button[contains(@class, 'qa_add_winner')])[last()]
    input text  xpath=(//input[contains(@class, 'qa_input_winner_srn')])[last()]   ${identifier_id}
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_input_winner_company_name')])[last()]   ${legal_name}
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_input_winner_zip')])[last()]  ${zip_code}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_drop_down_winner_region')])[last()]
    ${region}=   Run Keyword If   '${region}'      convert_delivery_address     ${region}
    Click Element   xpath=(//li[contains(text(), '${region}')])[last()]
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_input_winner_locality')])[last()]   ${locality}
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_winner_address')])[last()]   ${street_address}
    sleep  1
    click element  xpath=(//input[contains(@class, 'qa_checkbox_data_verified')])[last()]
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_winner_amount')])[last()]   ${value_amount}
    sleep  1
    Run Keyword If  '${tax}' == 'True'   click element  xpath=(//input[contains(@class, 'qa_checkbox_pdv')])[last()]
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_winner_name')])[last()]   ${name}
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_winner_phone')])[last()]  ${telephone}
    sleep  1
    click element  xpath=(//input[contains(@class, 'qa_qualification')])[last()]
    sleep  1
    capture page screenshot
    sleep  3
    click element   css=.qa_submit_tender
    sleep  5

    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=//button[contains(@data-sign-process-url, 'state_purchase/process_signature')]
    sleep  60
    reload page
    Click Element     xpath=//button[contains(@data-sign-process-url, 'state_purchase/process_signature')]
    sleep  8
    prom.Подписание ЕЦП
    sleep  5
    click element   css=.qa_lot_button
    sleep  5
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=(//a[contains(@data-afip-url, 'state_award/active')])[1]
    click element      xpath=(//a[contains(@data-afip-url, 'state_award/active')])[1]
    sleep  3
    choose file   xpath=//form[@class="qa_winner_popup"]//input[contains(@class, 'qa_state_offer_add_field')]   ${document}
    sleep  2
    click element  xpath=//form[@class="qa_winner_popup"]//button[@id="submit_button"]
    sleep  3
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=//div[contains(@data-sign-process-url, 'state_award/process_award_signature')]
    click element  xpath=//div[contains(@data-sign-process-url, 'state_award/process_award_signature')]
    sleep  40
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Wait Until Element Is Visible       css=#CAsServersSelect
    capture page screenshot
    click element    css=#CAsServersSelect
    sleep  3
    CLICK ELEMENT    xpath=//*[contains(text(), 'АЦСК ТОВ "КС"')]
    sleep  4
    click element    css=#CAsServersSelect
    sleep  2
    ${file_path}=    get_ecp_key    src/robot_tests.broker.prom/Key-6.dat
    Choose File       css=#PKeyFileInput      ${file_path}
    sleep  3
    Input Text    css=#PKeyPassword    1234
    sleep  7
    capture page screenshot
    Click Element  css=#SignDataButton
    sleep  15

Створити постачальника reporting
    [Arguments]   ${username}   ${tender_uaid}   ${supplier_data}   ${document}

    ${locality}=                            Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         locality
    ${zip_code}=                            Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         postalCode
    ${region}=                              Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         region
    ${street_address}=                      Get From Dictionary         ${supplier_data.data.suppliers[0].address}                                         streetAddress
    ${name}=                                Get From Dictionary         ${supplier_data.data.suppliers[0]}                                                 name
    ${email}=                               Get From Dictionary         ${supplier_data.data.suppliers[0].contactPoint}                                    email
    ${telephone}=                           Get From Dictionary         ${supplier_data.data.suppliers[0].contactPoint}                                    telephone
    ${identifier_id}=                       Get From Dictionary         ${supplier_data.data.suppliers[0].identifier}                                      id
    ${legal_name}=                          Get From Dictionary         ${supplier_data.data.suppliers[0].identifier}                                      legalName
    ${value_amount}=                        Get From Dictionary         ${supplier_data.data.value}                                                        amount
    ${value_amount}=                        convert to number           ${value_amount}
    ${tax}=                                 Get From Dictionary         ${supplier_data.data.value}                                                        valueAddedTaxIncluded

     Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=//button[contains(@data-sign-template-url, 'state_purchase/signature_template')]
    click element   xpath=//button[contains(@data-sign-template-url, 'state_purchase/signature_template')]
    sleep  2
    prom.Подписание ЕЦП
    sleep  10
    capture page screenshot

    Wait Until Keyword Succeeds     30      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible         xpath=//a[contains(@href, 'state_purchase/complete')]
    click element    xpath=//a[contains(@href, 'state_purchase/complete')]
    sleep  3
    choose file    xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${document}
    sleep  3
    input text   css=#contract_number    2342345
    sleep  2

    capture page screenshot
    sleep  1
    ${time}=     date_now
    input text   xpath=//input[@id="contract_sign_date"]    ${time}
    sleep  1
    click element   xpath=//input[@id="contract_sign_date"]
    ${start_date}=          delivery_date_start
    ${end_date}=        delivery_date_end
    sleep  3
    capture page screenshot
    input text      css=#contract_period_start  ${start_date}
    sleep  3
    click element   css=#contract_period_start
    sleep  1
    input text      css=#contract_period_end  ${end_date}
    sleep  2
    click element   css=#contract_period_end
    sleep  2
    click element   css=#submit_button
    sleep  5
    capture page screenshot

Підтвердити підписання контракту
    [Arguments]    ${username}   ${tender_uaid}   ${contract_num}

    Run Keyword If          '${procurement_method_type}' == 'negotiation'       Підтвердити підписання контракту negotiation    ${username}   ${tender_uaid}   ${contract_num}
    Run Keyword If          '${procurement_method_type}' == 'reporting'         Підтвердити підписання контракту reporting      ${username}   ${tender_uaid}   ${contract_num}

Підтвердити підписання контракту negotiation
    [Arguments]    ${username}   ${tender_uaid}   ${contract_num}
    capture page screenshot

    Wait Until Page Contains Element        css=.qa_lot_button
    sleep  1
    click element   css=.qa_lot_button
    Wait Until Keyword Succeeds     30      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=//div[contains(@class, 'qa_qualification_end_date')]
    sleep  2
    capture page screenshot
    ${doc_date}=     get element attribute     xpath=//div[contains(@class, 'qa_qualification_end_date')]@data-qualification-date-end
    ${doc_date}=     tender_end_date            ${doc_date}
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible         xpath=//a[contains(@href, 'state_purchase_lot/complete')]
    click element   xpath=//a[contains(@href, 'state_purchase_lot/complete')]
    sleep  3
    ${filepath}=        create_random_file
    choose file    xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${filepath}
    sleep  3
    input text   css=#contract_number    2342345
    sleep  2
    ${value}=    get element attribute    xpath=//input[@id='contract_value_amount_net']@value
    ${value}=           convert to number        ${value}
    capture page screenshot
    ${value}=           value_percentage        ${value}
    sleep  1
    clear element text   css=#contract_value_amount_net
    sleep  1
    input text  css=#contract_value_amount_net   ${value}
    sleep  1
    input text   xpath=//input[@id="contract_sign_date"]    ${doc_date}
    sleep  1
    click element   xpath=//input[@id="contract_sign_date"]
    ${start_date}=          delivery_date_start
    ${end_date}=        delivery_date_end
    sleep  3
    input text      css=#contract_period_start  ${start_date}
    sleep  3
    click element   css=#contract_period_start
    sleep  1
    input text      css=#contract_period_end  ${end_date}
    sleep  2
    click element   css=#contract_period_end
    sleep  5
    ${href_job_contract}=     get location
    click element   css=#submit_button
    sleep  10
    ${href_lot}=     get location
    CAPTURE PAGE SCREENSHOT
    run keyword if  '${href_job_contract}' == '${href_lot}'   click element  xpath=(//a[contains(@href, 'state_purchase_lot/view')])[1]
    run keyword if  '${href_job_contract}' == '${href_lot}'   wait until element is visible  css=#contract_number

    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=//div[contains(@data-sign-process-url, 'state_award/process_contract_signature/')]
    click element  xpath=//div[contains(@data-sign-process-url, 'state_award/process_contract_signature/')]
    sleep  40
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Wait Until Element Is Visible       css=#CAsServersSelect
    capture page screenshot
    click element    css=#CAsServersSelect
    sleep  3
    CLICK ELEMENT    xpath=//*[contains(text(), 'АЦСК ТОВ "КС"')]
    sleep  4
    click element    css=#CAsServersSelect
    sleep  2
    ${file_path}=    get_ecp_key    src/robot_tests.broker.prom/Key-6.dat
    Choose File       css=#PKeyFileInput      ${file_path}
    sleep  3
    Input Text    css=#PKeyPassword    1234
    sleep  7
    capture page screenshot
    Click Element  css=#SignDataButton
    sleep  30
    capture page screenshot
    Wait Until Keyword Succeeds     150      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=//button[contains(@data-afip-url, 'state_award/sign_contract')]
    click element  xpath=//button[contains(@data-afip-url, 'state_award/sign_contract')]
    sleep  7
    click element  css=#submit_button
    sleep  10

Підтвердити підписання контракту reporting
    [Arguments]    ${username}   ${tender_uaid}   ${contract_num}

    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=//div[contains(@data-sign-process-url, 'state_award/process_contract_signature/')]
    click element  xpath=//div[contains(@data-sign-process-url, 'state_award/process_contract_signature/')]
    sleep  30
    capture page screenshot
    Wait Until Keyword Succeeds     100      5          Run Keywords
    ...   Sleep  2
    ...   AND     Wait Until Element Is Visible       css=#CAsServersSelect
    capture page screenshot
    click element    css=#CAsServersSelect
    sleep  3
    CLICK ELEMENT    xpath=//*[contains(text(), 'АЦСК ТОВ "КС"')]
    sleep  4
    click element    css=#CAsServersSelect
    sleep  2
    ${file_path}=    get_ecp_key    src/robot_tests.broker.prom/Key-6.dat
    Choose File       css=#PKeyFileInput      ${file_path}
    sleep  3
    Input Text    css=#PKeyPassword    1234
    sleep  7
    capture page screenshot
    Click Element  css=#SignDataButton
    sleep  30
    capture page screenshot

Редагувати угоду
    [Arguments]    ${username}   ${tender_uaid}   ${contract_index}    ${fieldname}    ${fieldvalue}

    Run Keyword If          '${procurement_method_type}' == 'negotiation'       Редагувати угоду negotiation          ${username}   ${tender_uaid}   ${contract_index}    ${fieldname}    ${fieldvalue}
    Run Keyword If          '${procurement_method_type}' == 'reporting'         Редагувати угоду reporting        ${username}   ${tender_uaid}   ${contract_index}    ${fieldname}    ${fieldvalue}
    sleep  2
    capture page screenshot

Редагувати угоду negotiation
    [Arguments]    ${username}   ${tender_uaid}   ${contract_index}    ${fieldname}    ${fieldvalue}

    ${value_net}=     Run Keyword If                 '${fieldname}' == 'value.amountNet'             convert to string    ${fieldvalue}
    Run Keyword If                 '${fieldname}' == 'value.amountNet'             sleep  2

    ${value}=     Run Keyword If                 '${fieldname}' == 'value.amount'             convert to string    ${fieldvalue}
    Run Keyword If                 '${fieldname}' == 'value.amount'             sleep  2
    sleep  2
    capture page screenshot

Редагувати угоду reporting
    [Arguments]    ${username}   ${tender_uaid}   ${contract_index}    ${fieldname}    ${fieldvalue}

    Wait Until Keyword Succeeds     30      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible        xpath=//a[contains(@href, 'state_purchase/complete')]
    sleep  3
    ${value_net}=     Run Keyword If                 '${fieldname}' == 'value.amountNet'             convert to string    ${fieldvalue}

    Run Keyword If                 '${fieldname}' == 'value.amountNet'             clear element text   css=#contract_value_amount_net
    Run Keyword If                 '${fieldname}' == 'value.amountNet'             sleep  2
    Run Keyword If                 '${fieldname}' == 'value.amountNet'             input text   css=#contract_value_amount_net            ${value_net}

    ${value}=     Run Keyword If                 '${fieldname}' == 'value.amount'             convert to string    ${fieldvalue}

    Run Keyword If                 '${fieldname}' == 'value.amount'             clear element text   css=#contract_value_amount
    Run Keyword If                 '${fieldname}' == 'value.amount'             sleep  2
    Run Keyword If                 '${fieldname}' == 'value.amount'             input text   css=#contract_value_amount            ${value}
    sleep  2
    capture page screenshot
    click element   css=#submit_button
    sleep  5
    capture page screenshot

################################## Claim ######################################
Створити вимогу про виправлення умов закупівлі
    [Arguments]   ${username}   ${tender_uaid}   ${claim}    ${claim document}=${None}
    log to console  *Створити вимогу про виправлення умов закупівлі*
    log to console   ${claim}
    ${title}=        Get From Dictionary  ${claim.data}   title
    ${description}=  Get From Dictionary  ${claim.data}   description

    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    sleep  2
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    reload page
    click element        xpath=//a[@data-qa="qa_apply_requirement"]
    sleep  3
    input text  css=[id="name"]                 ${title}
    sleep  1
    input text  css=[id="description"]          ${description}
    sleep  1
    Run Keyword And Ignore Error  Choose File  xpath=//input[@data-qa="upload_file"]  ${claim document}
    sleep  5
    click element   css=[data-qa="create_claim_button"]
    sleep  5
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Visible       css=[data-qa="complaint_id"]
    ${return_value}=    get text    css=[data-qa="complaint_id"]
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    sleep  10
    capture page screenshot
    log to console  *Створити вимогу про виправлення умов закупівлі*
    [Return]  ${return_value}

Скасувати вимогу про виправлення умов закупівлі
    [Arguments]   ${username}   ${tender_uaid}   ${complaintID}    ${cancellation_data}
    log to console  ****Скасувати вимогу про виправлення умов закупівлі****
    log to console   ${complaintID}
    log to console   ${cancellation_data}
    ${cancellationReason}=   Get From Dictionary  ${cancellation_data.data}   cancellationReason
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    reload page
    click element  xpath=(//p[text()='${complaintID}']//../span)
    sleep  5
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       css=[data-qa='cancel_claim']
    click element  css=[data-qa='cancel_claim']
    sleep  2
    input text  css=[id='reason']    ${cancellationReason}
    sleep  1
    click element  css=[data-qa='ok']
    sleep  2
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    sleep  2
    capture page screenshot
    log to console  ****Скасувати вимогу про виправлення умов закупівлі****

Отримати інформацію із скарги
    [Arguments]   ${username}   ${tender_uaid}   ${complaintID}    ${field_name}  ${award_index}=None
    log to console  ******Отримати інформацію із скарги*****
    log to console   ${tender_uaid}
    log to console   ${complaintID}
    log to console   ${field_name}
    sleep  60
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    sleep  5
    reload page
    sleep  5
    reload page
    sleep  5
    capture page screenshot
    ${return_value}=    Run Keyword If     '${field_name}' == 'status'                  get text    xpath=//p[text()='${complaintID}']//..//..//../td[@data-qa="status"]
    ...     ELSE IF     '${field_name}' == 'description'                                Отримати інформацію із вимоги           ${complaintID}    ${field_name}
    ...     ELSE IF     '${field_name}' == 'title'                                      Отримати інформацію із вимоги           ${complaintID}    ${field_name}
    ...     ELSE IF     '${field_name}' == 'resolution'                                 Отримати інформацію із вимоги           ${complaintID}    ${field_name}
    ...     ELSE IF     '${field_name}' == 'resolutionType'                             Отримати інформацію із вимоги           ${complaintID}    ${field_name}
    ...     ELSE IF     '${field_name}' == 'satisfied'                                  Отримати інформацію із вимоги           ${complaintID}    ${field_name}

     ${return_value}=    Run Keyword If    '${field_name}' == 'resolutionType'          convert_complaints_resolutiontype       ${return_value}
    ...     ELSE IF     '${field_name}' == 'status'                                     convert_complaints_status               ${return_value}
    ...     ELSE IF     '${field_name}' == 'satisfied'                                  convert_complaints_satisfied_status     ${return_value}
    ...     ELSE     convert_prom_string_to_common_string                                                                       ${return_value}
    click element   xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10
    [Return]  ${return_value}

Отримати інформацію із вимоги
    [Arguments]      ${complaintID}    ${field_name}
    click element   xpath=(//p[text()='${complaintID}']//../span)
    sleep  5
    reload page
    sleep  2
    ${return_value}=    Run Keyword If     '${field_name}' == 'description'         get text    css=[data-qa="description_claim"]
    ...     ELSE IF     '${field_name}' == 'title'                                  get text    css=[data-qa="title_claim"]
    ...     ELSE IF     '${field_name}' == 'resolution'                             get text    css=[data-qa="answer_comment"]
    ...     ELSE IF     '${field_name}' == 'resolutionType'                         get text    css=[data-qa="claim_status"]
    ...     ELSE IF     '${field_name}' == 'satisfied'                              get text    css=[data-qa="claim_status"]
    [Return]  ${return_value}

Отримати інформацію із документа до скарги
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${doc_id}  ${field}
    log to console  ******Отримати інформацію із документа до скарги*****
    log to console   ${username}
    log to console   ${tender_uaid}
    log to console   ${complaintID}
    log to console   ${doc_id}
    log to console   ${field}
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    Wait Until Element Is Visible     xpath=//a[@data-qa="qa_apply_requirement"]    30
    reload page
    click element   xpath=(//p[text()='${complaintID}']//../span)
    sleep  2
    ${doc_name}=  get text  css=[data-qa="files"]
    [Return]  ${doc_name}

Створити вимогу про виправлення умов лоту
    [Arguments]   ${username}   ${tender_uaid}   ${claim}    ${lot_id}   ${document}=${None}
    log to console  ***Створити вимогу про виправлення умов лоту***
    log to console   ${claim}
    ${title}=        Get From Dictionary  ${claim.data}   title
    ${description}=  Get From Dictionary  ${claim.data}   description
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    click element        xpath=//a[contains(@href,'/state_purchase_lot_complaint/lot_claims')]
    capture page screenshot
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    capture page screenshot
    reload page
    click element        xpath=//a[@data-qa="qa_apply_requirement"]
    sleep  2
    input text  css=[id="name"]                 ${title}
    sleep  1
    input text  css=[id="description"]          ${description}
    sleep  1
    Run Keyword And Ignore Error  Choose File  xpath=//input[@data-qa="upload_file"]  ${document}
    sleep  5
    click element   css=[data-qa="create_claim_button"]
    sleep  5
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Visible       css=[data-qa="complaint_id"]
    ${return_value}=    get text    css=[data-qa="complaint_id"]
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])
    Wait Until Element Is Visible   css=.qa_lot_button    10
    capture page screenshot
    log to console   ***Створити вимогу про виправлення умов лоту***
    [Return]  ${return_value}

Скасувати вимогу про виправлення умов лоту
    [Arguments]   ${username}   ${tender_uaid}   ${complaintID}    ${cancellation_data}
    log to console  ***Скасувати вимогу про виправлення умов лоту***
    log to console   ${complaintID}
    log to console   ${cancellation_data}
    ${cancellationReason}=   Get From Dictionary  ${cancellation_data.data}   cancellationReason
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    click element        xpath=(//p[text()='${complaintID}']//../span)
    sleep  2
     Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Enabled       css=[data-qa='cancel_claim']
    click element  css=[data-qa='cancel_claim']
    sleep  2
    input text  css=[id='reason']    ${cancellationReason}
    sleep  1
    click element  css=[data-qa='ok']
    sleep  2
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10
    capture page screenshot
    log to console   ***Скасувати вимогу про виправлення умов лоту***

Відповісти на вимогу про виправлення умов закупівлі
    [Arguments]   ${username}   ${tender_uaid}   ${complaintID}    ${answer_data}
    log to console  ****Відповісти на вимогу про виправлення умов закупівлі****
    log to console   ${complaintID}
    log to console   ${answer_data}
    ${answer_type}=   get from dictionary   ${answer_data.data}    resolutionType
    ${description}=   get from dictionary   ${answer_data.data}    resolution
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    Wait Until Page Contains Element     css=[data-qa="claim_tender"]    30
    click element        xpath=(//p[text()='${complaintID}']//../span)
    sleep  1
    click element  css=[data-qa="answer_claim"]
    sleep  1
    click element  css=[data-qa="answer_type_dd"]
    sleep  1
    run keyword if   '${answer_type}' == 'resolved'     click element  xpath=//div[text()='Задовольнити вимогу']
    run keyword if   '${answer_type}' == 'declined'     click element  xpath=//div[text()='Відхилити вимогу']
    run keyword if   '${answer_type}' == 'invalid'      click element  xpath=//div[text()='Відхилити вимогу як недійсну']
    sleep  1
    input text  css=[id="comment"]      ${description}
    sleep  1
    click element  xpath=(//button[@type="button"])[1]
    sleep  2
    log to console  ****Відповісти на вимогу про виправлення умов закупівлі****

Підтвердити вирішення вимоги про виправлення умов закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${confirmation_data}
    log to console  ***Підтвердити вирішення вимоги про виправлення умов закупівлі***
    log to console   ${username}
    log to console   ${tender_uaid}
    log to console   ${complaintID}
    log to console   ${confirmation_data}
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    sleep  5
    click element        xpath=(//p[text()='${complaintID}']//../span)
    sleep  3
    ${satisfied}=      get from dictionary   ${confirmation_data.data}   satisfied
    run keyword if    '${satisfied}' == 'True'  click element  css=[data-qa="qa_status_satisfied"]
    sleep  2
    ${pop_up}=  Run Keyword And Return Status    Element Should Be Visible    css=[data-qa="qa_close_claim_dialog"]
    Run Keyword If    '${pop_up}' == 'True'      click element    css=[data-qa="qa_close_claim_dialog"]
    sleep  4
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10
    log to console  ***Підтвердити вирішення вимоги про виправлення умов закупівлі***

################################## Кваліфікація ################################

Завантажити документ рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
    log to console   ***Завантажити документ рішення кваліфікаційної комісії***
    log to console   ${username}
    log to console   ${document}
    log to console   ${tender_uaid}
    log to console   ${award_num}
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    Run Keyword If  '${procurement_method_type}' == 'closeFrameworkAgreementUA'   Завантажити документ рішення кваліфікаційної комісії для closeFrameworkAgreementUA    ${document}    ${award_num}
    ...  ELSE   Завантажити документ рішення кваліфікаційної комісії для інших процедур     ${document}
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10

Скасування рішення кваліфікаційної комісії
    [Arguments]  ${username}   ${tender_uaid}  ${award_num}
    log to console  ***Скасування рішення кваліфікаційної комісії***
    log to console  ${award_num}
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
     Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       xpath=//a[contains(@data-afip-url, 'award_cancel')]
    click element    xpath=//a[contains(@data-afip-url, 'award_cancel')]
    sleep  2
    click element   css=[type="submit"]
    sleep  2

Підтвердити постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    log to console   ***Підтвердити постачальника***
    log to console   ${username}
    log to console   ${tender_uaid}
    log to console   ${award_num}
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       css=[data-sign-process-url*="state_award/process_award_signature"]
    click element  css=[data-sign-process-url*="state_award/process_award_signature"]
    sleep  4
    prom.Подписание ЕЦП
    sleep  4
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       css=[href*='state_purchase_lot/complete']
    sleep  3

Створити вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${claim}  ${award_index}  ${document}=${None}
    log to console   ***Створити вимогу про виправлення визначення переможця***
    log to console   ${username}
    log to console   ${tender_uaid}
    log to console   ${claim}
    ${title}=        Get From Dictionary    ${claim.data}               title
    ${description}=  Get From Dictionary    ${claim.data}               description
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    click element        xpath=//a[contains(@href,'/state_purchase_lot_complaint/lot_claims')]
    capture page screenshot
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    capture page screenshot
    reload page
    click element        xpath=//a[@data-qa="qa_apply_requirement"]
    sleep  2
    click element        css=.dropdownSimple__dropdownValue__1Bt3D
    sleep  2
    click element   xpath=(//div[@data-qa="dd_lists"])[last()]
    sleep  2
    input text  css=[id="name"]                 ${title}
    sleep  1
    input text  css=[id="description"]          ${description}
    sleep  1
    Run Keyword And Ignore Error  Choose File  xpath=//input[@data-qa="upload_file"]  ${document}
    sleep  5
    click element   css=[data-qa="create_claim_button"]
    sleep  5
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Visible       css=[data-qa="complaint_id"]
    ${return_value}=    get text    css=[data-qa="complaint_id"]
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])
    Wait Until Element Is Visible   css=.qa_lot_button    10
    capture page screenshot
    log to console   ***Створити вимогу про виправлення визначення переможця***
    [Return]  ${return_value}

Скасувати вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${cancellation_data}  ${award_index}
    log to console  ***Скасувати вимогу про виправлення визначення переможця***
    log to console   ${complaintID}
    log to console   ${cancellation_data}
    ${cancellationReason}=   Get From Dictionary  ${cancellation_data.data}   cancellationReason
    CLICK ELEMENT    css=.qa_lot_button
    Wait Until Element Is Visible   css=.qa_lot_title     10
    click element        xpath=//a[contains(@href,'/state_purchase_lot_complaint/lot_claims')]
    Wait Until Page Contains Element     xpath=//a[@data-qa="qa_apply_requirement"]    30
    click element        xpath=(//p[text()='${complaintID}']//../span)
    sleep  2
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   1
    ...   AND     Wait Until Element Is Enabled       css=[data-qa='cancel_claim']
    click element  css=[data-qa='cancel_claim']
    sleep  2
    input text  css=[id='reason']    ${cancellationReason}
    sleep  1
    click element  css=[data-qa='ok']
    sleep  2
    click element  xpath=(//a[contains(@href,'cabinet/purchases/state_purchase/view')])[1]
    Wait Until Element Is Visible   css=.qa_lot_button    10
    capture page screenshot
    log to console   ***Скасувати вимогу про виправлення визначення переможця***

Відповісти на вимогу про виправлення визначення переможця
    [Arguments]  ${username}  ${tender_uaid}  ${complaintID}  ${answer_data}  ${award_index}
    log to console   ***Відповісти на вимогу про виправлення визначення переможця***
    log to console   ${username}
    log to console   ${tender_uaid}
    log to console   ${complaintID}
    log to console   ${answer_data}
    log to console   ${complaintID}
    ${answer_type}=   get from dictionary   ${answer_data.data}    resolutionType
    ${description}=   get from dictionary   ${answer_data.data}    resolution
    click element        xpath=//a[contains(@href,'/state_purchase_complaint/purchase_claims')]
    Wait Until Page Contains Element     css=[data-qa="claim_tender"]    30
    click element        xpath=(//p[text()='${complaintID}']//../span)
    sleep  1
    click element  css=[data-qa="answer_claim"]
    sleep  1
    click element  css=[data-qa="answer_type_dd"]
    sleep  1
    run keyword if   '${answer_type}' == 'resolved'     click element  xpath=//div[text()='Задовольнити вимогу']
    run keyword if   '${answer_type}' == 'declined'     click element  xpath=//div[text()='Відхилити вимогу']
    run keyword if   '${answer_type}' == 'invalid'      click element  xpath=//div[text()='Відхилити вимогу як недійсну']
    sleep  1
    input text  css=[id="comment"]      ${description}
    sleep  1
    click element  xpath=(//button[@type="button"])[1]
    sleep  2

###############################################################################
Отримати qualificationPeriod.endDate
    log to console  ***Отримати qualificationPeriod.endDate***
    ${return_value}=  run keyword if  '${procurement_method_type}' == 'closeFrameworkAgreementUA'   Get Element Attribute   xpath=//span[contains(@class, 'qa_qualification_period')]//span[contains(@class, 'qa_date_time_end')]@data-period-date-end
    ...  ELSE  Get Element Attribute   xpath=//dd[contains(@class, ' qa_date_period_clarifications')]//span[contains(@class, 'qa_date_time_end')]@data-period-date-end
    log to console  ${return_value}
    [Return]  ${return_value}

Завантажити документ рішення кваліфікаційної комісії для closeFrameworkAgreementUA
    [Arguments]  ${document}    ${award_num}
    log to console  ***Завантажити документ рішення кваліфікаційної комісії для closeFrameworkAgreementUA***
    Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       xpath=//button[@data-qa="award_confirm"]

    run keyword if   '${award_num}' == '0'      Підтвердити першого Аварда      ${document}
    ...   ELSE IF    '${award_num}' == '1'      Підтвердити другого Аварда      ${document}
    ...   ELSE                                  Підтвердити третього Аварда     ${document}

    ${award1}=      Get Element Attribute     xpath=(//button[@data-qa="award_confirm"])[1]/../..//div[@data-qa-award]@data-qa-award
    ${award2}=      Get Element Attribute     xpath=(//button[@data-qa="award_confirm"])[2]/../..//div[@data-qa-award]@data-qa-award
    ${award3}=      Get Element Attribute     xpath=(//button[@data-qa="award_confirm"])[3]/../..//div[@data-qa-award]@data-qa-award

Підтвердити першого Аварда
    [Arguments]  ${document}
    sleep  2
    log to console  ***Підтвердити першого Аварда***
    click element    xpath=//button[@data-qa="award_confirm" and //div[@data-qa-award="${award1}"]]
    sleep  2
    Choose File      xpath=//div[@data-qa-award="${award1}"]//input[@data-qa="upload_file"]     ${document}
    sleep  5
    click element    css=.qa_type_file
    sleep  2
    click element    xpath=//div[text()='Протокол розгляду']
    sleep  3
    click element    xpath=//div[@data-qa-award="${award1}"]//button[@data-qa="ok"]
    sleep  5

Підтвердити другого Аварда
    [Arguments]  ${document}
    sleep  2
    log to console  ***Підтвердити другого Аварда***
    click element    xpath=//button[@data-qa="award_confirm" and //div[@data-qa-award="${award2}"]]
    sleep  2
    Choose File      xpath=//div[@data-qa-award="${award2}"]//input[@data-qa="upload_file"]     ${document}
    sleep  5
    click element    css=.qa_type_file
    sleep  2
    click element    xpath=//div[text()='Протокол розгляду']
    sleep  3
    click element    xpath=//div[@data-qa-award="${award2}"]//button[@data-qa="ok"]
    sleep  5

Підтвердити третього Аварда
    [Arguments]  ${document}
    sleep  2
    log to console  ***Підтвердити третього Аварда***
    click element    xpath=//button[@data-qa="award_confirm" and //div[@data-qa-award="${award3}"]]
    sleep  2
    Choose File      xpath=//div[@data-qa-award="${award3}"]//input[@data-qa="upload_file"]     ${document}
    sleep  5
    click element    css=.qa_type_file
    sleep  2
    click element    xpath=//div[text()='Протокол розгляду']
    sleep  3
    click element    xpath=//div[@data-qa-award="${award3}"]//button[@data-qa="ok"]
    sleep  5

Завантажити документ рішення кваліфікаційної комісії для інших процедур
     [Arguments]  ${document}
     log to console  ***Завантажити документ рішення кваліфікаційної комісії для інших процедур***
     Wait Until Keyword Succeeds     300      10          Run Keywords
    ...   Sleep  3
    ...   AND     Reload Page
    ...   AND     sleep   2
    ...   AND     Wait Until Element Is Enabled       css=[data-afip-url*="/cabinet/purchases/state_award/active"]
    click element    css=[data-afip-url*="/cabinet/purchases/state_award/active"]
    sleep  2
    Choose File      css=.qa_state_offer_add_field    ${document}
    sleep  7
    click element    css=.qa_type_file
    sleep  7
    click element    xpath=//div[text()='Протокол розгляду']
    sleep  3
    click element    css=[id="submit_button"]
    sleep  4
