
import sys
import os
import glob

"""471      data WORK.SHOES    ;
472      %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
473      infile 'C:\myfiles\test.csv' delimiter = ',' MISSOVER DSD lrecl=32767 ;
474         informat VAR1 $27. ;
475         informat VAR2 $6. ;
476         informat VAR3 $13. ;
477         informat VAR4 $4. ;
478         informat VAR5 $10. ;
479         informat VAR6 $10. ;
480         informat VAR7 $8. ;
481         format VAR1 $27. ;
482         format VAR2 $6. ;
483         format VAR3 $13. ;
484         format VAR4 $4. ;
485         format VAR5 $10. ;
486         format VAR6 $10. ;
487         format VAR7 $8. ;
488      input
489                  VAR1 $
490                  VAR2 $
491                  VAR3 $
492                  VAR4 $
493                  VAR5 $
494                  VAR6 $
495                  VAR7 $
496      ;
497      if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection
497! macro variable */
498      run;
"""

