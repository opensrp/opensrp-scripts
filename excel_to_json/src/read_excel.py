#!/usr/bin/python3
"""
"""
import click
import json
import xlrd

from processors import ANCProcessor


@click.command()
@click.option('--excel_file', prompt='Path to the excel file', help='Path to the excel file to process')
@click.option('--dump_excel_data', default=True, help='Dump the excel data to a JSON file.')
@click.option('--out_dir', prompt='out_dir', help='Folder where the JSON files will be written')
@click.option('--sheet_file_map', prompt='sheet_file_map', help='Map for the sheets in the excel to the JSON files')
def read_exel_file(excel_file, dump_excel_data, out_dir, sheet_file_map):
    """
    """
    book = xlrd.open_workbook(excel_file)

    all_data = {}
    sheets =  [sheet.name for sheet in book.sheets()]
    for k in sheets:
        print(k)
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

    obj.process_data(all_data)

if __name__ == '__main__':
    read_exel_file()
