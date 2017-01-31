*** Settings ***
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
${locator.description}                                          css=.qa_auction_descr
${locator.minimalStep.amount}                                   css=.qa_bid_step
${locator.minimalStep}                                          css=.qa_quantity
${locator.value.amount}                                         css=.qa_amount_block .qa_buget
${locator.value.pdv}                                            css=.qa_amount_block .qa_pdv
${locator.tenderId}                                             css=.qa_ua_ea_id
${locator.procuringEntity.name}                                 css=.qa_merchant_name
${locator.auctionPeriod.startDate}                              css=.qa_date_time_auction
${locator.auctionPeriod.endDate}                                css=.qa_date_time_auction
${locator.enquiryPeriod.startDate}                              css=.qa_date_time_auction
${locator.enquiryPeriod.endDate}                                css=.qa_date_period_clarifications
${locator.tenderPeriod.startDate}                               css=.qa_date_submission_of_proposals
${locator.tenderPeriod.endDate}                                 css=.qa_date_submission_of_proposals
${locator.items.quantity}                                       //span[@class='qa_quantity']
${locator.items.description}                                    //div[@class='qa_item_short_descr']
${locator.items.unit.code}                                      //span[@class='qa_item_unit']
${locator.items.unit.name}                                      //span[@class='qa_item_unit']
${locator.items.deliveryAddress.postalCode}                     //td[contains(@class, 'qa_address_delivery')]
${locator.items.deliveryAddress.countryName}                    //td[contains(@class, 'qa_address_delivery')]
${locator.items.deliveryAddress.region}                         //td[contains(@class, 'qa_address_delivery')]
${locator.items.deliveryAddress.locality}                       //td[contains(@class, 'qa_address_delivery')]
${locator.items.deliveryAddress.streetAddress}                  //td[contains(@class, 'qa_address_delivery')]
${locator.items.classification.scheme}                          //span[@class='qa_classifier_scheme']
${locator.items.classification.id}                              //span[@class='qa_classifier_code']
${locator.items.classification.description}                     //span[@class='qa_classifier_name']
${locator.questions.title}                                      //p[contains(@class, 'qa_message_title')]
${locator.questions.description}                                //div[contains(@class, 'qa_message_description')]
${locator.questions.date}                                       //span[contains(@class, 'qa_question_date')]
${locator.questions.answer}                                     //div[contains(@class, 'zk-question__answer-body')]
${locator.bids}                                                 css=.qa_offer_price
${locator.dgf}                                                  css=.qa_auction_dgf_id
${locator.dgfDecisionDate}                                      css=.qa_auction_dgf_decision_date
${locator.dgfDecisionID}                                        css=.qa_auction_dgf_decision_date
${locator.cancellations[0].status}                              css=.qa_auction_status
${locator.cancellations[0].reason}                              css=.qa_auction_cancel_reason
${locator.contracts[-1].status}                                 css=.qa_auction_status
${locator.procurementMethodType}                                css=.qa_purchase_procedure
${locator.tenderAttempts}                                       css=.qa_auction_tender_attempts

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
    Clear Element Text   id=phone_email
    Input Text      ${login_sign_in}          ${USERS.users['${ARGUMENTS[0]}'].login}
    Input Text      ${password_sign_in}       ${USERS.users['${ARGUMENTS[0]}'].password}
    Click Button    id=submit_button
    Sleep   2

