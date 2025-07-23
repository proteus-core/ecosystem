#TODO: Use a proper logger 

GLOBAL_DEBUG = False

class Logger:
    def __init__(self, debug_mode=True):
        self.DEBUG = debug_mode

    def debug(self, message):
        if self.DEBUG or GLOBAL_DEBUG:
            print(f"DEBUG: {message}")

    def result(self, message):
        print(f"\033[0;34m RESULT:  {message} \033[0m")

    def info(self, message):
        print(f"\033[0;32m INFO:  {message} \033[0m")

    def error(self, message):
        print(f"\033[0;31m ERROR: {message} \033[0m")

    def warning(self, message):
        print(f"\033[0;33m WARNING: {message} \033[0m")