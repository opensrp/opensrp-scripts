import copy
import os
import json

import subprocess

from .base import BaseProcessor


fields_with_options = ['check_box', 'native_radio', 'MC (select one)']

simple_fields = [
    'choose_image', 'edit_text', 'hidden', 'date_picker', 'barcode',
    'numbers_selector', 'normal_edit_text','spinner',
    'Image', 'Note', 'Text', 'QR Code','Calculation', 'Integer'
]


replaceable_strings = {
    '\"dont_know\"': '\\\"dont_know\\\"',
    '\"yes\"': '\\\"yes\\\"',
    '\"no\"': '\\\"no\\\"',
    '\"specific_complaint\"': '\\\"specific_complaint\\\"',
    '\n-': '\\n-',
    '\n\n': '\\\\n\\\\n',
}


pre_and_post_process_strings = {
    '"None"': '"None_escaped"',
    # '\"38\"': 'escaped_38',
    # '\"3\"': 'escaped_3"',
    '"yes"': 'escaped_yes',
    '"no"': '"escaped_no"',
    '"3"': 'escaped_3_no_slash',
    '"1"': 'escaped_1_no_slash',
    '"2"': 'escaped_2_no_slash',
    # '\"None\"': 'escaped_none_with_slash',
}

def pre_process_file(json_file_path):
    """
    Format the JSON file to remove all the unwanted characters which cause
    JSON to fail.
    """
    for key, value in pre_and_post_process_strings.items():
        subprocess.run(
            [
                "sed",
                '-i',
                 's/{}/"{}"/g'.format(key, value),
                json_file_path]
        )
    subprocess.run(
        [
            "sed",
            '-i',
             's/\"3\"/"{}"/g'.format("escaped_38"),
            json_file_path]
    )
    subprocess.run(
            [
                "sed",
                '-i',
                 's/#"38#"/"{}"/g'.format("escaped_38"),
                json_file_path]
    )
    subprocess.run(
            [
                "sed",
                '-i',
                 's/\"None\"/"{}"/g'.format("escaped_none_with_slash"),
                json_file_path]
    )

def post_process_file(json_file_path):
    """
    Put back the characters that were removed during preprocessing.
    """


def replace_escape_chars_in_the_json_file(content):
    for key, value in replaceable_strings.items():
        content = content.replace(key, value )
    try:
        return json.loads(content)
    except Exception as error:
        raise


