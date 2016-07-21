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
${locator.title}                                                css=.qa_title
${locator.status}                                               xpath=//td[contains(@class, 'zk-status')]
${locator.description}                                          css=.qa_descr
${locator.minimalStep.amount}                                   css=.qa_min_budget
${locator.value.amount}                                         css=.qa_budget_pdv
${locator.tenderId}                                             xpath=//dd[contains(@class, 'tender-tuid')]
${locator.procuringEntity.name}                                 css=.qa_procuring_entity
${locator.enquiryPeriod.startDate}                              css=.qa_date_period_clarifications
${locator.enquiryPeriod.endDate}                                css=.qa_date_period_clarifications
${locator.tenderPeriod.startDate}                               css=.qa_date_submission_of_proposals
${locator.tenderPeriod.endDate}                                 css=.qa_date_submission_of_proposals
${locator.items[0].quantity}                                    xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].description}                                 css=.qa_item_name
${locator.items[0].deliveryLocation.latitude}                   css=.qa_place_delivery
${locator.items[0].deliveryLocation.longitude}                  css=.qa_place_delivery
${locator.items[0].unit.code}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].unit.name}                                   xpath=//td[contains(@class, 'qa_quantity')]/p
${locator.items[0].deliveryAddress.postalCode}                  css=.qa_address_delivery
${locator.items[0].deliveryAddress.countryName}                 css=.qa_address_delivery
${locator.items[0].deliveryAddress.region}                      css=.qa_address_delivery
${locator.items[0].deliveryAddress.locality}                    css=.qa_address_delivery
${locator.items[0].deliveryAddress.streetAddress}               css=.qa_address_delivery
${locator.items[0].classification.scheme}                       css=.qa_cpv_name
${locator.items[0].classification.id}                           css=.qa_cpv_classifier
${locator.items[0].classification.description}                  css=.qa_cpv_classifier
${locator.questions[0].title}                                   css=.qa_message_title
${locator.questions[0].description}                             css=.qa_message_description
${locator.questions[0].date}                                    css=.qa_question_date
${locator.questions[0].answer}                                  css=.zk-question__answer-body


