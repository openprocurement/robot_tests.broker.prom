# -*- coding: utf-8 -*-
from datetime import timedelta, datetime


def get_all_prom_dates(period_interval=31):
    now = datetime.now()
    return {
        'EndPeriod': (now + timedelta(minutes=8)).strftime("%d.%m.%Y %H:%M"),
        'StartDate': (now + timedelta(minutes=8)).strftime("%d.%m.%Y %H:%M"),
        'EndDate': (now + timedelta(minutes=(8 + period_interval))).strftime("%d.%m.%Y %H:%M"),
    }


def convert_date_to_prom_tender(isodate):
    first_iso = datetime.strptime(isodate, "%d.%m.%y").isoformat()
    return first_iso


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
    }.get(string, string)
