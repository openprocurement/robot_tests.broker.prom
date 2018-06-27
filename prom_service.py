# -*- coding: utf-8 -*-
import pytz
import dateutil.parser
import urllib
import shutil

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


def convert_to_float(price):
    return float(price.replace(',', '.'))


def iso_date(date):
    next_date = datetime.now() + timedelta(days=10)
    return next_date.strftime("%d.%m.%Y 00:00")


def convert_iso_date_to_prom(date):
    a = dateutil.parser.parse(date)
    return a.strftime("%d.%m.%Y %H:%M")


def convert_date_prom(date):
    date_obj = datetime.strptime(date, "%d.%m.%y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%d %H:%M:%S.%f%z")


def convert_dgf_date_prom(date_str):
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    return date_obj.strftime("%d.%m.%Y")


def revert_dgf_date_prom(date_str):
    date_obj = datetime.strptime(date_str, "%d.%m.%Y")
    return date_obj.strftime("%Y-%m-%d")


def convert_date_to_prom_tender_startdate(date):
    first_date = date.split(' - ')[0]
    date_obj = datetime.strptime(first_date, "%d.%m.%y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%d %H:%M:%S.%f%z")


def convert_date_to_prom_tender_enddate(date):
    second_date = date.split(' - ')[1]
    date_obj = datetime.strptime(second_date, "%d.%m.%y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%d %H:%M:%S.%f%z")


def convert_prom_string_to_common_string(string):
    return {
        u"грн": u"UAH",
        u"шт.": u"штуки",
        u"кв.м.": u"метри квадратні",
        u"м2": u"метри квадратні",
        u"м²": u"метри квадратні",
        u"метры квадратные": u"метри квадратні",
        u"метр квадратний": u"метри квадратні",
        u"Рівненська область": u"Ровненская",
        u"с НДС": True,
        u"з ПДВ": True,
        u"Класифікатор:": u"CAV-PS",
        u"Оголошення аукціону з Найму": u"Оренда",
        u"Період уточнень": u"active.enquiries",
        u"Прийом пропозицій": u"active.tendering",
        u"Аукціон": u"active.auction",
        u"Кваліфікація": u"active.qualification",
        u"Скасована": u"cancelled",
        u"Аукціон не відбувся": u"unsuccessful",
        u"Аукцион не состоялся": u"unsuccessful",
        u"Завершена": u"complete",
        u"Подписанный": u"active",
        u"Впервые": u"Лот виставляється вперше",
        u"Вперше": u"Лот виставляється вперше",
        u"Вдруге": u"Лот виставляється повторно",
        u"Повторно": u"Лот виставляється повторно",
        u"Згідно рішення Організатора торгів": u"Згідно рішення виконавчої дирекції Замовника",
        u"Завершено": u"complete",
        u"Uri:": u"UA-EDR",
    }.get(string, string)


def convert_cancellations_status(string):
    return {
        u"Скасована": u"active",
        u"Аукціон": u"active.tendering",
    }.get(string, string)


def convert_registration_details(string):
    return {
        u"complete": u"Об'єкт зареєстровано",
        u"registering": u"Об'єкт реєструється",
        u"unknown": u"За замовчуванням",
    }.get(string, string)


def revert_registration_details(string):
    return {
        u"Об'єкт зареєстровано": u"complete",
        u"Об'єкт реєструється": u"registering",
        u"За замовчуванням": u"unknown",
    }.get(string, string)


def convert_procurement_method_type(string):
    return {
        u"МАЙНО": u"dgfOtherAssets",
        u"ФІНАНСОВІ АКТИВИ": u"dgfFinancialAssets",
        u"ГОЛЛАНДСКИЙ АУКЦИОН": u"dgfInsider",
        u"ГОЛЛАНДСЬКИЙ АУКЦІОН": u"dgfInsider",
        u"Державне майно": u"dgfOtherAssets",
        u"Государственное имущество": u"dgfOtherAssets",
    }.get(string, string)


