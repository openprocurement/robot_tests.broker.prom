# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import shutil
import os

from datetime import datetime, timedelta


def move_uploaded_file(file_name, src_dir, dest_dir):
    src_path = '{path}/{file}'.format(path=src_dir, file=file_name)
    dest_path = '{path}/{file}'.format(path=dest_dir, file=file_name)
    shutil.move(src_path, dest_path)


def create_random_file():
    index = datetime.now().strftime("%s%f")
    file_path = '/tmp/tmp_file_%s' % index
    files = open(file_path, 'w')
    files.close()
    return file_path


def date_now():
    next_date = datetime.now()
    return next_date.strftime("%d.%m.%Y %H:%M")

def delivery_date_start():
    next_date = datetime.now()
    return next_date.strftime("%d.%m.%Y")


def delivery_date_end():
    next_date = datetime.now() + timedelta(days=2)
    return next_date.strftime("%d.%m.%Y")

def convert_period_to_closeframeworkagreement(date):
    convert_date = dateutil.parser.parse(date)
    return convert_date.strftime("%Y" )

def tender_end_date(date):
    convert_date = dateutil.parser.parse(date) + timedelta(minutes=15)
    return convert_date.strftime("%d.%m.%Y %H:%M")


def tender_end_date_esco(date):
    convert_date = dateutil.parser.parse(date) + timedelta(minutes=20)
    return convert_date.strftime("%d.%m.%Y %H:%M")


def convert_iso_date_to_prom(date):
    convert_date = dateutil.parser.parse(date)
    return convert_date.strftime("%d.%m.%Y %H:%M")


def convert_iso_date_to_prom_without_time(date):
    convert_date = dateutil.parser.parse(date)
    return convert_date.strftime("%d.%m.%Y")


def convert_iso_date_to_prom_without_time_two(date):
    convert_date = dateutil.parser.parse(date) + timedelta(days=4)
    return convert_date.strftime("%d.%m.%Y")


def get_milestones_duration_type(string):
    return {
        u'(робочих)': u'working',
        u'(робочі)': u'working',
        u'(банківськіх)': u'banking',
        u'(банківські)': u'banking',
        u'(календарних)': u'calendar',
        u'(календарні)': u'calendar',
    }.get(string, string)


def get_milestones_code(string):
    return {
        u'аванс': u'prepayment',
        u'післяоплата': u'postpayment',
    }.get(string, string)


def get_milestones_title(string):
    return {
        u'підписання договору': 'signingTheContract',
        u'поставка товару': 'deliveryOfGoods',
        u'дата подання заявки': 'submissionDateOfApplications',
        u'дата закінчення звітного періоду': 'endDateOfTheReportingPeriod',
        u'дата виставлення рахунку': 'dateOfInvoicing',
        u'виконання робіт': 'executionOfWorks',
        u'надання послуг': 'submittingServices',
        u'інша подія': 'anotherEvent',
    }.get(string, string)


def convert_prom_string_to_common_string(string):
    return {
        u"послуги": u"services",
        u"роботи": u"works",
        u"товари": u"goods",
        u"ДК 021": u"ДК021",
        u"грн": u"UAH",
        u"шт.": u"штуки",
        u"нб.": u"набір",
        u"уп.": u"упаковка",
        u"кг": u"кілограми",
        u"кв.м.": u"метри квадратні",
        u"с НДС": True,
        u"з ПДВ": True,
        u"без ПДВ": False
    }.get(string, string)


def convert_tender_status(string):
    return {
        u"Період уточнень": u"active.enquiries",
        u"Прийом пропозицій": u"active.tendering",
        u"Пропозицію прийнято": u"active",
        u"Аукціон": u"active.auction",
        u"Прекваліфікація": u"active.pre-qualification",
        u"Кваліфікація": u"active.qualification",
        u"Скасована": u"cancelled",
        u"Аукціон не відбувся": u"unsuccessful",
        u"Аукцион не состоялся": u"unsuccessful",
        u"Завершена": u"complete",
        u"Подписанный": u"active",
        u"неактивно": u"invalid",
        u"Кандидат, очікує рішення": u"pending",
        u"Прекваліфікація: період оскарження": u"active.pre-qualification.stand-still",
        u"очікує розгляду": u"invalid",
    }.get(string, string)


