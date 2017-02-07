from ranger.api.commands import *
import subprocess
from os import getcwd

# autojump integration
# stolen from https://github.com/ranger/ranger/issues/91#issuecomment-231938613
class j(Command):
    """
    :j <directory>

    Uses autojump to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["autojump"] + self.args[1:])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip("\n")
        self.fm.execute_console("cd " + directory)

class jc(Command):
    """
    :j <directory>

    Uses autojump to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["autojump", getcwd()] + self.args[1:])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip("\n")
        self.fm.execute_console("cd " + directory)
