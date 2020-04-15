import sys
import string

filename_en = sys.argv[1]
filename_zu = sys.argv[2]

with open(filename_en) as f:
	lines_en = [line.rstrip().lower().translate(str.maketrans('', '', string.punctuation)) for line in f]

with open(filename_zu) as f:
	lines_zu = [line.rstrip().lower().translate(str.maketrans('', '', string.punctuation)) for line in f]

words_en = set(' '.join(lines_en).split(' '))
words_zu = set(' '.join(lines_zu).split(' '))

cooccurrances = {}
inner_dict = {}
for word_zu in words_zu:
	if word_zu not in inner_dict:
		inner_dict[word_zu] = 0
del inner_dict['']

for word_en in words_en:
	if word_en not in cooccurrances:
		cooccurrances[word_en] = inner_dict.copy()
del cooccurrances['']

for i in range(len(lines_en)):
	line_en = lines_en[i].split(' ')
	line_zu = lines_zu[i].split(' ')
	for word_en in line_en:
		for word_zu in line_zu:
			if word_en != '' and word_zu != '':
				cooccurrances[word_en][word_zu] += 1

for word_en in cooccurrances:
	total = 0
	for word_zu in cooccurrances[word_en]:
		total += cooccurrances[word_en][word_zu]
	for word_zu in cooccurrances[word_en]:
		val = cooccurrances[word_en][word_zu] / total
		print("%f\t%s\t%s" % (val, word_en, word_zu))
