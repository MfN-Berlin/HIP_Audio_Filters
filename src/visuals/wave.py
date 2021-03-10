'''
Created on 11.11.2020
Apply audio filters to all files in material and
save the filtered files to production
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import sys
import glob
import argparse
import traceback
from arg_utils import parse_args
from Visuals import FfmpegWave

if __name__ == "__main__":
    """
    Draw waveform of audio files

    command-line arguments:
    @arg --in  path to folder with audio files as mounted in container
               relative to notebook-home (e.g. material)
    @arg --out path to folder where audio files will be stored as mounted
               in container relative to notebook-home (e.g. production)
    @arg --tool ffmpeg
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
        if args.tool == 'ffmpeg':
            wave = FfmpegWave()
        else:
            raise "Only 'tool ffmpeg' is implemented"

        for infile in file_list:
            wave.draw(infile, args.outfolder)

    except Exception as e:
        print(e)
        print(traceback.format_exc())
        arg_parser.print_help()
        sys.exit(1)