def convert_negotiation_cause_type(string):
    return {
        u"twiceUnsuccessful": u"ст. 35, п. 4 Закупівля проведена попередньо двічі невдало",
        u"artContestIP": u"cт. 35, п. 1 Закупівля творів мистецтва",
        u"stateLegalServices": u"cт. 35, п. 7 Закупівля юридичних послуг",
        u"additionalPurchase": u"cт. 35, п. 5 Додаткова закупівля",
        u"additionalConstruction": u"cт. 35, п. 6 Додаткові будівельні роботи",
        u"noCompetition": u"cт. 35, п. 2 Відсутність конкуренції ",
    }.get(string, string)


def revert_negotiation_cause_type(string):
    return {
         u"ст. 35, п. 4 Закупівля проведена попередньо двічі невдало": u"twiceUnsuccessful",
         u"cт. 35, п. 1 Закупівля творів мистецтва": u"artContestIP",
         u"cт. 35, п. 7 Закупівля юридичних послуг": u"stateLegalServices",
         u"cт. 35, п. 5 Додаткова закупівля": u"additionalPurchase",
         u"cт. 35, п. 6 Додаткові будівельні роботи": u"additionalConstruction",
         u"cт. 35, п. 2 Відсутність конкуренції": u"noCompetition",
    }.get(string, string)


def adapt_owner(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Owner"'
    tender_data['data']['procuringEntity']['identifier']['id'] = u'5555555'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['contactPoint']['url'] = u'http://www.mysite1.com/'
    tender_data['data']['procuringEntity']['contactPoint']['telephone'] = u'+380501234578'
    tender_data['data']['procuringEntity']['contactPoint']['name'] = u'тест тест'
    tender_data['data']['procuringEntity']['address']['postalCode'] = u'00000'
    tender_data['data']['procuringEntity']['address']['region'] = u'Київ'
    tender_data['data']['procuringEntity']['address']['streetAddress'] = u'вулиця Тестова, 2'
    tender_data['data']['procuringEntity']['name'] = u'ТОВ "Prom_Owner"'
    return tender_data


def adapt_viewer(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Viewer"'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['contactPoint']['url'] = u'http://webpage.org.ua/'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def adapt_provider(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Provider"'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def adapt_provider1(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Provider1"'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def adapt_provider2(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Provider2"'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def get_ecp_key(path):
    return os.path.join(os.getcwd(), path)


def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))


def covert_features(features):
    return int(features * 100)


def value_percentage(value):
    return int(value * 0.9)


def value_percentage_sum(value):
    return int(value / 0.9)


def convert_delivery_address(address):
    if u'обла' in address:
        return ''.join(address.split(' ')[:-1])
    else:
        return address


def convert_complaints_status(string):
    return {
        u"скасована": u"cancelled",
        u"розглянута замовником": u"answered",
        u"розглядається замовником": u"claim",
        u"задовільнена": u"answered",
        u"відхилена": u"declined",
        u"розглянута": u"resolved",
        u"недійсна": u"invalid"
    }.get(string, string)


def convert_complaints_resolutiontype(string):
    return {
        u"відхилена": u"declined",
        u"скасована": u"resolved",
        u"Відхилили як недійсне": u"invalid",
        u"задовільнена": u"resolved"
    }.get(string, string)


def convert_complaints_satisfied_status(string):
    return {
        u"задовільнена": True
    }.get(string, string)


def convert_plan_status(string):
    return {
        u"Запланований": u"scheduled",
        u"Допорогова закупівля": u"belowThreshold"
    }.get(string, string)

def convert_procurementmethodtype(string):
    return {
        u"Публічні закупівлі енергосервісу": u"esco",
        u"Допорогова закупівля": u"belowThreshold",
        u"Переговорна процедура для потреб оборони": u"aboveThresholdUA.defense",
        u"Укладення рамкової угоди": u"closeFrameworkAgreementUA"
    }.get(string, string)


def convert_fundingkind(string):
    return {
        u"фінансування з бюджетних коштів": u"budget"
    }.get(string, string)


def convert_esco_data(data):
    return data * 100


def revert_esco_data(data):
    return data / 100
