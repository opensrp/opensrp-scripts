import os
import json

from .base import BaseProcessor


fields_with_options = ['check_box', 'native_radio', ]

simple_fields = [
    'choose_image', 'edit_text', 'hidden', 'date_picker', 'barcode',
    'numbers_selector', 'normal_edit_text'
]


class ANCProcessor(BaseProcessor):
    """
    """
    def process_field_data(self, field_data, key_data, excel_row):
        """
        """
        name =  excel_row.get('Name')
        openmrs_entity_parent = str(excel_row.get('OpenMRS entity parent')).strip()
        if openmrs_entity_parent in ['--', 'NA']:
            field_data['openmrs_entity_parent'] = ""
        elif len(openmrs_entity_parent.split('-')) == 2:

            if openmrs_entity_parent.find('AAAAA')  != -1:
                field_data['openmrs_entity_parent'] = openmrs_entity_parent.split('-')[1]
            else:
                field_data['openmrs_entity_parent'] = openmrs_entity_parent
            print("Nimekucheki {}".format(openmrs_entity_parent))
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

    def update_relevant_fields_in_the_json_file(self, excel_data, json_file_name):
        """
        """
        new_data = []
        data =  no_of_steps = None
        file_path =  os.path.join('json_files', json_file_name)
        with open(file_path, 'r', encoding='unicode_escape') as data_file:

            data = json.loads(data_file.read(),  strict=False)
            no_of_steps = int(data.get('count'))

        for m in range(1, no_of_steps+1):
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
                            print("Seen a field with options")
                            field_data = self.process_field_data(field_data, key_data, row)
                            options = key_data.get('options')
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

        with open('json_files/_new{}'.format(json_file_name), 'w+') as new_data_file:
            json.dump(data, new_data_file, indent=4)
            print("Done")


    def process_data(self, excel_data):
        sheet_file_map = {
        # 'ANC Reg': 'anc_register',
        'Quick Check':'anc_quick_check',
        'Profile': 'anc_profile',
        'S&F': 'anc_symptoms_follow_up',
        # 'PE': 'anc_physical_exam',
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
            self.update_relevant_fields_in_the_json_file(
                excel_data.get(k),
                json_file_name
            )

