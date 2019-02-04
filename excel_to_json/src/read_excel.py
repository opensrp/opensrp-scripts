#!/usr/bin/python3
"""
"""
import click
import json
import xlrd

from processors import ANCProcessor

path = '/home/brian/Desktop'
excel = path +'/de_excel.xlsx'
json_files_path =  path + '/opensrp_client_forms'

json_out_dir =  path + '/opensrp_result'

@click.command()
@click.option('--excel_file', default=excel, prompt='Path to the excel file', help='Path to the excel file to process')
@click.option('--json_files', default=json_files_path, prompt='path to the source json files', help='Dump the excel data to a JSON file.')
@click.option('--json_out_dir', default=json_out_dir, prompt='out_dir', help='Folder where the JSON files will be written')
def read_exel_file(excel_file, json_files, json_out_dir):
    """
    """
    book = xlrd.open_workbook(excel_file)

    all_data = {}
    sheets =  [sheet.name for sheet in book.sheets()]
    for k in sheets:
        sheet =  book.sheet_by_name(k)
        num_columns = sheet.ncols
        num_rows = sheet.nrows
        col_titles = sheet.row(0)
        sheet_data = []
        for x in range(num_rows):
            if x == 0:
                continue
            row_data = sheet.row(x)
            row_dict_data = dict(zip(col_titles, row_data))
            formatted_data = {p.value:q.value for p,q in row_dict_data.items()}
            sheet_data.append(formatted_data)
        all_data[k] = sheet_data

    obj = ANCProcessor()

    obj.process_data(all_data, json_files, json_out_dir)

if __name__ == '__main__':
    read_exel_file()
