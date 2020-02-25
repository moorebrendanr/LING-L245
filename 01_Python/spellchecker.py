import sys

# Get input sentence
input = []
for line in sys.stdin.readlines():
    words = line.strip('\n').split(' ')
    for w in words:
        input.append(w)

# Loop through freq.txt one time and create a dictionary
dict = {}
fd = open('freq.txt', 'r')
for line in fd.readlines():
    freq = line.strip('\n').split('\t')
    dict[freq[1]] = freq[0]

# For each word in input, check if in dict.
for i, w in enumerate(input):
    if w not in dict:
        input[i] = '*' + w

# Assemble output string
output = ''
for word in input:
    output += (word + ' ')

print(output.strip())
