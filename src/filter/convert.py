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
from Timer import Timer
from Filter_Factory import Filter_Factory

if __name__ == "__main__":
    """
    Filter audio files.
    Filter definitions are in
    https://github.com/MfN-Berlin/HIP_Audio_Filters/wiki/Filters

    @arg --in  path to folder with audio files as mounted in container
               relative to notebook-home (e.g. material)
    @arg --out path to folder where audio files will be stored as mounted
               in container relative to notebook-home (e.g. production)
    """
    try:
        # Performance
        with Timer() as t:
            # Parse command-line options
            arg_parser = argparse.ArgumentParser()
            arg_parser.add_argument(
                "-i", "--in", dest="infolder",
                help="path to folder with audio files as mounted in container \
                relative to notebook-home, e.g. material")
            arg_parser.add_argument(
                "-o", "--out", dest="outfolder",
                help="path to folder where audio files will be stored as \
                mounted in container relative to notebook-home, e.g. production")
            arg_parser.add_argument(
                "-c", "--configuration", dest="configpath",
                help="path to folder where audio files will be stored as \
                mounted in container relative to notebook-home, e.g. production")
            args = arg_parser.parse_args()
            if (args.infolder is None or args.outfolder is None):
                raise Exception("Missing folder paths")
            if (args.configpath is None):
                raise Exception("Missing path to configuration file")

            # Read the configuration file
            config = configparser.ConfigParser()
            config.read(args.configpath)

            # list all audio files in material folder
            file_list = glob.glob("%s/*.mp3" % args.infolder)

            # apply filters to all files
            factory = Filter_Factory(args.outfolder, config)
            filters = factory.all_filters()

        print("\n= Total time =======================")
        print("Total {:06.4f} s\n".format(t.interval))

    except Exception as e:
        print(e)
        arg_parser.print_help()
        sys.exit(1)
