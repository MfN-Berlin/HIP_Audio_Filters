# -*- coding: utf-8 -*-
'''
Created on 11.11.2020
Draw a spectrogram using sox
@author: Alvaro Ortiz for Museum fuer Naturkunde Berlin
'''
import os


class Sox_Spectro():
    def draw(self, infile, outpath):
        """
        Draw spectrograms using sox (http://sox.sourceforge.net/).
        """
        outfile = "%s/%s_spg.png" % (
            outpath,
            os.path.basename(infile).split(".")[0]
        )
        print(outfile)

        command = "sox %s -n remix 1 spectrogram -x 630 -y 80 -l -m -c "" -a -r -o %s" % (
            infile,
            outfile
        )
        os.system(command)
