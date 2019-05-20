# Checksum checker by SynneK1337
# Usuful to verify if there weren' t any errors while moving file from SD Card to SSD

import hashlib
import os


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
        f.close()
        return hash_md5.hexdigest()


if __name__ == "__main__":
    sd_card_hashes = {}
    sd_card_path = input("SD Card Path: ")
    ssd_path = input("SSD Path: ")
    os.chdir(sd_card_path)
    for file in os.listdir():
        sd_card_hashes[file] = md5(file)
    os.chdir(ssd_path)
    for file in os.listdir():
        if md5(file) != sd_card_hashes[file]:
            print(f"{file} is invalid.")