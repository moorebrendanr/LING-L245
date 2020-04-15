import sys
import string

input = sys.stdin.read()
file_name = sys.argv[1]

translations = {}
with open(file_name) as f:
	max_prob = 0
	for line in f:
		line = line.rstrip().split("\t")
		prob = float(line[0])
		if line[1] not in translations or prob > max_prob:
			max_prob = prob
			translations[line[1]] = line[2]

text = input.lower().translate(str.maketrans('', '', string.punctuation))
words = text.split(' ')
output = ''
for word in words:
	if word not in translations:
		output += '*' + word + ' '
	else:
		output += translations[word] + ' '

print(output.rstrip())