class ANCProcessor(BaseProcessor):
    """
    """
    def process_field_data(self, field_data, key_data, excel_row):
        """
        """
        # if field_data.get('key') == 'cardiac_exam_abnormal':
        #     import pdb
        #     pdb.set_trace()
        name =  excel_row.get('Name')
        openmrs_entity_parent = str(excel_row.get('OpenMRS entity parent')).strip()
        if openmrs_entity_parent in ['--', 'NA']:
            field_data['openmrs_entity_parent'] = ""
        elif len(openmrs_entity_parent.split('-')) == 2:

            if openmrs_entity_parent.find('AAAAA')  != -1:
                field_data['openmrs_entity_parent'] = openmrs_entity_parent.split('-')[1]
            else:
                field_data['openmrs_entity_parent'] = openmrs_entity_parent
        else:
            field_data['openmrs_entity_parent'] = openmrs_entity_parent
        openmrs_entity = excel_row.get('OpenMRS entity')
        if not openmrs_entity and not name:
            return
        if name == "NA":
            return
        openmrs_entity = str(openmrs_entity)

        if openmrs_entity == '--':
            field_data['openmrs_entity'] = ""
        elif openmrs_entity.find('Concept') == 0:
            field_data['openmrs_entity'] = 'concept'
        else:
            field_data['openmrs_entity'] = openmrs_entity
        field_data['openmrs_entity_id'] = excel_row.get('OpenMRS entity ID')

        if field_data.get('v_regex'):
            regex_data = "[A-Za-z\\\\s\\\\.\\\\-]*"
            field_data['v_regex']['value'] = regex_data
        return field_data

    def process_sub_form(self, json_files, options, excel_data, excel_row):
        for option_instance in options:
            if option_instance.get('content_form'):
                content_form_file_path = 'sub_form/' + option_instance.get('content_form')+ ('.json')
                print("Processing ==>{}".format(content_form_file_path))
                content_form_file =  os.path.join(json_files.strip(), content_form_file_path)
                with open(content_form_file, 'r', encoding='unicode_escape') as content_form_data_file:
                    try:
                        content_form_contents = json.loads(content_form_data_file.read(),  strict=False)
                        fields_in_content_form = content_form_contents.get('content_form')

                        # THis assumes that the 'key only appears in fields and not in other words'
                        # The quotes help with ensuring that other key are not counted
                        content_form_no_of_fields = json.dumps(fields_in_content_form).count('"key"')
                        new_data = {"content_form": []}
                        excel_data_index = excel_row + 1
                        for field in fields_in_content_form:
                            field_data = field
                            options_data = []
                            field_data = self.process_field_data(field_data, field, excel_data[excel_data_index])
                            if field.get('type') in fields_with_options:
                                excel_data_index += 3
                                for field_option in field.get('options'):
                                    field_option_data = self.process_field_data(field_option, field, excel_data[excel_data_index])
                                    options_data.append(field_option_data)
                                    excel_data_index += 1
                                field_data['options'] = options_data
                            else:
                                field_data = field
                                field_data = self.process_field_data(field_data, field, excel_data[excel_data_index])
                                excel_data_index += 1
                            new_data['content_form'].append(field_data)
                        with open('/tmp/sub_forms/{}'.format(option_instance.get('content_form')+ ('.json')), 'w+') as new_data_file:
                            json.dump(new_data, new_data_file, indent=4)
                            return excel_data_index
                    except:
                        raise

    def update_relevant_fields_in_the_json_file(self, excel_data, json_file_name, json_files, json_out_dir):
        """
        """
        data =  no_of_steps = None
        file_path =  os.path.join(json_files.strip(), json_file_name.strip())
        pre_process_file(file_path)
        with open(file_path, 'r', encoding='unicode_escape') as data_file:
            data = replace_escape_chars_in_the_json_file(data_file.read())
            try:
                data = json.loads(data_file.read(),  strict=False)
                data_content = data_file.read()
            except:
                data_content = data_file.read()
                # data = replace_escape_chars_in_the_json_file(data_content)
            no_of_steps = int(data.get('count'))

        for m in range(1, no_of_steps+1):
            new_data = []
            for key_data in data.get('step{}'.format(m)).get('fields'):
                field_data = key_data

                for index, row in enumerate(excel_data):
                    if not row.get('Name'):
                        # These are option fields
                        continue
                    if row.get('Name') == key_data.get('key'):
                        field_type = key_data.get('type')
                        if field_type in simple_fields:
                            field_data = self.process_field_data(field_data, key_data, row)
                            if not field_data:
                                continue
                        elif field_type in fields_with_options:
                            field_data = self.process_field_data(field_data, key_data, row)
                            options = key_data.get('options')
                            self.process_sub_form(json_files, options, excel_data, index+1)

                            number_of_options = len(options)
                            x = 0
                            all_options = []
                            new_index = index

                            while x < number_of_options:
                                options_data = options[x]
                                option_field_data = self.process_field_data(options_data, options_data, excel_data[new_index+1])
                                if  option_field_data:
                                    all_options.append(option_field_data)
                                x += 1
                                new_index += 1
                            field_data['options'] = all_options

                        else:
                            raise Exception("Unknown field has been seen ===> {}".format(field_type))


                new_data.append(field_data)
                data['step{}'.format(m)]['fields'] = new_data

        with open('{}/{}'.format(json_out_dir,json_file_name), 'w+') as new_data_file:
            json.dump(data, new_data_file, indent=4)


    def process_data(self, excel_data, json_files, json_out_dir):
        sheet_file_map = {
        # 'ANC Reg': 'anc_register',
        # 'Quick Check':'anc_quick_check',
        # 'Profile': 'anc_profile',
        # 'S&F': 'anc_symptoms_follow_up',
        'PE': 'anc_physical_exam',
        # 'Tests': 'anc_test',
        # 'C&T': 'anc_counselling_treatment',
        # 'CASE INVESTIGATION FORM FOR AEF':'',
        # 'Vaccine Override': None,
        # 'Summary': None,
        # 'Contact Summary': None,
        # 'Profile Overview': None,
        # 'ANC Close':'anc_close',
        # 'Attn flags': None,
        # 'Pop Charact.': None,
        # 'Site Charact.': 'anc_site_characteristics',
        # 'LocationsUsers': None,
        # 'Advanced Search': None,
        # 'FilterSort Parameters': None,
        # 'Index': None,
        }
        for k, v in sheet_file_map.items():
            json_file_name = '{}.json'.format(v)
            sheet_data =  copy.deepcopy(excel_data.get(k))
            self.update_relevant_fields_in_the_json_file(
                sheet_data,
                json_file_name, json_files, json_out_dir
            )