Створити тендер
    [Arguments]   ${username}    ${tender_data}
    ${method_type_status}=  Run Keyword And Return Status    Should Be Equal   ${tender_data.data.procurementMethodType}     dgfOtherAssets
    ${tender_attempts}=      Get From Dictionary         ${tender_data.data}             tenderAttempts
    ${title}=                Get From Dictionary         ${tender_data.data}             title
    ${dgf}=                  Get From Dictionary         ${tender_data.data}             dgfID
    ${dgf_id}=               Get From Dictionary         ${tender_data.data}             dgfDecisionID
    ${dgf_date}=             Get From Dictionary         ${tender_data.data}             dgfDecisionDate
    ${dgf_date}=             convert_dgf_date_prom       ${dgf_date}
    ${description}=          Get From Dictionary         ${tender_data.data}             description
    ${budget}=               Get From Dictionary         ${tender_data.data.value}       amount
    ${currency}=                            Get From Dictionary         ${tender_data.data.value}              currency
    ${valueAddedTaxIncluded}=               Get From Dictionary         ${tender_data.data.value}              valueAddedTaxIncluded
    ${step_rate}=                           Get From Dictionary         ${tender_data.data.minimalStep}        amount
    ${start_day_auction}=                   get_all_prom_dates          ${tender_data}                         StartDate

    Switch Browser      ${username}
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]    20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/list')]
    Wait Until Page Contains Element     xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]     20
    Click Element                        xpath=//a[contains(@href,'/cabinet/purchases/state_auction/add')]
    Wait Until Page Contains Element     css=.qa_multilot_title       20
    Click Element                        css=.qa_multilot_type_drop_down
    Wait Until Page Contains Element     xpath=//li[contains(text(),'Майно')]
    Run Keyword If   '${method_type_status}' == 'True'     Click Element      xpath=//li[contains(text(),'Майно')]
    ...    ELSE    Click Element     xpath=//li[contains(text(),'Фінансові активи')]
    Sleep  2
    Input Text                           css=.qa_multilot_title               ${title}
    Input Text                           css=.qa_multilot_dgf_id              ${dgf}
    Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]
    Sleep   1
    Run Keyword If   '${tender_attempts}' == '1'     Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]//li[contains(@data-reactid, '$1')]
    ...    ELSE IF   '${tender_attempts}' == '2'     Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]//li[contains(@data-reactid, '$2')]
    ...    ELSE IF   '${tender_attempts}' == '3'     Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]//li[contains(@data-reactid, '$3')]
    ...    ELSE IF   '${tender_attempts}' == '4'     Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]//li[contains(@data-reactid, '$4')]
    ...    ELSE     Click Element     xpath=//div[contains(@class, 'qa_tender_attempts')]//li[contains(@data-reactid, '$0')]

    Input Text                           css=.qa_dgf_decision_id              ${dgf_id}
    Input Text                           css=.qa_dgf_decision_date            ${dgf_date}
    Input Text                           css=.qa_multilot_descr               ${description}
    ${budget}=        Convert To String                                 ${budget}
    Input Text        id=qa_currency_input                              ${budget}
    ${step_rate}=     Convert To String                                 ${step_rate}
    Input Text        css=.qa_singlelot_tender_step_auction_rate        ${step_rate}
    Click Element     css=.qa_multilot_tax_included
    Input Text        css=.qa_singlelot_end_period_adjustments          ${start_day_auction}
    Sleep   1
    Press Key         css=.qa_singlelot_end_period_adjustments            \\13
    ${items}=   Get From Dictionary   ${tender_data.data}   items
    ${number_of_items}=  Get Length  ${items}
    :FOR  ${index}  IN RANGE  ${number_of_items}
    \  Run Keyword If  '${index}' != '0'   Click Element     css=.qa_singlelot_tender_add_more_product
    \  Додати предмети    ${items[${index}]}
    Click Button      css=.qa_multilot_tender_submit_button
    Sleep   3
    Wait Until Page Does Not Contain        очікування...         1000
    Reload Page
    ${TENDER}=     Get Text        css=.qa_ua_ea_id
    ${access_token}=    Get Variable Value    ${TENDER.access.token}
    Set To Dictionary   ${USERS.users['${username}']}    access_token=${access_token}
    log to console      ${TENDER}
    [Return]    ${TENDER}

