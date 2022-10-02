

from dataclasses import dataclass
import sys
import os
import zipfile
import pandas
import logging

logger = logging.getLogger(__name__)


def import_seq_lookup():
    data = {}
    
    return data


def import_geo():
    pass

def import_estimate(zf, component, config_info):

    fnames = list(config_info["row_hdr_flds"].keys())
    data_range = config_info["tables_by_sequence"]["0069"]
    zc = zf.open(component, "r")
    col_types = config_info["row_hdr_flds"]
    wd = zc.readline()[:-1].decode()
    
    zc.seek(0)
    seq = component.filename[8:12].lstrip('0')

    for pc in range(1, len(wd.split(',')) - len(fnames)):
        fnames.append(f"P{seq}{pc:05d}")

    df = pandas.read_csv(zc, header=0, names=fnames, dtype = 'float64', converters = col_types) 
    zc.close()

    df.head(n=15)
    df.save_sqlite3("my.sqlite3", append=True) 

def import_margin():
    pass

def scan_archive(archiveName, config_info):
    zf = zipfile.ZipFile(archiveName, 'r')
    zi = zf.infolist()

    for itm in zi:
        if itm.file_size > 0:
                if itm.filename.startswith('e'):
                    import_estimate(zf, itm, config_info)
                elif itm.filename.startswith('m'):
                    import_margin(zf, itm, config_info)
                elif itm.filename.startswith('g'):
                    import_geo(zf, itm, config_info)
                else:
                    logger.warning(f"failed to understand, {itm.filename}, inside {zf.filename}")

def main(args=[]):

    config_info = {
        "row_hdr_flds": {"filetype": str, "fileid": str, "state": str, "county": str, "sequence": str, "recno": str},
        "tables_by_sequence": {"0069": [1, 20]}
    }
    scan_archive("Alabama_Tracts_Block_Groups_Only.zip", config_info)

    logger.info("All Done")

if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)

    main(sys.argv)
