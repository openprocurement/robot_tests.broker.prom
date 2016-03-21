# -*- coding: utf-8 -*-
import dateutil.parser
from datetime import timedelta, datetime


def get_all_prom_dates(INITIAL_TENDER_DATA, key):
    tender_period = INITIAL_TENDER_DATA.data.tenderPeriod
    start_dt = dateutil.parser.parse(tender_period['startDate'])
    end_dt = dateutil.parser.parse(tender_period['endDate'])
    data = {
        'EndPeriod': start_dt.strftime("%d.%m.%Y %H:%M"),
        'StartDate': start_dt.strftime("%d.%m.%Y %H:%M"),
        'EndDate': end_dt.strftime("%d.%m.%Y %H:%M"),
    }
    return data.get(key, '')


def get_delivery_date_prom(INITIAL_TENDER_DATA):
    delivery_end_date = INITIAL_TENDER_DATA.data['items'][0]['deliveryDate']['endDate']
    endDate = dateutil.parser.parse(delivery_end_date)
    return endDate.strftime("%d.%m.%Y")


def return_delivery_endDate(INITIAL_TENDER_DATA, input_date):
    init_delivery_end_date = INITIAL_TENDER_DATA.data['items'][0]['deliveryDate']['endDate']
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


def procuringEntity_name_prom(INITIAL_TENDER_DATA):
    INITIAL_TENDER_DATA.data.procuringEntity['name'] = u"Test_company_from_Prozorro"
    return INITIAL_TENDER_DATA


def convert_prom_string_to_common_string(string):
    return {
        u"Украина": u"Україна",
        u"Киевская область": u"м. Київ",
        u"килограммы": u"кілограм",
        u"кг.": u"кілограм",
    }.get(string, string)