Додати предмети
    [Arguments]  ${items}
    ${descr_lot}=            Get From Dictionary         ${items}                      description
    ${quantity}=             Get From Dictionary         ${items}                      quantity
    ${unit}=                 Get From Dictionary         ${items.unit}                 name
    ${cav_id}=               Get From Dictionary         ${items.classification}       id
    ${postalCode}=           Get From Dictionary         ${items.deliveryAddress}      postalCode
    ${locality}=             Get From Dictionary         ${items.deliveryAddress}      locality
    ${streetAddress}=        Get From Dictionary         ${items.deliveryAddress}      streetAddress

    Wait Until Page Contains Element       xpath=(//input[contains(@class, 'qa_multilot_tender_descr_product')])[last()]
    Input Text        xpath=(//input[contains(@class, 'qa_multilot_tender_descr_product')])[last()]          ${descr_lot}
    Input Text        xpath=(//input[contains(@class, 'qa_multilot_tender_quantity_product')])[last()]       ${quantity}
    Click Element     xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]
    Run Keyword If    '${unit}' in ['метри квадратні', 'метры квадратные']   Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]//li[text()='метры квадратные']
    ...    ELSE IF    '${unit}' == 'штуки'     Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]//li[text()='штуки']
    ...    ELSE       Click Element   xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_product')])[last()]//li[text()='послуга']
    Click Element     xpath=(//a[contains(@class, 'qa_multilot_tender_cav_classifier')])[last()]
    Wait Until Page Contains Element    css=.qa_search_input    20
    Click Element     css=.qa_search_input
    Input Text        css=.qa_search_input    ${cav_id}
    Press Key         css=.qa_search_input         \\13
    Sleep    1
    Click Element     css=.qa_dkpp_classifier_block .b-checkbox__input
    Click Element     css=.qa_submit_dkpp_block
    Sleep    1
    Click Element     xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')])[last()]
    Sleep    2
    Click Element     xpath=(//div[contains(@class, 'qa_multilot_tender_drop_down_region')]//li[contains(@data-reactid, '$9')])[last()]
    Input Text        xpath=(//input[contains(@class, 'qa_multilot_tender_zip_code')])[last()]      ${postalCode}
    Input Text        xpath=(//input[contains(@class, 'qa_multilot_tender_locality')])[last()]      ${locality}
    Input Text        xpath=(//input[contains(@class, 'qa_multilot_tender_address')])[last()]       ${streetAddress}

Пошук тендера по ідентифікатору
    [Arguments]   ${username}   ${tender_uaid}
    Go to   ${USERS.users['${username}'].default_page}
    Wait Until Page Contains Element      id=search           20
    Input Text        id=search     ${tender_uaid}
    log to console    ${tender_uaid}
    Sleep  2
    Click Element     id=js-cabinet_search_form button
    Wait Until Page Contains Element      xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]         20
    Click Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Sleep  1

Завантажити документ
    [Arguments]  ${username}  ${filepath}  ${tender_uaid}
    prom.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    Wait Until Page Contains Element     css=[href*='state_auction/edit/']    30
    Click Element   css=[href*='state_auction/edit/']
    Wait Until Page Contains Element      xpath=(//input[contains(@class, 'qa_state_offer_add_field')])[1]
    Choose File       xpath=(//input[contains(@class, 'qa_state_offer_add_field')])[1]       ${filepath}
    Wait Until Page Contains Element      xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  3
    Click Element     xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  3
    Click Element     xpath=(//span[text()='Паспорт торгів'])[last()]
    Sleep  3
    Click Element     css=.qa_multilot_tender_submit_button

Задати питання
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} ==  username
    ...      ${ARGUMENTS[1]} ==  tender_uaid
    ...      ${ARGUMENTS[2]} ==  questionId
    ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
    ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description
    prom.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
    Wait Until Page Contains Element      css=[href*=state_auction_question]
    Click Element     css=[href*=state_auction_question]
    Sleep   15
    Click Element     css=.qa_ask_a_question
    Wait Until Page Contains Element    name=title    20
    Input Text                          name=title                 ${title}
    Input Text                          xpath=//textarea[@name='description']           ${description}
    Click Element                       id=submit_button
    Wait Until Page Contains Element            css=.qa_ask_a_question     30
    capture page screenshot

Оновити сторінку з тендером
    [Arguments]   ${username}   ${tender_uaid}
    Switch Browser    ${username}
    prom.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}

Отримати інформацію із предмету
    [Arguments]   ${username}   ${tender_uaid}   ${item_id}   ${field_name}
    ${return_value}=   Get Text   xpath=//tr[contains(@class, 'table__row') and .//div[contains(text(), '${item_id}')]]${locator.items.${field_name}}
    ${return_value}=    Run Keyword If    'unit.code' in '${field_name}'  convert_prom_code_to_common_string   ${return_value}
    ...   ELSE IF   'quantity' in '${field_name}'   Convert To Number     ${return_value}
    ...   ELSE      convert_prom_string_to_common_string     ${return_value}
    [Return]  ${return_value}

Отримати інформацію із тендера
    [Arguments]   ${username}   ${tender_uaid}   ${field_name}
    ${return_value}=  Run Keyword  Отримати інформацію про ${field_name}
    [Return]  ${return_value}

Отримати тест із поля і показати на сторінці
    [Arguments]   ${field_name}
    ${return_value}=   Get Text  ${locator.${field_name}}
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
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...      ${ARGUMENTS[0]} =  username
    ...      ${ARGUMENTS[1]} =  tender_uaid
    Switch Browser    ${ARGUMENTS[0]}
    prom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
    Sleep   2
    Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
    Sleep   1
    ${title}=         Get Text     id=title
    ${description}=   Get Text     id=descr
    Click Button    id=submit_button
    Sleep   2

Отримати інформацію про value.currency
    ${return_value}=   Отримати тест із поля і показати на сторінці  minimalStep.amount
    ${return_value}=   Convert To String     ${return_value.split(',')[1].split(' ')[1]}
    ${return_value}=   convert_prom_string_to_common_string      ${return_value}
    [Return]  ${return_value}

Отримати інформацію про value.valueAddedTaxIncluded
    ${return_value}=   Отримати тест із поля і показати на сторінці  value.pdv
    ${return_value}=   Remove String     ${return_value}    грн
    ${return_value}=   convert_prom_string_to_common_string      ${return_value}
    [Return]   ${return_value}

Отримати інформацію про auctionId
    ${return_value}=   Отримати тест із поля і показати на сторінці   tenderId
    [Return]  ${return_value}

Отримати інформацію про procuringEntity.name
    ${return_value}=   Отримати тест із поля і показати на сторінці   procuringEntity.name
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
    Fail   ***** enquiryPeriod.endDate отсутсвует на Zakupki.dz-test *****

Отримати інформацію про enquiryPeriod.startDate
    ${return_value}=    Отримати тест із поля і показати на сторінці  enquiryPeriod.startDate
    ${return_value}=    convert_date_prom    ${return_value}
    [Return]  ${return_value}

Отримати інформацію про questions[0].title
    ${return_value}=    Отримати тест із поля і показати на сторінці  questions.title
    [Return]  ${return_value}

Отримати інформацію про questions[0].description
    ${return_value}=    Отримати тест із поля і показати на сторінці   questions.description
    [Return]  ${return_value}

Отримати інформацію про questions[0].date
    ${return_value}=    Отримати тест із поля і показати на сторінці   questions.date
    ${return_value}=    convert_date_prom     ${return_value}
    [Return]  ${return_value}

Отримати інформацію про questions[0].answer
    ${return_value}=    Отримати тест із поля і показати на сторінці   questions.answer
    [Return]  ${return_value}

Отримати інформацію про bids
    ${bids}=    Отримати текст із поля і показати на сторінці   bids
    [Return]  ${bids}

Отримати інформацію про cancellations[0].status
    ${return_value}=    Отримати тест із поля і показати на сторінці   cancellations[0].status
    ${return_value}=    convert_cancellations_status      ${return_value}
    [Return]  ${return_value}

Отримати інформацію про cancellations[0].reason
    ${return_value}=    Отримати тест із поля і показати на сторінці   cancellations[0].reason
    ${return_value}=   convert_prom_string_to_common_string      ${return_value}
    [Return]  ${return_value}

Отримати інформацію про contracts[-1].status
    ${return_value}=    Отримати тест із поля і показати на сторінці    contracts[-1].status
    ${return_value}=   convert_prom_string_to_common_string      Подписанный
    [Return]  ${return_value}

Отримати інформацію про eligibilityCriteria
    ${return_value}=   convert_prom_string_to_common_string      шт.
    [Return]  ${return_value}

Отримати інформацію про procurementMethodType
    ${return_value}=    Отримати тест із поля і показати на сторінці  procurementMethodType
    ${return_value}=   convert_procurement_method_type    ${return_value}
    [Return]  ${return_value}

Отримати інформацію про dgfDecisionDate
    ${return_value}=    Отримати тест із поля і показати на сторінці  dgfDecisionDate
    ${return_value}=   Convert To String     ${return_value.split(' ')[2]}
    ${return_value}=   revert_dgf_date_prom      ${return_value}
    [Return]     ${return_value}

Отримати інформацію про dgfDecisionID
    ${return_value}=    Отримати тест із поля і показати на сторінці  dgfDecisionID
    [Return]  ${return_value.split(' ')[0]}

Отримати інформацію про tenderAttempts
    ${return_value}=    Отримати тест із поля і показати на сторінці  tenderAttempts
    ${return_value}=   convert_prom_string_to_common_string    ${return_value}
    [Return]  ${return_value}


Відповісти на запитання
    [Arguments]  ${username}  ${tender_uaid}  ${answer_data}  ${question_id}
    prom.Пошук тендера по ідентифікатору  ${username}   ${tender_uaid}
    Sleep   2
    Wait Until Page Contains Element      css=[href*='state_auction_question/list']
    Click Element                         css=[href*='state_auction_question/list']
    Wait Until Page Contains Element      xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]
    Click Element           xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]
    Sleep  3
    Input Text      xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//textarea[@name='answer']        ${answer_data.data.answer}
    Sleep  3
    Click Element   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//button[@type='submit']

Подати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tender_uaid
    ...    ${ARGUMENTS[2]} ==  test_bid_data
    Should Be Equal   '${ARGUMENTS[2]['data']['qualified']}'   'True'
    ${amount}=    Get From Dictionary     ${ARGUMENTS[2].data.value}    amount
    prom.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
    Click Element       css=.qa_button_create_offer
    Wait Until Page Contains Element        id=amount       10
    ${amount}=      Convert To String           ${amount}
    Input Text          id=amount               ${amount}
    Wait Until Page Contains Element        id=reglament_agreement       10
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button
    Sleep   30
    reload page
    ${resp}=    Get Text      css=.qa_offer_id
    [Return]    ${resp}

Отримати інформацію із пропозиції
    [Arguments]  ${username}  ${tender_uaid}   ${field}
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Click Element        css=.qa_your_modify_offer
    Sleep   1
    ${value}=   Get Value     id=amount
    ${value}=   convert to string      ${value.split('.')[0]}
    ${value}=   Convert To Number      ${value}
    Click Element        css=.qa_cancel_offer
    [Return]    ${value}

Скасувати цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  none
    ...    ${ARGUMENTS[2]} ==  tender_uaid
    Switch Browser       ${ARGUMENTS[0]}
    Go to   ${USERS.users['${ARGUMENTS[0]}'].default_page}
    Sleep  10
    Input Text        id=search     ${ARGUMENTS[1]}
    Sleep  2
    Click Element     css=#js-cabinet_search_form button
    Sleep  5
    Click Element     xpath=(//a[contains(@class, 'qa_procurement_name_in_list')])[1]
    Sleep   20
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Click Element        css=.qa_your_withdraw_offer

Змінити цінову пропозицію
    [Arguments]  @{ARGUMENTS}
    [Documentation]
    ...    ${ARGUMENTS[0]} ==  username
    ...    ${ARGUMENTS[1]} ==  tender_uaid
    ...    ${ARGUMENTS[2]} ==  amount
    ...    ${ARGUMENTS[3]} ==  amount.value
    prom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
    Click Element           css=.qa_your_modify_offer
    Clear Element Text      id=amount
    ${value} =          Convert To String  ${ARGUMENTS[3]}
    Input Text              id=amount         ${value}
    Sleep   3
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button

Завантажити документ в ставку
    [Arguments]  ${username}  ${filePath}  ${tender_uaid}  ${doc_type}=documents
    Wait Until Page Contains Element      css=.qa_your_suggestion_block     10
    Sleep   5
    Click Element       css=.qa_your_modify_offer
    Sleep   3
    Choose File         xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${filePath}
    Sleep   10
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button

Змінити документ в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${path}  ${docid}
    prom.Завантажити документ в ставку  ${username}  ${path}  ${tender_uaid}

Отримати посилання на аукціон для глядача
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       css=.qa_auction_url
    ${value}=   get text     css=.qa_auction_url
    [Return]   ${value}

Отримати посилання на аукціон для учасника
    [Arguments]  ${username}  ${tender_uaid}  ${lot_id}=${Empty}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       css=.qa_auction_url
    ${value}=   get text     css=.qa_auction_url
    [Return]   ${value}

Підтвердити постачальника
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Sleep   150
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
    Sleep    10
    Click Element       id=submit_button

Скасувати закупівлю
    [Arguments]  @{ARGUMENTS}
    prom.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/cancel')]    30
    Click Element      xpath=//a[contains(@href, 'state_auction/cancel')]
    Wait Until Page Contains Element      css=.qa_state_offer_add_field    30
    Choose File         css=.qa_state_offer_add_field       ${ARGUMENTS[3]}
    Sleep   1
    Click Element       xpath=//div[@id='reason_dd']
    Sleep   1
    Click Element       xpath=//ul[@id='reason_dd_ul']//li[contains(text(), "${ARGUMENTS[2]}")]
    Sleep   2
    Click Element       id=submit_button
    Wait Until Keyword Succeeds     30      30          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible       xpath=//span[contains(@data-href, 'state_auction/confirm_cancellation')]
    Click Element               xpath=//span[contains(@data-href, 'state_auction/confirm_cancellation')]

Отримати інформацію із документа
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}  ${field}
    prom.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    Run Keyword If   '${field}' == 'description'   Fail    ***** Опис документу скасування закупівлі не виводиться на Zakupki.dz-test *****
    ${doc_name}=   Get Text     xpath=//div[contains(@class, 'file-name')]//a[contains(text(), '${doc_id}')]
    [Return]   ${doc_name}

Отримати інформацію із документа по індексу
    [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
    prom.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    Run Keyword If   '${field}' == 'description'   Fail    ***** Опис документу скасування закупівлі не виводиться на Zakupki.dz-test *****
    ${index}=   Set Variable   ${document_index + 1}
    ${doc_name}=   Get Text     xpath=//div[contains(@class, 'modified__item')][${index}]//div[contains(@class, 'file-type')]
    ${doc_name}=   Run keyword if   '${doc_name}' == 'Посилання'    Get Text     xpath=//div[contains(@class, 'modified__item')][${index}]//div[contains(@class, 'description')]//a
    ${doc_type}=   revert_document_type   ${doc_name}
    [Return]   ${doc_type}

Завантажити ілюстрацію
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/edit')]    30
    Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
    Choose File       css=.qa_state_offer_add_field       ${filepath}
    Wait Until Page Contains Element      xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  5
    Click Element     xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  3
    Click Element     xpath=(//span[text()='Ілюстрація'])[last()]
    Sleep  3
    Click Element     css=.qa_multilot_tender_submit_button

Додати публічний паспорт активу
    [Arguments]  ${username}  ${tender_uaid}  ${certificate_url}  ${title}=Public Asset Certificate
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/edit')]    30
    Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
    Wait Until Page Contains Element     css=.qa_dgf_public_asset_certificate    30
    Input Text        css=.qa_dgf_public_asset_certificate    ${certificate_url}
    Sleep  3
    Click Element     css=.qa_multilot_tender_submit_button

Додати офлайн документ
    [Arguments]  ${username}  ${tender_uaid}  ${accessDetails}
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/edit')]    30
    Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
    Input Text        css=.qa_dgf_asset_familiarization    ${accessDetails}
    Sleep  1
    Click Element     css=.qa_multilot_tender_submit_button

Завантажити документ в тендер з типом
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${documentType}
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/edit')]    30
    Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
    Wait Until Page Contains Element      xpath=(//input[contains(@class, 'qa_state_offer_add_field')])[1]
    Choose File       xpath=(//input[contains(@class, 'qa_state_offer_add_field')])[1]       ${filepath}
    Wait Until Page Contains Element      xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  5
    Click Element     xpath=(//td[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  3
    ${document}=      convert_document_type    ${documentType}
    Click Element     xpath=(//span[text()='${document}'])[last()]
    Sleep  3
    Click Element     css=.qa_multilot_tender_submit_button

Додати Virtual Data Room
    [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}  ${title}=Sample Virtual Data Room
    Wait Until Page Contains Element      xpath=//a[contains(@href, 'state_auction/edit')]    30
    Click Element      xpath=//a[contains(@href, 'state_auction/edit')]
    Input Text         css=.qa_vdr          ${vdr_url}
    Sleep  3
    Click Element      css=.qa_multilot_tender_submit_button

Отримати інформацію із запитання
    [Arguments]  ${username}  ${tender_uaid}  ${question_id}  ${field_name}
    prom.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    Wait Until Page Contains Element        xpath=//a[contains(@href, 'state_auction_question')]  30
    Click Element       xpath=//a[contains(@href, 'state_auction_question')]
    Wait Until Page Contains Element      xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]
    ${status}=  Run Keyword And Return Status    Element Should Be Visible   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')]
    Run Keyword If   '${status}' == 'False'   Click Element   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//p[contains(@class, 'qa_message_title')]
    Sleep  3
    ${return_value}=      Run Keyword If   '${field_name}' == 'title'
    ...     Get Text    xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//p[contains(@class, 'qa_message_title')]
    ...     ELSE IF  '${field_name}' == 'answer'     Get Text   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//span[@class='qa_answer']
    ...     ELSE    Get Text   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')]
    [Return]  ${return_value}

Отримати документ
    [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
    prom.Пошук тендера по ідентифікатору   ${username}   ${tender_uaid}
    Click Element   xpath=//a[contains(text(), '${doc_id}')]
    Sleep   3
    ${file_name}=   Get Element Attribute    xpath=//a[contains(text(), '${doc_id}')]@id
    ${url}=   Get Element Attribute    xpath=//div[contains(@id, '${file_name}')]//a@href
    download_file   ${url}  ${file_name.split('/')[-1]}  ${OUTPUT_DIR}
    [Return]  ${file_name.split('/')[-1]}


Задати запитання на тендер
    [Arguments]  ${username}  ${tender_uaid}  ${question}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element      css=[href*=state_auction_question]
    Click Element     css=[href*=state_auction_question]
    Sleep   5
    Click Element     css=.qa_ask_a_question
    Wait Until Page Contains Element    name=title    20
    Input Text                          name=title                 ${question.data.title}
    Input Text                          xpath=//textarea[@name='description']           ${question.data.description}
    Click Element                       id=submit_button
    Wait Until Page Contains Element            css=.qa_ask_a_question     30

Задати запитання на предмет
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element      css=[href*=state_auction_question]
    Click Element     css=[href*=state_auction_question]
    Sleep  5
    Click Element     css=.qa_ask_a_question
    Wait Until Page Contains Element    name=title    20
    Input Text                          name=title                 ${question.data.title}
    Input Text                          xpath=//textarea[@name='description']           ${question.data.description}
    Click Element                       id=submit_button

Завантажити фінансову ліцензію
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element        css=.qa_your_modify_offer    30
    Click Element           css=.qa_your_modify_offer
    Wait Until Page Contains Element        xpath=//input[contains(@class, 'qa_state_offer_add_field')]   30
    Choose File         xpath=//input[contains(@class, 'qa_state_offer_add_field')]   ${filepath}
    Sleep   3
    Click Element       xpath=(//div[contains(@class, 'qa_type_file')]//div[1])[last()]
    Sleep  2
    Click Element       xpath=//span[text()='Фінансова ліцензія']
    Click Element       id=reglament_agreement
    Click Element       id=oferta_agreement
    Click Element       id=submit_button

Отримати кількість документів в ставці
    [Arguments]  ${username}  ${tender_uaid}  ${bid_index}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element     xpath=//a[contains(@href, 'print/protocol')]
    ${bid_doc_number}=   Get Matching Xpath Count   xpath=//a[contains(@href, 'print/protocol')]
    [Return]  ${bid_doc_number}

Отримати дані із документу пропозиції
    [Arguments]  ${username}  ${tender_uaid}  ${bid_index}  ${document_index}  ${field}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    ${status}=   Run Keyword And Return Status    Element Should Be Visible    xpath=//a[contains(@href, 'print/protocol')]
    ${result}=   Set Variable If   ${status}    auctionProtocol     noDocument
    [Return]   ${result}

Скасування рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible      css=[data-afip-url*='state_award/award_cancel']
    Click Element     css=[data-afip-url*='state_award/award_cancel']
    Click Element     id=submit_button
    Sleep  10

Дискваліфікувати постачальника
    [Documentation]
    ...      [Arguments] Username, tender uaid and award number
    ...      [Description] Find tender using uaid, create data dict with unsuccessful status and call patch_award
    ...      [Return] Reply of API
    [Arguments]  ${username}  ${tender_uaid}  ${award_num}  ${description}
    Reload Page

Завантажити документ рішення кваліфікаційної комісії
    [Arguments]  ${username}  ${document}  ${tender_uaid}  ${award_num}
     Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible      css=[data-afip-url*='state_award/unsuccessful']
    Click Element     css=[data-afip-url*='state_award/unsuccessful']
    Click Element     id=submit_button
    Sleep     10

Завантажити протокол аукціону
    [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${award_index}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Keyword Succeeds     30      150          Run Keywords
    ...   Reload Page
    ...   AND     Wait Until Element Is Visible      css=[href*='state_offer_auction/edit_files']
    Click Element     css=[href*='state_offer_auction/edit_files']
    Sleep  2
    Choose File         css=.qa_state_offer_add_field       ${filepath}
    Sleep  5
    ${status}=  Run Keyword And Return Status    Element Should Be Visible   xpath=(//div[contains(@class, 'qa_type_file')]//div)[1]
    Run Keyword If   '${status}' == 'False'   Click Element   xpath=(//div[contains(@class, 'qa_type_file')]//div)[1]
    ...    ELSE         Click Element   xpath=(//div[contains(@class, 'qa_type_file')]//div)[last()]
    Sleep  3
    Run Keyword If   '${status}' == 'False'   Click Element   xpath=(//span[text()='Протокол'])[1]
    ...    ELSE         Click Element   xpath=(//span[text()='Протокол'])[last()]
    Sleep  2
    Click Element       id=submit_button
    Sleep  5

Отримати кількість предметів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element     xpath=//tr[contains(@class, 'items-table__row')]
    ${number_of_items}=   Get Matching Xpath Count   xpath=//tr[contains(@class, 'items-table__row')]
    [Return]  ${number_of_items}

Отримати кількість документів в тендері
    [Arguments]  ${username}  ${tender_uaid}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Wait Until Page Contains Element     xpath=//div[contains(@class, 'file-name')]
    ${number_of_items}=   Get Matching Xpath Count   xpath=//div[contains(@class, 'file-name')]
    [Return]  ${number_of_items}

Додати предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item}
    prom.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
    Run Keyword And Ignore Error    Додати предмети   ${item}

Видалити предмет закупівлі
    [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${lot_id}=${Empty}
    Run Keyword And Ignore Error   Click Element     xpath=//a[contains(@href, 'state_auction/edit')]