def convert_prom_code_to_common_string(string):
    return {
        u"кв.м.": u"MTK",
        u"м2": u"MTK",
        u"м²": u"MTK",
        u"послуга": u"E48",
        u"послуги": u"E48",
        u"шт.": u"H87",
        u"Класифікатор:": u"CPV",
        u"метри квадратні": u"метр квадратний",
        u"Очікує протокол": u"pending.verification",
        u"очікується протокол": u"pending.verification",
        u"Очікує рішення": u"pending.waiting",
        u"очікується кінець кваліфікації": u"pending.waiting",
        u"Пропозицію відхилено": u"unsuccessful",
        u"Очікується підписання договору": u"pending.payment",
        u"Оплачено, очікується підписання договору": u"active",
        u"Очікує розгляду": u"cancelled",
        u"Не розглядався": u"cancelled",
        u"Завершено": u"complete",
        u"Виключений з переліку": u"deleted",
        u"Опубліковано. Очікування інформаційного повідомлення.": u"pending",
        u"Опубліковано": u"pending",
        u"Аукціон": u"scheduled",
        u"Аукціон із зниженням стартової ціни": u"scheduled",
        u"Аукціон за методом покрокового зниження стартової ціни та подальшого подання цінових пропозицій": u"scheduled",
        u"Англійський аукціон": u"scheduled",
        u"Голландський аукціон": u"scheduled",
        u"Об’єкт виключено": u"deleted",
        u"cavps": u"CAV-PS",
        u"notice": u"Рішення про затвердження переліку об'єктів, що підлягають приватизації",
    }.get(string, string)


def convert_document_type(string):
    return {
        u"Додаткова інформація": u"informationDetails",
        u"Виключення з переліку": u"cancellationDetails",
        u"Рішення про затвердження переліку об'єктів, що підлягають приватизації": u"notice",
        u"Презентація": u"x_presentation",
        u"Інформація про об'єкт малої приватизації": u"technicalSpecifications",
        u"Ілюстрації": u"illustration",
    }.get(string, string)


def revert_document_type(string):
    return {
        u"informationDetails": u"Додаткова інформація",
        u"cancellationDetails": u"Виключення з переліку",
        u"notice": u"Рішення аукціонної комісії",
        u"x_presentation": u"Презентація",
        u"technicalSpecifications": u"Інформація про об'єкт малої приватизації",
        u"illustration": u"Ілюстрації",
    }.get(string, string)


def adapt_assetholder_owner(tender_data):
    tender_data['data']['assetCustodian']['identifier']['legalName'] = u'ТОВ "ЭТУ КОМПАНИЮ НЕ ТРОГАТЬ"'
    tender_data['data']['assetHolder']['identifier']['legalName'] = u'ТОВ "ЭТУ КОМПАНИЮ НЕ ТРОГАТЬ"'
    tender_data['data']['assetCustodian']['identifier']['legalName'] = u'ТОВ "ЭТУ КОМПАНИЮ НЕ ТРОГАТЬ"'
    tender_data['data']['assetHolder']['identifier']['id'] = u'2222233'
    tender_data['data']['assetCustodian']['identifier']['id'] = u'2222233'
    tender_data['data']['assetHolder']['contactPoint']['telephone'] = u'+380440000011'
    tender_data['data']['assetCustodian']['contactPoint']['telephone'] = u'+380440000011'
    tender_data['data']['assetHolder']['contactPoint']['email'] = u'test@test17.com'
    tender_data['data']['assetCustodian']['contactPoint']['email'] = u'test@test17.com'
    tender_data['data']['assetHolder']['contactPoint']['name'] = u'Авокадо Ананасович'
    tender_data['data']['assetCustodian']['contactPoint']['name'] = u'Авокадо Ананасович'
    return tender_data


def adapt_assetholder_viewer(tender_data):
    tender_data['data']['assetHolder']['identifier']['legalName'] = u'ТОВ "ЭТУ КОМПАНИЮ НЕ ТРОГАТЬ"'
    tender_data['data']['assetHolder']['identifier']['id'] = u'54353455'
    tender_data['data']['assetHolder']['contactPoint']['telephone'] = u'+380441112233'
    tender_data['data']['assetHolder']['contactPoint']['email'] = u'test@test13.com'
    tender_data['data']['assetHolder']['contactPoint']['name'] = u'Рустам Коноплянка'
    return tender_data


def adapt_qualified(tender_data, username):
    if username == 'Prom_Provider':
        if 'qualified' in tender_data['data']:
            return True
    return False


def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))