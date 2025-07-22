from vcdvcd import VCDVCD
import logger
from itertools import zip_longest
logger = logger.Logger(debug_mode=False)

def hex_or_none_to_str(value):
    if value is None:
        return "None"
    else:
        return f"{int(value, 2):<10X}"
    
def get_max_time(vcd, signals):
        return max(vcd[signal].tv[len(vcd[signal].tv) - 1][0] for signal in signals)

def get_last_value(vcd, signal):
        return vcd[signal].tv[len(vcd[signal].tv) - 1][1]

class Comparator:
    """
    A class to compare vcd files on a list of signals.

    Attributes:
    _signals (Signal): A list of security signals.
    
    Methods:
    introspect(file1, file2, mintime, maxtime): Compare two vcd files on a list of signals and print the differences.
    check_diff(file1, file2): Compare two vcd files on a list of signals.
    """
    def __init__(self, signals):
        self._signals = signals

    @property
    def signals(self):
        return self._signals

    @signals.setter
    def signals(self, signals):
        self._signals = signals   

    # Compare two vcd files on a list of signals and print the differences.
    # Useful for debugging with gtkwave.
    #
    # @arg file1, file2: base name of the files to compare (without extension)
    # @arg mintime, maxtime: the time range to compare
    def introspect(self, file1, file2, mintime=0, maxtime=0, maxsignals=0):
        vcd1 = VCDVCD(f"{file1}.vcd")
        vcd2 = VCDVCD(f"{file2}.vcd")
        if maxtime == 0:
            max1 = get_max_time(vcd1, self._signals)
            max2 = get_max_time(vcd2, self._signals)
            maxtime = max(max1, max2)


        print (f"Comparing {file1} and {file2} from {mintime} to {maxtime}")

        diffs = []
        for signal in self.signals:
            #print (f"Checking {signal}")
            signal1 = [(time, value) for time, value in vcd1[signal].tv if mintime <= time <= maxtime]
            signal2 = [(time, value) for time, value in vcd2[signal].tv if mintime <= time <= maxtime]
    
            if len(signal1) < len(signal2):
                padding_time, padding_value = signal1[len(signal1) - 1]
            else:
                padding_time, padding_value = signal1[len(signal2) - 1]

            #print(signal1)
            #print(signal2)
            for (time1, value1), (time2, value2) in zip_longest(signal1, signal2, fillvalue=(padding_time, padding_value)):
                if value1 != value2 or time1 != time2:
                    #print(f"Diff on signal {signal}")
                    diffs.append((signal, time1, value1, time2, value2))

        # Sort diffs by the minimum of both times
        diffs.sort(key=lambda x: min(x[1], x[3]))

        print(diffs)
        
        # Print the first maxsignals differences
        if maxsignals > 0 and len(diffs) > maxsignals:
            print(f"\033[0;31m--- Found {len(diffs)} differences in signals. Printing first {maxsignals} ---\033[0m")
            diffs = diffs[:maxsignals]
        
        for (signal, time1, value1, time2, value2) in diffs:
            print(f"\033[0;34m====> Signal {signal} differs \033[0m")
            str1 = f"{file1:<50} @ "
            str2 = f"{file2:<50} @ "
            if time1 != time2:
                str1 += f"\033[0;31m{time1:<10}\033[0m = "
                str2 += f"\033[0;31m{time2:<10}\033[0m = "
            else:
                str1 += f"{time1:<10} = "
                str2 += f"{time2:<10} = "
            if value1 != value2:
                str1 += f"\033[0;31m {hex_or_none_to_str(value1)} \033[0m"
                str2 += f"\033[0;32m {hex_or_none_to_str(value2)} \033[0m"
            else:
                str1 += f" {int(value1, 2):<10X}"
                str2 += f" {int(value2, 2):<10X}"
            print(str1)
            print(str2)

        if len(diffs) == 0:
            print(f"\033[0;32m--- Programs {file1} {file2} are equivalent ---\033[0m")



    # Compare two vcd files on a list of signals.
    # Return 1 if one of the signal differ (leak detected); 0 otherwise.
    # @arg file1, file2: base name of the files to compare (without extension)
    def check_diff(self, file1, file2):
        # Project on the signal
        vcd1 = VCDVCD(f"{file1}.vcd")
        vcd2 = VCDVCD(f"{file2}.vcd")

        for signal in self.signals:
            if vcd1[signal].tv != vcd2[signal].tv:
                logger.debug(f"!--- Programs {file1} {file2} differ ---!")
                logger.debug(f"+ diff on {signal}")
                logger.debug(f"+ vcd1 = {vcd1[signal].tv}")
                logger.debug(f"+ vcd2 = {vcd2[signal].tv}")
                return 1
            
        logger.debug(f"!--- Program {file1} {file2} are equivalent ---!")
        return 0