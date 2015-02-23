import json
import codecs
import copy

output_file_path = "abbreviations.json"
combined_path = "abbs-combined.json"
special_path = "abbs-specialchars.json"

combined_read = codecs.open(combined_path, mode='r', encoding='utf-8')
combined = json.load(combined_read)
combined_read.close()

fixed = {}

for abbreviation in combined[4516:4521]:
	fixed[abbreviation['id']] = copy.deepcopy(abbreviation)

	abb = fixed[abbreviation['id']]

print fixed

# json_write = codecs.open(json_file_path, mode='w', encoding='utf-8')
# json_str = json.dumps(third_list).encode('utf8', 'replace')
# json_write.write(json_str)
# json_write.close()