*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]     @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  Open Browser  ${USERS.users['${ARGUMENTS[0]}'].homepage}  ${USERS.users['${ARGUMENTS[0]}'].browser}  alias=${ARGUMENTS[0]}
  Set Window Size       @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'Prom_Viewer'   Login   ${ARGUMENTS[0]}

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}
  ${tender_data}=   adapt_procuringEntity   ${tender_data}
  ${tender_data}=   adapt_item   ${tender_data}
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
  Click Button    id=submit_login_button
  Sleep   2

Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data

    ${title}=                Get From Dictionary         ${ARGUMENTS[1].data}             title
    ${description}=          Get From Dictionary         ${ARGUMENTS[1].data}             description
    ${items}=                Get From Dictionary         ${ARGUMENTS[1].data}             items
    ${item0}=                Get From List               ${items}                         0
    ${descr_lot}=            Get From Dictionary         ${item0}                         description
    ${budget}=               Get From Dictionary         ${ARGUMENTS[1].data.value}       amount
    ${currency}=                            Get From Dictionary         ${ARGUMENTS[1].data.value}       currency
    ${valueAddedTaxIncluded}=               Get From Dictionary         ${ARGUMENTS[1].data.value}       valueAddedTaxIncluded
    ${unit}=                 Get From Dictionary         ${items[0].unit}                 name
    ${cav_id}=               Get From Dictionary         ${items[0].classification}       id
    ${delivery_end}=         get_delivery_date_prom      ${ARGUMENTS[1]}

    ${postalCode}=           Get From Dictionary         ${items[0].deliveryAddress}      postalCode
    ${locality}=             Get From Dictionary         ${items[0].deliveryAddress}      locality
    ${streetAddress}=        Get From Dictionary         ${items[0].deliveryAddress}      streetAddress
    ${latitude}=             Get From Dictionary         ${items[0].deliveryLocation}     latitude
    ${longitude}=            Get From Dictionary         ${items[0].deliveryLocation}     longitude
    ${quantity}=             Get From Dictionary         ${items[0]}                      quantity
    ${step_rate}=            Get From Dictionary         ${ARGUMENTS[1].data.minimalStep}       amount
    ${enquiryPeriod}=        Get From Dictionary         ${ARGUMENTS[1].data}             enquiryPeriod
    ${end_period_adjustments}=      get_all_prom_dates          ${ARGUMENTS[1]}           EndPeriod
    ${start_receive_offers}=        get_all_prom_dates          ${ARGUMENTS[1]}           StartDate
    ${end_receive_offers}=          get_all_prom_dates          ${ARGUMENTS[1]}           EndDate


    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]    20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]     20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]
    Wait Until Page Contains Element     id=title       20
    Input text                           id=title               ${title}
    Input text                           id=descr               ${description}
    Input text        id=state_purchases_items-0-descr          ${descr_lot}
    Input text        id=state_purchases_items-0-quantity       ${quantity}
    Click Element     id=state_purchases_items-0-unit_id_dd
    Click Element     xpath=//li[@data-value='1']
     ## cav
    Click Element     xpath=//div[contains(@class, 'qa_cav_button')]
    Wait Until Page Contains Element    xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-url, 'classifier_type=cav')]    20
    Click Element     xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-url, 'classifier_type=cav')]
    Input text        xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-url, 'classifier_type=cav')]    ${cav_id}
    Wait Until Page Contains Element      xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-label, '${cav_id}')]      20
    Press Key         xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-label, '${cav_id}')]             \\13
    Click Element     xpath=//div[contains(@class, 'qa_cav_popup')]//input[contains(@data-label, '${cav_id}')]
    Sleep    2
    Click Element     xpath=//div[contains(@class, 'qa_cav_popup')]//a[contains(@data-target, 'inputs-container')]
    Sleep    2
    Input text        id=state_purchases_items-0-delivery_postal_code       ${postalCode}
    Click Element     id=state_purchases_items-0-delivery_region_dd
    Click Element     xpath=//li[contains(@data-value, 'Киев')]
    Input text        id=state_purchases_items-0-delivery_locality          ${locality}
    Input text        id=state_purchases_items-0-delivery_street_address    ${streetAddress}
    ${latitude}=   Convert To String     ${latitude}
    Input text        id=state_purchases_items-0-delivery_latitude          ${latitude}
    ${longitude}=   Convert To String     ${longitude}
    Input text        id=state_purchases_items-0-delivery_longitude         ${longitude}
    ${budget}=   Convert To String     ${budget}
    Input text        id=amount             ${budget}
    Click Element     id=tax_included
    Input text        id=dt_enquiry           ${end_period_adjustments}
    Sleep   1
    Click Element     id=dt_enquiry
    Press Key         id=dt_enquiry                   \\13
    Sleep   1
    Input text        id=dt_tender_start      ${start_receive_offers}
    Click Element     id=dt_tender_start
    Press Key         id=dt_tender_start              \\13
    Sleep   1
    Input text        id=dt_tender_end        ${end_receive_offers}
    Click Element     id=dt_tender_end
    Press Key         id=dt_tender_end                \\13
    Sleep   1
    ${step_rate}=   Convert To String     ${step_rate}
    input text        id=step                 ${step_rate}
    Click Button      id=submit_button
    Sleep   3
    Wait Until Page Does Not Contain        очікування...         1000
    Reload Page
    ${tender_id}=     Get Text        xpath=//p[@class='tender-tuid']
    ${TENDER}=            Remove String     ${tender_id}      Ідентифікатор аукціону:
    log to console      ${TENDER}
    [Return]    ${TENDER}

