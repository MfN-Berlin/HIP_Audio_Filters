# -*- coding: utf-8 -*-
'''
Created on 29.10.2020
Apply audio filters to a file and save the filtered file
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import os


class AbstractFilter:
    """
    Abstract base class for Filter classes
    """

    def apply(self, infile, outpath):
        """
        @param infile String path to file to filter
        @param outpath String path to where the filtered files will be stored
        """
        raise Exception("Unimplemented abstract method")


class Sox_Filter(AbstractFilter):
    """
    Filter audio files using sox (http://sox.sourceforge.net/).
    Filter definitions are in
    https://github.com/MfN-Berlin/HIP_Audio_Filters/wiki/Filters
    """

    def __init__(self, name, definition):
        """
        Filters should be instantiated through FilterFactory.
        Filter_Factory reads the name and definition from config.ini
        @param name String name of the filter
        @param definition String definition of the filter
        """
        self.name = name
        self.definition = definition

    def apply(self, infile, outpath):
        """
        override abstract method in AbstractFilter
        """
        outfile = "%s/Filtered_%s_%s" % (outpath,
                                         self.name, os.path.basename(infile))
        command = "sox %s %s %s" % (infile, outfile, self.definition)
        os.system(command)
