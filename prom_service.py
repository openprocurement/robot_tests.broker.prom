# -*- coding: utf-8 -*-
import dateutil.parser
from datetime import datetime


def get_all_prom_dates(initial_tender_data, key):
    tender_period = initial_tender_data.data.tenderPeriod
    start_dt = dateutil.parser.parse(tender_period['startDate'])
    end_dt = dateutil.parser.parse(tender_period['endDate'])
    data = {
        'EndPeriod': start_dt.strftime("%d.%m.%Y %H:%M"),
        'StartDate': start_dt.strftime("%d.%m.%Y %H:%M"),
        'EndDate': end_dt.strftime("%d.%m.%Y %H:%M"),
    }
    return data.get(key, '')


def get_delivery_date_prom(initial_tender_data):
    delivery_end_date = initial_tender_data.data['items'][0]['deliveryDate']['endDate']
    endDate = dateutil.parser.parse(delivery_end_date)
    return endDate.strftime("%d.%m.%Y")


def return_delivery_endDate(initial_tender_data, input_date):
    init_delivery_end_date = initial_tender_data.data['items'][0]['deliveryDate']['endDate']
    if input_date in init_delivery_end_date:
        return init_delivery_end_date
    else:
        return input_date


def convert_delivery_date_prom(isodate):
    return datetime.strptime(isodate, '%d.%m.%y').date().isoformat()


def convert_date_to_prom_tender_startdate(isodate):
    first_date = isodate.split(' - ')[0]
    first_iso = datetime.strptime(first_date, "%d.%m.%y %H:%M").isoformat()
    return first_iso


def convert_date_to_prom_tender_enddate(isodate):
    second_date = isodate.split(' - ')[1]
    second_iso = datetime.strptime(second_date, "%d.%m.%y %H:%M").isoformat()
    return second_iso


def procuringEntity_name_prom(initial_tender_data):
    initial_tender_data.data.procuringEntity['name'] = u"Test_company_from_Prozorro"
    return initial_tender_data


def convert_prom_string_to_common_string(string):
    return {
        u"Украина": u"Україна",
        u"Киевская область": u"м. Київ",
        u"килограммы": u"кілограм",
        u"кг.": u"кілограм",
        u"грн.": u"UAH",
        u" з ПДВ": True,
        u"Картонки": u"Картонні коробки",
    }.get(string, string)
