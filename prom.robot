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
    ...    ELSE IF  '${role_name}' == 'tender_owner'    adapt_owner     ${tender_data}
    ...    ELSE IF  '${role_name}' == 'provider'     adapt_provider     ${tender_data}
    [Return]  ${adapted_data}

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

Створити план
    [Arguments]   ${username}    ${plan_data}
    go to  ${USERS.users['${username}'].state_plan_page}
    sleep  1
    Click Element   xpath=(//a[contains(@href, 'state_plan/add')])[1]
    Sleep  2

    ${procurement_method_type}=         Get From Dictionary             ${plan_data.data.tender}                        procurementMethodType
    ${description}=                     Get From Dictionary             ${plan_data.data.budget}                        description
    ${amount}=                          Get From Dictionary             ${plan_data.data.budget}                        amount
    ${classification}=                  Get From Dictionary             ${plan_data.data.classification}                id

    Wait Until Page Contains Element        css=#state_plan_purchase_method_type_dd    20
    CLICK ELEMENT       css=#state_plan_purchase_method_type_dd
    sleep  2
    log to console  .
    log to console  ------------------------------
    log to console  ${procurement_method_type}
    log to console  ------------------------------
    ${name}=   Run Keyword If   '${procurement_method_type}' == 'aboveThresholdEU'          Click Element    xpath=(//li[@data-value="aboveThresholdEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                Click Element    xpath=(//li[@data-value="belowThreshold"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'openeu'                        Click Element    xpath=(//li[@data-value="aboveThresholdEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA'              Click Element    xpath=(//li[@data-value="aboveThresholdUA"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'reporting'                     Click Element    xpath=(//li[@data-value="reporting"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation'                   Click Element    xpath=(//li[@data-value="negotiation"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'negotiation_quick'             Click Element    xpath=(//li[@data-value="negotiation_quick"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueUA'         Click Element    xpath=(//li[@data-value="competitiveDialogueUA"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'competitiveDialogueEU'         Click Element    xpath=(//li[@data-value="competitiveDialogueEU"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'closeFrameworkAgreementUA'     Click Element    xpath=(//li[@data-value="closeFrameworkAgreementUA"])[last()]
    ...      ELSE IF        '${procurement_method_type}' == 'centralizedProcurement'        Click Element    xpath=(//li[@data-value="centralizedProcurement"])[last()]
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

    # публикуем план
    CLICK ELEMENT  css=#submit_button
    ${tender_uaid}=     get text     css=.qa_plan_uid
    ${tender_uaid}=    Run Keyword If   '${tender_uaid}' == 'очікування...'    Run Keywords
    ...    Sleep  20
    ...    AND    Reload page
    ...    AND    Sleep  3
    ${tender_uaid}=     get text     css=.qa_plan_uid
    ${access_token}=    Get Variable Value    ${tender_uaid.access.token}
    Set To Dictionary   ${USERS.users['${username}']}    access_token=${access_token}
    log to console  *******plan_id*********
    log to console  ${tender_uaid}
    log to console  ****************
    [Return]    ${tender_uaid}

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
    Click Element     xpath=(//div[@data-classifier-code="dk021"]//span)[last()]
    sleep  1
    input text  css=.qa_search_input                        ${item_classification_id}
    sleep  1
    Click Element  css=[class="b-checkbox__input"]
    sleep  2
    Click Element  css=.qa_submit
    sleep  1

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

Пошук плану по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    log to console  .
    log to console  ${tender_uaid}
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].state_plan_page}
    sleep    3
    ${href}=    Get Location
    Run Keyword If  '${href}' in 'https://zk-kub.olympus.evo/signin'  Run Keywords
    ...   Input Text             ${login_sign_in}          ${USERS.users['${username}'].login}
    ...   AND    Input Text      ${password_sign_in}       ${USERS.users['${username}'].password}
    ...   AND    Click Button    id=submit_button
    ...   AND    Sleep   2
    Go to   ${USERS.users['${username}'].state_plan_page}
    sleep   3
    sleep   3
    Wait Until Page Contains Element      css=#search     15
    Input Text         css=#search   ${tender_uaid}
    log to console    ${tender_uaid}
    Sleep  2
    Click Element     css=[type="submit"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=(//tr[contains(@class, 'qa_plan_list')]//td[contains(@class, 'qa_item_name')]//a)[1]
    Click Element     xpath=(//tr[contains(@class, 'qa_plan_list')]//td[contains(@class, 'qa_item_name')]//a)[1]
    Sleep  2

Оновити сторінку з планом
    [Arguments]   ${username}    ${tender_uaid}
    Switch Browser    my_custom_alias
    sleep  1
    Reload Page
    sleep  2

Створити тендер
    [Arguments]   ${username}    ${tender_data}
    log to console      @@@@@@@@@@@@@@@@@@@@@@@@@@
    log to console   ${tender_data}
    log to console      @@@@@@@@@@@@@@@@@@@@@@@@@@
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
    ${endDate}=                      convert_iso_date_to_prom       ${endDate}
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

    ${milestones}=                      Get From Dictionary         ${tender_data.data}                                         milestones

    ${items}=                           Get From Dictionary         ${tender_data.data}                                         items


    Go to                                ${USERS.users['${username}'].default_page}
    Sleep  1
    Wait Until Page Contains Element     css=.qa_button_add_new_purchase     20
    Click Element                        css=.qa_button_add_new_purchase
    Wait Until Page Contains Element     css=.qa_multilot_type_drop_down     20
    Click Element                        css=.qa_multilot_type_drop_down
    sleep  2

    LOG TO CONSOLE  ??????????????????????????????????
    LOG TO CONSOLE  ${procurement_method_type}
    LOG TO CONSOLE  ??????????????????????????????????
    Run Keyword If          '${procurement_method_type}' == 'aboveThresholdEU'              Click Element    xpath=//span[text()='Відкриті торги з публікацією англійською мовою']
    ...      ELSE IF        '${procurement_method_type}' == 'belowThreshold'                Click Element    xpath=//span[text()='Допорогова закупівля']
    ...      ELSE IF        '${procurement_method_type}' == 'aboveThresholdUA'              Click Element    xpath=//span[text()='Відкриті торги']
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
    log to console  !!!!!!!!!!!!!!!!!!!!!!
    log to console  ${mainprocurementcategory}
    log to console  !!!!!!!!!!!!!!!!!!!!!!
    Run Keyword If          '${mainprocurementcategory}' == 'goods'             Click Element    xpath=//span[text()='товари']
    ...      ELSE IF        '${mainprocurementcategory}' == 'services'          Click Element    xpath=//span[text()='послуги']
    ...      ELSE IF        '${mainprocurementcategory}' == 'works'             Click Element    xpath=//span[text()='роботи']
    ...      ELSE           '${mainprocurementcategory}' == 'dima Banan'        Click Element    xpath=//span[text()='роботи']

    sleep  3

    ####################ТУТ ЛАЖА###################
    click element  xpath=(//div[contains(@class, 'qa_language')])[2]
    sleep  2
    ${test_name}=   set variable    'test test'
    input text     xpath=//input[contains(@class, 'qa_contact_name undefined')]          ${test_name}

    #заполнение Англ данных
    input text  xpath=//input[contains(@class, 'qa_name_in_en')]    ${name_en}
    sleep  1
    #Наверстать локаторы #### НЕ РАБОТАЕТ ######
#    CLICK ELEMENT  xpath=(//span[@class="b-drop-down__value"])[5]
#    sleep  1
#    # Наверстать локаторы
#    Run Keyword If          '${availableLanguage}' == 'en'              Click Element    xpath=(//li[text()='English'])[2]
#    ...      ELSE IF        '${availableLanguage}' == 'ru'              Click Element    xpath=(//li[text()='русский'])[2]


    #################Інформація про закупівлю на разных языках #############################

    input text     css=.qa_tender_title          ${title}
    sleep  2
    click element  xpath=(//div[contains(@class, 'qa_language')])[3]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_title undefined')]         ${title_en}
    sleep  1
    input text     css=.qa_tender_description    ${description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language')])[4]
    sleep  3
    input text     xpath=//textarea[contains(@class, 'qa_tender_description undefined')]    ${description_en}


    Run Keyword If  '${tax}' == 'true'   select checkbox  css=.qa_multilot_tax_included

    input text     css=.qa_multilot_end_period_adjustments       ${endDate}

    #############################Добавление лота#######################################

    input text  css=.qa_lot_title                                    ${lots_title}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language')])[5]
    sleep  2
    input text  xpath=//textarea[contains(@class, 'qa_lot_title undefined')]      ${lots_title}
    sleep  2
    input text  css=.qa_lot_description   ${lots_description}
    click element  xpath=(//div[contains(@class, 'qa_language')])[6]

    input text  xpath=//textarea[contains(@class, 'qa_lot_description undefined')]   ${lots_description}

    input text  css=.qa_multilot_tender_lot_bugdet        ${lots_amount}

    input text  css=.qa_multilot_tender_step_auction_rate            ${lots_minimalstep}

    #############################Добавление milestones(Додати умови оплати)#######################################

    ${number_of_milestones}=      Get Length                      ${milestones}
    set global variable                                           ${number_of_milestones}
    :FOR  ${index}  IN RANGE  ${number_of_milestones}
    \  Run Keyword If  '${index}' != '0'   Click Element     xpath=(//a[contains(@class, 'qa_add_new_milestone')])[last()]
    \  Додати умови оплати    ${milestones[${index}]}

    sleep  2

    #############################Добавление Items#######################################

    ${number_of_items}=  Get Length  ${items}
    set global variable    ${number_of_items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_add_button
    \  Додати айтем тендера    ${items[${index}]}



Додати умови оплати
    [Arguments]   ${milestones}
    ${title}=           Get From Dictionary    ${milestones}                title
    ${code}=            Get From Dictionary    ${milestones}                code
    ${days}=            Get From Dictionary    ${milestones.duration}       days
    ${type}=            Get From Dictionary    ${milestones.duration}       type
    ${percentage}=      Get From Dictionary    ${milestones}                percentage

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
    sleep  1
    ${code}=  Run Keyword If    '${code}' == 'prepayment'               Click Element    xpath=(//li[text()="післяоплата"])[last()]
    ...      ELSE IF            '${code}' == 'postpayment'              Click Element    xpath=(//li[text()="аванс"])[last()]
    sleep  2
    input text   xpath=(//input[contains(@class, 'qa_milestone_duration_days')])[last()]    ${days}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_milestone_duration_type')])[last()]
    sleep  2
    ${type}=  Run Keyword If   '${type}' == 'calendar'               Click Element    xpath=(//li[text()="календарні"])[last()]
    ...      ELSE IF           '${type}' == 'working'                Click Element    xpath=(//li[text()="робочі"])[last()]
    ...      ELSE IF           '${type}' == 'banking'                Click Element    xpath=(//li[text()="банківські"])[last()]
    sleep  1
    input text  xpath=(//input[contains(@class, 'qa_milestone_percentage')])[last()]    ${percentage}
    sleep  1

Додати айтем тендера
    [Arguments]   ${items}
    ${item_classification_description}=         Get From Dictionary             ${items.classification}           description
    ${item_classification_id}=                  Get From Dictionary             ${items.classification}           id
    ${item_classification_scheme}=              Get From Dictionary             ${items.classification}           scheme
    ${delivery_country}=                        Get From Dictionary             ${items.deliveryAddress}          countryName
    ${delivery_country_en}=                     Get From Dictionary             ${items.deliveryAddress}          countryName_en
    ${delivery_country_ru}=                     Get From Dictionary             ${items.deliveryAddress}          countryName_ru
    ${delivery_locality}=                       Get From Dictionary             ${items.deliveryAddress}          locality
    ${delivery_postalCode}=                     Get From Dictionary             ${items.deliveryAddress}          postalCode
    ${delivery_region}=                         Get From Dictionary             ${items.deliveryAddress}          region
    ${delivery_street}=                         Get From Dictionary             ${items.deliveryAddress}          streetAddress
    ${delivery_end}=                            Get From Dictionary             ${items.deliveryDate}             endDate
    ${delivery_start}=                          Get From Dictionary             ${items.deliveryDate}             startDate
    ${item_description}=                        Get From Dictionary             ${items}                          description
    ${item_description_en}=                     Get From Dictionary             ${items}                          description_en
    ${item_description_ru}=                     Get From Dictionary             ${items}                          description_ru
    ${item_quantity}=                           Get From Dictionary             ${items}                          quantity
    ${item_quantity}=                           Convert To String               ${item_quantity}
    ${unit_code}=                               Get From Dictionary             ${items.unit}                     code
    ${unit_name}=                               Get From Dictionary             ${items.unit}                     name

    input text    xpath=(//textarea[contains(@class, 'qa_item_description')])[last()]    ${item_description}
    sleep  1
    click element  xpath=(//div[contains(@class, 'qa_language')])[7]
    sleep  1
    input text    xpath=(//textarea[contains(@class, 'qa_item_description undefined')])[last()]   ${item_description_en}
    sleep  1
    input text    xpath=(//input[contains(@class, 'qa_multilot_tender_quantity_product')])[last()]      ${item_quantity}
    sleep  1
    Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]
    sleep  1
    ${name}=   Run Keyword If   '${unit_name}' == 'штуки'            Click Element    xpath=//li[text()='штука'][1]
    ...      ELSE IF            '${unit_name}' == 'упаковка'         Click Element    xpath=//li[text()='упаковка']
    ...      ELSE IF            '${unit_name}' == 'кілограми'        Click Element    xpath=//li[text()='кілограм']
    ...      ELSE IF            '${unit_name}' == 'набір'            Click Element    xpath=//li[text()='набір']
    ...      ELSE IF            '${unit_name}' == 'лот'              Click Element    xpath=//li[text()='лот']
    ...      ELSE               '${unit_name}' == 'pct'              Click Element    xpath=//li[text()='ампула']
    sleep  1
    click element   xpath=(//a[contains(@class, 'qa_multilot_tender_dk_classifier')])[last()]
    sleep  1
    input text      css=.qa_classifier_popup .qa_search_input          ${item_classification_id}
    sleep  1
    click element   css=.qa_classifier_popup [type="checkbox"]
    sleep  1
    CLICK ELEMENT   css=.qa_classifier_popup .qa_submit span
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_address')])[last()]         ${delivery_street}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_locality')])[last()]        ${delivery_locality}
    sleep  1
    input text      xpath=(//input[contains(@class, 'qa_multilot_tender_zip_code')])[last()]        ${delivery_postalCode}
    sleep  1
    click element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]
    sleep  1
    log to console  ~~~~~~~1~~~~~~
    log to console  ${delivery_region}
    log to console  ~~~~~~~~~~~~~
    ${delivery_region}=   Run Keyword If   '${delivery_region}' != 'місто Київ'    remove string     ${delivery_region}  ' область'
    ...    ELSE IF  '${delivery_region}' != 'містоКиїв'    remove string     ${delivery_region}    'місто'
    ...    ELSE    remove string     ${delivery_region}    'місто '
    log to console  ~~~~~~2~~~~~~~
    log to console  ${delivery_region}
    log to console  ~~~~~~~~~~~~~
    Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]//li[contains(text(), '${delivery_region}')]
    sleep  1
    click element   css=.qa_submit_tender


Можливість знайти тендер по ідентифікатору
    [Arguments]    ${username}    ${tender_uaid}
    log to console  .
    log to console  ${tender_uaid}
    Switch Browser    my_custom_alias
    Go to   ${USERS.users['${username}'].default_page}
    sleep    3
    ${href}=    Get Location
    Run Keyword If  '${href}' in 'https://zk-kub.olympus.evo/signin'  Run Keywords
    ...   Input Text             ${login_sign_in}          ${USERS.users['${username}'].login}
    ...   AND    Input Text      ${password_sign_in}       ${USERS.users['${username}'].password}
    ...   AND    Click Button    id=submit_button
    ...   AND    Sleep   2
    Go to   ${USERS.users['${username}'].default_page}
    sleep   3
    Wait Until Page Contains Element      css=#search     15
    Input Text         css=#search   ${tender_uaid}
    log to console    ${tender_uaid}
    Sleep  2
    Click Element     css=[type="submit"]
    Wait Until Keyword Succeeds     40      5          Run Keywords
    ...   Sleep  2
    ...   AND     Reload Page
    ...   AND     Sleep  2
    ...   AND     Wait Until Element Is Visible       xpath=(//tr[contains(@class, 'qa_purchase_result')]//div[contains(@class, 'qa_name')]//a)[1]
    Click Element     xpath=(//tr[contains(@class, 'qa_purchase_result')]//div[contains(@class, 'qa_name')]//a)[1]
    Sleep  2

