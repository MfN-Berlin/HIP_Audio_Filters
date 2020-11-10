'''
Created on 29.10.2020
Create filter objects from configuration file
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
from Filter import Sox_Filter


class Filter_Factory:
    def __init__(self, config):
        """
        @param config ConfigParser object
        """
        self.config = config
        self.filters = self._instantiate_filters(self.config)

    def all_filters(self):
        """
        @return dict of Filter objects
        """
        return(self.filters)

    def _instantiate_filters(self, config):
        """
        @param config ConfigParser a parsed configuration file
        @return a dict of filters
        """
        resp = {}
        for f in config['filters']:
            definition = config.get('filters', f)
            resp[f] = Sox_Filter(f, definition)
        return resp
