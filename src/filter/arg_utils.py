def parse_args(arg_parser):
    """
    Parse the command-lline arguments

    @param arg_parser ConfigParser object
    """
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

    # Parse command-line options
    if (args.infolder is None or args.outfolder is None):
        raise Exception("Missing folder paths")
    if (args.configpath is None):
        raise Exception("Missing path to configuration file")
    return args
