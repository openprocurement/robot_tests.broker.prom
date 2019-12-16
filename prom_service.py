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
    next_date = datetime.now() + timedelta(minutes=50)
    return next_date.strftime("%d.%m.%Y %H:%M")


def convert_iso_date_to_prom(date):
    convert_date = dateutil.parser.parse(date) + timedelta(minutes=-2)
    return convert_date.strftime("%d.%m.%Y %H:%M")


def convert_iso_date_to_prom_without_time_one(date):
    convert_date = dateutil.parser.parse(date) + timedelta(days=3)
    return convert_date.strftime("%d.%m.%Y")


def convert_iso_date_to_prom_without_time_two(date):
    convert_date = dateutil.parser.parse(date) + timedelta(days=4)
    return convert_date.strftime("%d.%m.%Y")


def convert_iso_date_to_prom_without_time_three(date):
    convert_date = dateutil.parser.parse(date) + timedelta(days=5)
    return convert_date.strftime("%d.%m.%Y")


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


def adapt_owner(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Owner"'
    tender_data['data']['procuringEntity']['identifier']['id'] = u'13313462'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def adapt_viewer(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Viewer"'
    tender_data['data']['procuringEntity']['identifier']['id'] = u'13313462'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'тест тест'
    return tender_data


def adapt_provider(tender_data):
    tender_data['data']['procuringEntity']['identifier']['legalName'] = u'ТОВ "Prom_Provider1"'
    tender_data['data']['procuringEntity']['identifier']['id'] = u'13313462'
    tender_data['data']['procuringEntity']['identifier']['scheme'] = u'UA-EDR'
    tender_data['data']['procuringEntity']['name'] = u'test test'
    return tender_data


def adapt_test_mode(tender_data):
    try:
        del tender_data['data']['mode']
    except KeyError:
        pass
    return tender_data


def adapt_qualified(tender_data, username):
    if username == 'Prom_Provider':
        if 'qualified' in tender_data['data']:
            return True
    return False


def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))
