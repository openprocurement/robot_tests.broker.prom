*** Settings ***
Library   Selenium2Screenshots
Library   String
Library   DateTime
Library   Selenium2Library
Library   Collections
Library   prom_service.py


*** Variables ***
${sign_in}                                                      css=.qa_entrance_btn
${login_sign_in}                                                id=phone_email
${password_sign_in}                                             id=password
${locator.title}                                                css=.qa_auction_title
${locator.status}                                               css=.qa_auction_status
${locator.description}                                          css=.qa_auction_lot_descr
${locator.minimalStep.amount}                                   css=.qa_bid_step
${locator.minimalStep}                                          css=.qa_quantity
${locator.value.amount}                                         css=.qa_bid
${locator.tenderId}                                             css=.qa_ua_ea_id
${locator.procuringEntity.name}                                 css=.qa_merchant_name
${locator.auctionPeriod.startDate}                              css=.qa_date_time_auction
${locator.auctionPeriod.endDate}                                css=.qa_date_time_auction
${locator.enquiryPeriod.startDate}                              css=.qa_date_time_auction
${locator.enquiryPeriod.endDate}                                css=.qa_date_period_clarifications
${locator.tenderPeriod.startDate}                               css=.qa_date_submission_of_proposals
${locator.tenderPeriod.endDate}                                 css=.qa_date_submission_of_proposals
${locator.items[0].quantity}                                    css=.qa_quantity
${locator.items[0].description}                                 css=.qa_item_short_descr
${locator.items[0].unit.code}                                   css=.qa_quantity
${locator.items[0].unit.name}                                   css=.qa_quantity
${locator.items[0].deliveryAddress.postalCode}                  css=.qa_address_delivery
${locator.items[0].deliveryAddress.countryName}                 css=.qa_address_delivery
${locator.items[0].deliveryAddress.region}                      css=.qa_address_delivery
${locator.items[0].deliveryAddress.locality}                    css=.qa_address_delivery
${locator.items[0].deliveryAddress.streetAddress}               css=.qa_address_delivery
${locator.items[0].classification.scheme}                       css=.qa_classifier_scheme
${locator.items[0].classification.id}                           css=.qa_classifier_code
${locator.items[0].classification.description}                  css=.qa_classifier_name
${locator.questions[0].title}                                   css=.qa_message_title
${locator.questions[0].description}                             css=.qa_message_description
${locator.questions[0].date}                                    css=.qa_question_date
${locator.questions[0].answer}                                  css=.zk-question__answer-body
${locator.bids}                                                 css=.qa_offer_price
${locator.dgf}                                                  css=.qa_auction_descr

*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Prom_provider1'   Login   ${ARGUMENTS[0]}

Підготувати дані для оголошення тендера
  [Arguments]  ${username}   ${tender_data}    ${role_name}
  ${tender_data}=    adapt_procuringEntity   ${tender_data}
  ${tender_data}=    adapt_item   ${tender_data}  ${role_name}
  [Return]  ${tender_data}

Підготувати дані для оголошення тендера користувачем
  [Arguments]   ${username}      ${tender_data}      ${role_name}
  [Documentation]  Відключити створення тендеру в тестовому режимі
  ${tender_data}=     Run keyword if    '${role_name}' == 'viewer' or '${role_name}' == 'tender_owner' or '${role_name}' == 'provider' or '${role_name}' == 'provider1'
  ...       adapt_test_mode   ${tender_data}
  [Return]      ${tender_data}


