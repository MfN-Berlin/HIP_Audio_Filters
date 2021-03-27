'''
Created on 27.03.2021
Change speed of all files in material and
save the edited files to production
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import sys
import glob
import argparse
import traceback
import os
from arg_utils import parse_args


class SoxConverter:
    def outfile_path(self, infile, outfolder, pitch):
        """Returns the path to the out file"""
        outfile = "%s/%s_%sx.mp3" % (
            outfolder,
            os.path.basename(infile).rsplit(".", 1)[0],
            pitch
        )
        return outfile

    def process(self, infile, outfolder, pitch):
        outfile = self.outfile_path(infile, outfolder, pitch)
        command = "sox %s %s pitch -q %s" % (
            infile,
            outfile,
            float(pitch) * 1200
        )
        print(command)
        os.system(command)


if __name__ == "__main__":
    """
    Chage speed of audio files

    command-line arguments:
    @arg --in  path to folder with audio files as mounted in container
               relative to notebook-home (e.g. material)
    @arg --out path to folder where audio files will be stored as mounted
               in container relative to notebook-home (e.g. production)
    @arg --pitch shift in octaves
    """
    try:
        # Parse command-line arguments
        arg_parser = argparse.ArgumentParser()
        args = parse_args(arg_parser)

        # list all audio files in input folder
        file_list = []
        for infolder in args.infolder.split(","):
            file_list += glob.glob("%s/*.mp3" % infolder)
        # draw spectrograms all files in infolder, save to outfolder
        converter = SoxConverter()

        for infile in file_list:
            converter.process(infile, args.outfolder, args.pitch)

    except Exception as e:
        print(e)
        print(traceback.format_exc())
        arg_parser.print_help()
        sys.exit(1)