Завантажити документ
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${filepath}
  ...      ${ARGUMENTS[2]} ==  ${TENDER}
  Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
  Sleep   2
  Input Text      id=search       ${ARGUMENTS[2]}
  Sleep   3
  Click Button    xpath=//button[@type='submit']
  Sleep   3
  Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
  Sleep   1
  Click Element   xpath=//span[@class='b-button__text']
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
  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Sleep  20
  Input Text      id=search_text_id   ${ARGUMENTS[1]}
  log to console    ${ARGUMENTS[1]}
  Sleep  2
  Click Element    id=search_submit
  Sleep  2
  CLICK Element     xpath=(//a[contains(@class, 'qa_auctions_item')])[1]
  Sleep  3
  Click Element   id=show_lot_info-0

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderUaId
  ...      ${ARGUMENTS[2]} ==  questionId
  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Input Text      id=search_text_id   ${ARGUMENTS[1]}
  Click Button    id=search_submit
  Sleep  2
  Sleep  2
  CLICK ELEMENT     xpath=(//a[contains(@class, 'qa_auctions_item')])[1]
  Sleep   1
  Click Element     id=qa_question_and_answer
  Sleep   15
  Click Element     xpath=//a[contains(@href, 'state_auction_question/add')]
  Wait Until Page Contains Element    name=title    20
  Input text                          name=title                 ${title}
  Input text                          xpath=//textarea[@name='description']           ${description}
  Click Element                       id=submit_button
  Wait Until Page Contains Element            xpath=//a[contains(@href, 'state_auction_question/add')]     30
  capture page screenshot

Оновити сторінку з тендером
    [Arguments]    @{ARGUMENTS}
    [Documentation]    ${ARGUMENTS[0]} = username
    ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
    Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
    prom.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}

Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  ${return_value}=  run keyword  Отримати інформацію про ${ARGUMENTS[1]}
  [Return]  ${return_value}

Отримати тест із поля і показати на сторінці
  [Arguments]   ${fieldname}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [Return]  ${return_value}

Отримати інформацію про title
  ${return_value}=   Отримати тест із поля і показати на сторінці   title
  [Return]  ${return_value}

Отримати інформацію про status
  reload page
  ${return_value}=   Отримати тест із поля і показати на сторінці   status
  ${return_value}=   convert_prom_string_to_common_string   ${return_value}
  [Return]  ${return_value}

Отримати інформацію про description
  ${return_value}=   Отримати тест із поля і показати на сторінці   description
  [Return]  ${return_value}

Отримати інформацію про value.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Remove String      ${return_value}     грн. з ПДВ
  ${return_value}=   Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [Return]  ${return_value}

Отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці   minimalStep.amount
  ${return_value}=    Remove String      ${return_value}     грн.
  ${return_value}=   Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  [Return]   ${return_value}

Внести зміни в тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  ${TENDER_UAID}
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
  Input Text        id=search       ${ARGUMENTS[1]}
  Click Button    xpath=//button[@type='submit']
  Sleep   2
  Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
  Sleep   2
  Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
  Sleep   1
  ${title}=   Get Text     id=title
  ${description}=   Get Text    id=descr
  Click Button    id=submit_button
  Sleep   2
  Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
  Input Text      id=search_text_id   ${ARGUMENTS[1]}
  Click Button    id=search_submit
  Sleep   2
  CLICK ELEMENT     xpath=(//a[contains(@href, 'net/dz/')])[1]


Отримати інформацію про items[0].quantity
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].quantity
  ${return_value}=    Convert To Number   ${return_value.split(' ')[0]}
  [Return]  ${return_value}

Отримати інформацію про items[0].unit.code
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.code
  ${return_value}=   Convert To String     ${return_value.split(' ')[1]}
  ${return_value}=   Convert To String    KGM
  [Return]  ${return_value}

Отримати інформацію про items[0].unit.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].unit.name
  ${return_value}=   Convert To String     ${return_value.split(' ')[1]}
  ${return_value}=   convert_prom_string_to_common_string     кг.
  [Return]   ${return_value}

Отримати інформацію про value.currency
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Convert To String     ${return_value.split(' ')[2]}
  ${return_value}=   convert_prom_string_to_common_string      ${return_value}
  [Return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Remove String      ${return_value}    50 000,99 грн.
  ${return_value}=   convert_prom_string_to_common_string      ${return_value}
  [Return]  ${return_value}

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

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=    Отримати тест із поля і показати на сторінці  tenderPeriod.startDate
  ${return_value}=    convert_date_to_prom_tender_startdate      ${return_value}
  [Return]    ${return_value}

Отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  tenderPeriod.endDate
  ${return_value}=    convert_date_to_prom_tender_enddate    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.startDate
  Fail   Дане поле відсутнє на e-auction.dz-test.net

Отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.endDate
  ${return_value}=    convert_date_to_prom_tender_startdate    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].description
  ${return_value}=   Отримати тест із поля і показати на сторінці   items[0].description
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.id
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.id
  [Return]  ${return_value.split(' ')[0]}

Отримати інформацію про items[0].classification.scheme
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.scheme
  ${return_value}=    Remove String      ${return_value}     :
  ${return_value}=    Convert To String     ${return_value.split(' ')[1]}
  [Return]  ${return_value}

Отримати інформацію про items[0].classification.description
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].classification.description
  ${return_value}=   Convert To String     ${return_value.split('5 ')[1]}
  ${return_value}=   convert_prom_string_to_common_string       ${return_value}
  [Return]  ${return_value}

Отримати інформацію про items[0].deliveryAddress.countryName
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.countryName
  [Return]      ${return_value.split(', ')[0]}