Login
  [Arguments]  @{ARGUMENTS}
  Click Element   ${sign_in}
  Sleep   1
  Clear Element Text   id=phone_email
  Input text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
  Input text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Button    id=submit_button
  Sleep   2

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
    ${title}=                Get From Dictionary         ${ARGUMENTS[1].data}             title
    ${dgf}=                  Get From Dictionary         ${ARGUMENTS[1].data}             dgfID
    ${description}=          Get From Dictionary         ${ARGUMENTS[1].data}             description
    ${budget}=               Get From Dictionary         ${ARGUMENTS[1].data.value}       amount
    ${currency}=                            Get From Dictionary         ${ARGUMENTS[1].data.value}              currency
    ${valueAddedTaxIncluded}=               Get From Dictionary         ${ARGUMENTS[1].data.value}              valueAddedTaxIncluded
    ${step_rate}=                           Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}        amount
    ${start_day_auction}=                   get_all_prom_dates          ${ARGUMENTS[1]}                         StartDate
    ${items}=                Get From Dictionary         ${ARGUMENTS[1].data}             items
    ${item0}=                Get From List               ${items}                         0
    ${descr_lot}=            Get From Dictionary         ${items[0]}                      description
    ${quantity}=             Get From Dictionary         ${items[0]}                      quantity
    ${unit}=                 Get From Dictionary         ${items[0].unit}                 name
    ${cav_id}=               Get From Dictionary         ${items[0].classification}       id
    ${postalCode}=           Get From Dictionary         ${items[0].deliveryAddress}      postalCode
    ${locality}=             Get From Dictionary         ${items[0].deliveryAddress}      locality
    ${streetAddress}=        Get From Dictionary         ${items[0].deliveryAddress}      streetAddress

    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]    20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]     20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]
    Wait Until Page Contains Element     css=.qa_multilot_title       20
    Input text                           css=.qa_multilot_title               ${title}
    Input text                           css=.qa_multilot_dgf_id              ${dgf}
    Input text                           css=.qa_multilot_descr               ${description}
    ${budget}=        Convert To String                                 ${budget}
    Input text        id=qa_currency_input                              ${budget}
    ${step_rate}=        Convert To String                              ${step_rate}
    Input text        css=.qa_singlelot_tender_step_auction_rate        ${step_rate}
    Click Element     css=.qa_multilot_tax_included
    Input text        css=.qa_singlelot_end_period_adjustments          ${start_day_auction}
    Sleep   1
    Press Key         css=.qa_singlelot_end_period_adjustments            \\13
    Input text        css=.qa_multilot_tender_descr_product             ${descr_lot}
    Input text        css=.qa_multilot_tender_quantity_product          ${quantity}
    Click Element     css=.qa_multilot_tender_drop_down_product
    Run Keyword If    '${unit}' in ['метри квадратні', 'метры квадратные']   Click Element   xpath=//div[contains(@class, 'qa_multilot_tender_drop_down_product')]//li[contains(@data-reactid, '$15')]
    ...    ELSE IF    '${unit}' == 'штуки'     Click Element   xpath=//div[contains(@class, 'qa_multilot_tender_drop_down_product')]//li[contains(@data-reactid, '$14')]
    ...    ELSE
    ...    Click Element   xpath=//div[contains(@class, 'qa_multilot_tender_drop_down_product')]//li[contains(@data-reactid, '$2')]
    Click Element     css=.qa_multilot_tender_cav_classifier
    Wait Until Page Contains Element    css=.qa_search_input    20
    Click Element     css=.qa_search_input
    Input text        css=.qa_search_input    ${cav_id}
    Press Key         css=.qa_search_input            \\13
    sleep    1
    Click Element     css=.qa_dkpp_classifier_block .b-checkbox__input
    Click Element     css=.qa_submit_dkpp_block
    Sleep    1
    Click Element     css=.qa_multilot_tender_drop_down_region
    sleep    2
    Click Element     xpath=//div[contains(@class, 'qa_multilot_tender_drop_down_region')]//li[contains(@data-reactid, '$9')]
    Input text        css=.qa_multilot_tender_zip_code      ${postalCode}
    Input text        css=.qa_multilot_tender_locality      ${locality}
    Input text        css=.qa_multilot_tender_address       ${streetAddress}
    Click Button      css=.qa_multilot_tender_submit_button
    Sleep   3
    Wait Until Page Does Not Contain        очікування...         1000
    Reload Page
    ${TENDER}=     Get Text        css=.qa_ua_ea_id
    log to console      ${TENDER}
    [Return]    ${TENDER}

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
  Wait Until Page Contains Element      id=search           10
  Input Text      id=search       ${ARGUMENTS[2]}
  Sleep   3
  Click Button    xpath=//button[@type='submit']
  Wait Until Page Contains Element      css=[class*='qa_procurement_name_in_list']      10
  Click Element   css=[class*='qa_procurement_name_in_list']
  Sleep   1
  Click Element   css=[href*='state_auction/edit/']
  Sleep   1
  Choose File     xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${ARGUMENTS[1]}
  Sleep   2
  Click Button     id=submit_button
  Sleep   3

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
  Wait Until Page Contains Element      id=search           10
  Sleep  10
  Input Text        id=search     ${ARGUMENTS[1]}
  log to console    ${ARGUMENTS[1]}
  Sleep  2
  Click Element     css=#js-cabinet_search_form button
  Wait Until Page Contains Element      xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]         10
  CLICK Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
  Sleep  1

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
  prom.Пошук тендера по ідентифікатору
  Wait Until Page Contains Element      css=[href*=state_auction_question]
  Click Element     css=[href*=state_auction_question]
  Sleep   15
  Click Element     css=.qa_ask_a_question
  Wait Until Page Contains Element    name=title    20
  Input text                          name=title                 ${title}
  Input text                          xpath=//textarea[@name='description']           ${description}
  Click Element                       id=submit_button
  Wait Until Page Contains Element            css=.qa_ask_a_question     30
  capture page screenshot

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    prom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  item_id
  ...      ${ARGUMENTS[3]} ==  field_name
  ${return_value}=  Run Keyword And Return  prom.Отримати інформацію із тендера  ${username}  ${tender_uaid}  ${field_name}
  [Return]  ${return_value}

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  fieldname
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[2]}
  [Return]  ${return_value}

