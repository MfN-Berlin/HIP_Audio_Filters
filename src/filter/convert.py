'''
Created on 29.10.2020
Apply audio filters to all files in material and
save the filtered files to production
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import sys
import glob
import argparse
import configparser
import traceback
from arg_utils import parse_args
from Timer import Timer
from Filter_Factory import Filter_Factory

if __name__ == "__main__":
    """
    Filter audio files.
    Filter definitions are in
    https://github.com/MfN-Berlin/HIP_Audio_Filters/wiki/Filters

    command-line arguments:
    @arg --in  path to folder with audio files as mounted in container
               relative to notebook-home (e.g. material)
    @arg --out path to folder where audio files will be stored as mounted
               in container relative to notebook-home (e.g. production)
    @arg --config String path to configuration file with the filter definitions
    """
    try:
        # Performance
        with Timer() as t:
            # Parse command-line arguments
            arg_parser = argparse.ArgumentParser()
            args = parse_args(arg_parser)

            # Read the configuration file
            config = configparser.ConfigParser()
            config.read(args.configpath)

            # list all audio files in input folder
            file_list = glob.glob("%s/*.mp3" % args.infolder)

            # apply filters to all files in infolder, save to outfolder
            factory = Filter_Factory(config)
            filters = factory.all_filters()
            for infile in file_list:
                for flt in filters:
                    filters[flt].apply(infile, args.outfolder)

        print("\n= Total time =======================")
        print("Total {:06.4f} s\n".format(t.interval))

    except Exception as e:
        print(e)
        print(traceback.format_exc())
        arg_parser.print_help()
        sys.exit(1)
