class Logger:
    def __init__(self, debug_mode: bool = True) -> None:
        self.DEBUG = debug_mode

    def debug(self, message: str) -> None:
        if self.DEBUG:
            print(f"DEBUG: {message}")

    def result(self, message: str) -> None:
        print(f"\033[0;34m RESULT:  {message} \033[0m")

    def info(self, message: str) -> None:
        print(f"\033[0;32m INFO:  {message} \033[0m")

    def error(self, message: str) -> None:
        print(f"\033[0;31m ERROR: {message} \033[0m")

    def warning(self, message: str) -> None:
        print(f"\033[0;33m WARNING: {message} \033[0m")

log = Logger()