Отримати тест із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [Return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати тест із поля і показати на сторінці   title
  [Return]  ${return_value}

Отримати інформацію про dgfID
  ${return_value}=   Отримати тест із поля і показати на сторінці   dgf
  [Return]  ${return_value}

Отримати інформацію про status
  Sleep  5
  Reload Page
  ${return_value}=    Отримати тест із поля і показати на сторінці   status
  ${return_value}=    convert_prom_string_to_common_string   ${return_value}
  [Return]  ${return_value}

Отримати інформацію про description
  ${return_value}=    Отримати тест із поля і показати на сторінці   description
  [Return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=    Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=    Remove String      ${return_value}     грн. з ПДВ
  ${return_value}=    Convert To Number   ${return_value.replace(' ','').replace(',','.')}
  [Return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=    Отримати тест із поля і показати на сторінці   minimalStep.amount
  ${return_value}=    Remove String      ${return_value}     грн.
  ${return_value}=    Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [Return]   ${return_value}

Отримати інформацію про minimalStep
  ${return_value}=    Отримати тест із поля і показати на сторінці   minimalStep
  ${return_value}=    Convert To Number   ${return_value.split(' ')[0]}
  [Return]   ${return_value}

Внести зміни в тендер
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  ${tender}=  prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Set_To_Object  ${tender.data}   ${fieldname}   ${fieldvalue}
  ${procurementMethodType}=  Get From Object  ${tender.data}  procurementMethodType
  Run Keyword If  '${procurementMethodType}' == 'aboveThresholdUA' or '${procurementMethodType}' == 'aboveThresholdEU'
  ...      Remove From Dictionary  ${tender.data}  enquiryPeriod
  ${tender}=  set_access_key  ${tender}  ${USERS.users['${username}'].access_token}
  ${tender}=  Call Method  ${USERS.users['${username}'].client}  patch_tender  ${tender}
  Set_To_Object   ${USERS.users['${username}'].tender_data}   ${fieldname}   ${fieldvalue}

Отримати інформацію про items[0].quantity
  ${return_value}=    Отримати тест із поля і показати на сторінці   items[0].quantity
  ${return_value}=    Convert To Number   ${return_value.split(' ')[0]}
  [Return]  ${return_value}


Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.code
  ${return_value}=   Convert To String     ${return_value.split(' ')[1]}
  ${return_value}    convert_prom_code_to_common_string        ${return_value}
  [Return]  ${return_value}


Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.name
  ${return_value}=   Convert To String     ${return_value.split(' ')[1]}
  ${return_value}=   convert_prom_string_to_common_string     ${return_value}
  [Return]   ${return_value}

Отримати інформацію про value.currency
  ${return_value}=   Отримати тест із поля і показати на сторінці  minimalStep.amount
  ${return_value}=   Convert To String     ${return_value.split(',')[1].split(' ')[1]}
  ${return_value}=   convert_prom_string_to_common_string      ${return_value}
  [Return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Convert To String     ${return_value.split('.')[1]}
  ${return_value}=   convert_prom_string_to_common_string      ${return_value}
  [Return]   ${return_value}

Отримати інформацію про auctionId
  ${return_value}=   Отримати тест із поля і показати на сторінці   tenderId
  [Return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   procuringEntity.name
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.latitude
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].deliveryLocation.latitude
  ${return_value}=   convert to number   ${return_value.split(' ')[1]}
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryLocation.longitude
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].deliveryLocation.longitude
  ${return_value}=   convert to number    ${return_value.split(' ')[0]}
  [Return]  ${return_value}

Отримати інформацію про auctionPeriod.startDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  auctionPeriod.startDate
  ${return_value}=    convert_date_prom      ${return_value}
  [Return]    ${return_value}

Отримати інформацію про auctionPeriod.endDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  auctionPeriod.endDate
  ${return_value}=    convert_date_to_prom_tender_enddate    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=    convert_date_to_prom_tender_startdate      ${return_value}
  [Return]    ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=    convert_date_to_prom_tender_enddate    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про enquiryPeriod.endDate
  Fail   Дане поле відсутнє на dz-test.net

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  enquiryPeriod.startDate
  ${return_value}=    convert_date_prom    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].description
  ${return_value}=    Отримати тест із поля і показати на сторінці   items[0].description
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].classification.id
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].classification.scheme
  ${return_value}=    convert_prom_string_to_common_string     ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].classification.description
  ${return_value}=    Convert To String     ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.countryName
  [Return]      ${return_value.split(', ')[0]}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [Return]      ${return_value.split(', ')[1]}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.region
  [Return]   ${return_value.split(', ')[2]}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.locality
  [Return]  ${return_value.split(', ')[3]}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=    Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.streetAddress
  [Return]  ${return_value.split(', ')[4]}

