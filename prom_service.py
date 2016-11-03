# -*- coding: utf-8 -*-
import pytz
import dateutil.parser

from datetime import datetime


def get_all_prom_dates(initial_tender_data, key):
    tender_period = initial_tender_data.data.auctionPeriod
    start_dt = dateutil.parser.parse(tender_period['startDate'])
    data = {
        'StartDate': start_dt.strftime("%d.%m.%Y %H:%M"),
    }
    return data.get(key, '')


def convert_date_prom(date):
    date_obj = datetime.strptime(date, "%d.%m.%y %H:%M")
    time_zone = pytz.timezone('Europe/Kiev')
    localized_date = time_zone.localize(date_obj)
    return localized_date.strftime("%Y-%m-%d %H:%M:%S.%f%z")


def convert_date_to_prom_tender_startdate(date):
    first_date = date.split(' - ')[0]
    convert_date_prom(first_date)


def convert_date_to_prom_tender_enddate(date):
    second_date = date.split(' - ')[1]
    convert_date_prom(second_date)


def convert_prom_string_to_common_string(string):
    return {
        u"грн.": u"UAH",
        u"шт.": u"штуки",
        u"кв.м.": u"метри квадратні",
        u"метры квадратные": u"метри квадратні",
        u" з ПДВ": True,
        u"Класифікатор:": u"CAV",
        u"Період уточнень": u"active.enquiries",
        u"Прийом пропозицій": u"active.tendering",
        u"Аукціон": u"active.auction",
        u"Кваліфікація": u"active.qualification",
    }.get(string, string)


def convert_prom_code_to_common_string(string):
    return {
        u"кв.м.": u"MTK",
        u"послуга": u"E48",
        u"послуги": u"E48",
        u"шт.": u"H87",
    }.get(string, string)


def adapt_procuringEntity(tender_data):
    tender_data['data']['procuringEntity']['name'] = u'ТОВ "ЭТУ КОМПАНИЮ НЕ ТРОГАТЬ"'
    tender_data['data']['procuringEntity']['address']['countryName'] = u"Украина"
    return tender_data


my_dict = {
    u"послуга": u"услуга",
    u"послуги": u"услуга",
    u"метри квадратні": u"метры квадратные",
}


def adapt_item(tender_data, role_name):
    if role_name != 'viewer':
        if 'unit' in tender_data['data']['items'][0]:
            for i in tender_data['data']['items']:
                i['unit']['name'] = my_dict[i['unit']['name']]
    return tender_data
