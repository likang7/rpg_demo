import sys 
import os

def ansi2utf8(dirPath):
	filenames = os.listdir(dirPath)
	for filename in filenames:
		filePath = os.path.join(dirPath, filename)
		with open(filePath, 'r') as f:
			s = f.read().decode('gb2312').encode('utf-8')
			f.close()
			f = open(filePath, 'w')
			f.write(s)
			f.close()

if __name__ == '__main__':
	dirPath = sys.argv[1]
	ansi2utf8(dirPath)
