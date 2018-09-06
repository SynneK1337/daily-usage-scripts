# Duplicates deleter developed by synnek1337.
import hashlib
import os

path = input("Path: ")
os.chdir(path)
filenames = os.listdir(path)
hashes = []


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
        if hash_md5.hexdigest() in hashes:
            os.remove(fname)
            print("{} removed.".format(fname))
        hashes.append(hash_md5.hexdigest())


for filename in filenames:
    md5(filename)
