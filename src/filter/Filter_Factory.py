'''
Created on 29.10.2020
Create filter objects from configuration file
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''


class Filter_Factory:
    def __init__(self, outpath, config):
        """
        @param outpath String path to where the filred files will be stored
        @param config ConfigParser object
        """
        self.outpath = outpath
        self.config = config

    def all_filters(self):
        pass