Отримати інформацію про items[0].deliveryAddress.postalCode
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.postalCode
  [Return]      ${return_value.split(', ')[1]}

Отримати інформацію про items[0].deliveryAddress.region
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.region
  [Return]   ${return_value.split(', ')[2]}

Отримати інформацію про items[0].deliveryAddress.locality
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.locality
  [Return]  ${return_value.split(', ')[3]}

Отримати інформацію про items[0].deliveryAddress.streetAddress
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[0].deliveryAddress.streetAddress
  [Return]  ${return_value.split(', ')[4]}

Отримати інформацію про questions[0].title
  Click Element                       id=qa_question_and_answer
  Wait Until Page Contains Element    xpath=//div[@class='zk-question']
  Click Element                       xpath=//div[@class='zk-question']
  ${return_value}=  Get text          css=.qa_message_title
  [Return]  ${return_value}

Отримати інформацію про questions[0].description
  ${return_value}=   Отримати тест із поля і показати на сторінці   questions[0].description
  [Return]  ${return_value}

Отримати інформацію про questions[0].date
  ${return_value}=   Отримати тест із поля і показати на сторінці   questions[0].date
  ${return_value}=    convert_date_prom     ${return_value}
  [Return]  ${return_value}

Отримати інформацію про questions[0].answer
  Click Element                       id=qa_question_and_answer
  Wait Until Page Contains Element    xpath=//div[@class='zk-question']
  Click Element                       xpath=//div[@class='zk-question']
  Sleep  1
  ${return_value}=   Get Text         css=.zk-question__answer-body
  [Return]  ${return_value}

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${TENDER_UAID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data
  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer
  Selenium2Library.Switch Browser     ${ARGUMENTS[0]}
  Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
  Input Text        id=search       ${ARGUMENTS[1]}
  Click Button    xpath=//button[@type='submit']
  Sleep   2
  Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
  Sleep   2
  Wait Until Page Contains Element      xpath=//a[@class='b-tabs__link']
  Click Element                         xpath=//a[@class='b-tabs__link']
  Wait Until Page Contains Element      css=.zk-question
  Click Element                         css=.zk-question
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
    sleep   10
    Input Text        id=search       ${ARGUMENTS[1]}
    Click Button    xpath=//button[@type='submit']
    Sleep   2
    Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
    Sleep   180
    reload page
    Click Element       xpath=//a[contains(@class, 'zk-button_theme_green')]
    Input Text          id=amount         ${amount}
    sleep   2
    Click Element       id=submit_button
    sleep   30
    reload page
    ${resp}=    Get Text      css=.qa_offer_id
    [Return]    ${resp}

Скасувати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  none
    ...    ${ARGUMENTS[2]} ==  tenderId
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Input Text        id=search       ${ARGUMENTS[1]}
    Click Button    xpath=//button[@type='submit']
    Sleep   2
    Click Element   xpath=(//td[contains(@class, 'qa_item_name')]//a)[1]
    sleep   2
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
    Input Text              id=amount         ${ARGUMENTS[3]}
    sleep   3
    Click Element       id=submit_button

Завантажити документ в ставку
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[1]} ==  file
    ...    ${ARGUMENTS[2]} ==  tenderId
    Sleep   5
    Click Element           css=.qa_your_modify_offer
    Sleep   2
    Choose File     xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${ARGUMENTS[1]}
    sleep   2
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
    Choose File     xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${ARGUMENTS[1]}
    sleep   2
    Click Element       id=submit_button

Отримати інформацію про bids
    [Arguments]  @{ARGUMENTS}
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}

Отримати посилання на аукціон для глядача
    [Arguments]  @{ARGUMENTS}
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].homepage}
    Sleep   380
    Input Text      id=search_text_id   ${ARGUMENTS[1]}
    Click Button    id=search_submit
    Sleep  2
    CLICK ELEMENT     xpath=(//a[contains(@class, 'qa_auctions_item')])[1]
    reload page
    ${result} =    get text    xpath=//a[contains(@target, 'blank_')]
    [Return]   ${result}

Отримати посилання на аукціон для учасника
    [Arguments]  @{ARGUMENTS}
    Selenium2Library.Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Input Text        id=search       ${ARGUMENTS[1]}
    Click Button    xpath=//button[@type='submit']
    Sleep   2
    CLICK Element     xpath=(//a[contains(@class, ' qa_procurement_name_in_list')])[1]
    Sleep   120
    reload page
    ${result}=       get text    xpath=//a[contains(@target, 'blank_')]
    [Return]   ${result}

