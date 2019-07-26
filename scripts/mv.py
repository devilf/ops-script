import re
import os
import sys
from pathlib import Path


def mv(dir, regular,add_regular):
    '''
    获取指定目录下的所有文件，并重命名
    '''
    p = Path(dir)
    for file in p.iterdir():
        if file.is_file():
            oldfile = file.name
            pattern = re.compile(regular)
            capture = pattern.search(oldfile).group(1)
            newfile = capture + add_regular
            src = Path(oldfile)
            dst = Path(newfile)
            os.chdir(dir)
            src.replace(dst)

if __name__ == '__main__':
    #dir = r'E:\python\spider\re-module\50'
    dir = sys.argv[1]
    #regular = r'([0-9A-Z_]+)[0-9_]{6}.pdf'
    regular = sys.argv[2]
    #add_regular = "_10_001.pdf"
    add_regular = sys.argv[3]
    mv(dir, regular, add_regular)