Отримати інформацію про questions[0].title
  Click Element                       id=qa_question_and_answer
  Wait Until Page Contains Element    xpath=//div[@class='zk-question']
  Click Element                       xpath=//div[@class='zk-question']
  ${return_value}=  Get text          css=.qa_message_title
  [Return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=    Отримати тест із поля і показати на сторінці   questions[0].description
  [Return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=    Отримати тест із поля і показати на сторінці   questions[0].date
  ${return_value}=    convert_date_prom     ${return_value}
  [Return]  ${return_value}

Отримати інформацію про questions[0].answer
  Click Element                       id=qa_question_and_answer
  Wait Until Page Contains Element    xpath=//div[@class='zk-question']
  Click Element                       xpath=//div[@class='zk-question']
  Sleep  1
  ${return_value}=   Get Text         css=.zk-question__answer-body
  [Return]  ${return_value}

Отримати інформацію про bids
    ${bids}=    Отримати текст із поля і показати на сторінці   bids
    [Return]  ${bids}


Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data
  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  prom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Sleep   2
  Wait Until Page Contains Element      css=[href*='state_auction_question/list']
  Click Element                         css=[href*='state_auction_question/list']
  Wait Until Page Contains Element      css=.qa_message_title
  Click Element                         css=.qa_message_title
  Input Text                            xpath=//textarea[@name='answer']        ${answer}
  Click Element                         xpath=(//button[@type='submit'])[1]

Подати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  ${test_bid_data}
    ${amount}=    Get From Dictionary     ${ARGUMENTS[2].data.value}    amount
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep  10
    Input Text      id=search     ${ARGUMENTS[1]}
    Sleep  2
    Click Element    css=#js-cabinet_search_form button
    Sleep  5
    CLICK Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Sleep   20
    reload page
    Click Element       css=.qa_button_create_offer
    Wait Until Page Contains Element        id=amount       10
    ${amount}=      Convert To String           ${amount}
    Input Text          id=amount               ${amount}
    Wait Until Page Contains Element        id=reglament_agreement       10
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button
    sleep   30
    reload page
    ${resp}=    Get Text      css=.qa_offer_id
    [Return]    ${resp}


Отримати інформацію із пропозиції
    [Arguments]  ${username}  ${tender_uaid}   ${field}
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Click Element        css=.qa_your_modify_offer
    sleep   1
    ${value}=   Get Value     id=amount
    ${value}=   convert to string      ${value.split('.')[0]}
    ${value}=   Convert To Number      ${value}
    Click Element        xpath=//td//a[contains(@href, 'state_auction/view')]
    [Return]    ${value}


Скасувати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  none
    ...    ${ARGUMENTS[2]} ==  tenderId
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep  10
    Input Text        id=search     ${ARGUMENTS[1]}
    Sleep  2
    Click Element     css=#js-cabinet_search_form button
    Sleep  5
    CLICK Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Sleep   20
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Click Element        css=.qa_your_withdraw_offer
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}

Змінити цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tenderId
    ...    ${ARGUMENTS[2]} ==  amount
    ...    ${ARGUMENTS[3]} ==  amount.value
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Click Element           css=.qa_your_modify_offer
    Clear Element Text      id=amount
    ${value} =          Convert To String  ${ARGUMENTS[3]}
    Input Text              id=amount         ${value}
    sleep   3
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button

Завантажити документ в ставку
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Sleep   5
    Click Element           css=.qa_your_modify_offer
    Sleep   2
    Choose File         xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${ARGUMENTS[1]}
    sleep   2
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button

Змінити документ в ставці
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId
    Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
    Click Element           css=.qa_your_modify_offer
    Sleep   2
    Choose File         xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${ARGUMENTS[1]}
    sleep   2
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button


Отримати посилання на аукціон для глядача
    [Arguments]  @{ARGUMENTS}
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep  10
    Input Text        id=search     ${ARGUMENTS[1]}
    Sleep  2
    Click Element     css=#js-cabinet_search_form button
    Sleep  5
    Click Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       css=.qa_auction_url
    ${value}=   get text     css=.qa_auction_url
    [Return]   ${value}

Отримати посилання на аукціон для учасника
    [Arguments]  @{ARGUMENTS}
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep  10
    Input Text        id=search     ${ARGUMENTS[1]}
    Sleep  2
    Click Element     css=#js-cabinet_search_form button
    Sleep  5
    Click Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       css=.qa_auction_url
    ${value}=   get text     css=.qa_auction_url
    [Return]   ${value}

Підтвердити постачальника
    [Documentation]
    ...      [Arguments] Username, tender uaid and number of the award to confirm
    ...      Find tender using uaid, create dict with confirmation data and call patch_award
    ...      [Return] Nothing
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    sleep   150
    Reload Page
    Wait Until Page Contains Element      css=[href*=has_protocol]     30
    Click Element                         css=[href*=has_protocol]
    Sleep   10
    Wait Until Page Contains Element      css=[href*=state_award]     30
    Click Element                         css=[href*=state_award]
    Sleep   10
    Reload Page

Завантажити угоду до тендера
    [Arguments]  ${username}  ${tender_uaid}  ${contract_num}  ${filepath}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element      xpath=//a[contains(@data-afip-url, 'state_auction/complete')]    30
    Click Element       xpath=//a[contains(@data-afip-url, 'state_auction/complete')]
    Sleep    10
    Choose File         css=.qa_state_offer_add_field       ${filepath}
    Sleep    10
    Click Element       xpath=//span[contains(@class, 'b-drop-down')]
    Sleep    1
    Click Element       xpath=//span[text()='Підписаний договір']
    Sleep    2
    Click Element       id=submit_button
    Sleep    15

Підтвердити підписання контракту
    [Documentation]
    ...      [Arguments] Username, tender uaid, contract number
    ...      Find tender using uaid, get contract test_confirmation data and call patch_contract
    ...      [Return] Nothing
    [Arguments]  ${username}  ${tender_uaid}  ${contract_num}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element      xpath=//a[contains(@data-afip-url, 'state_auction/complete')]    30
    Click Element       xpath=//a[contains(@data-afip-url, 'state_auction/complete')]
    Sleep    5
    ${file_path}  ${file_title}  ${file_content}=   create_fake_doc
    Sleep    10
    Choose File         css=.qa_state_offer_add_field       ${filepath}
    Sleep    10
    Click Element       xpath=//span[contains(@class, 'b-drop-down')]
    Sleep    1
    Click Element       xpath=//span[text()='Підписаний договір']
    Sleep    2
    Click Element       id=submit_button
    Sleep    2
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       xpath=//button[contains(@data-afip-url, 'state_award/sign_contract')]
    Click Element       xpath=//button[contains(@data-afip-url, 'state_award/sign_contract')]
    sleep    10
    Click Element       id=submit_button
