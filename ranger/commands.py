from ranger.api.commands import *
import subprocess

# autojump integration
# stolen from https://github.com/ranger/ranger/issues/91#issuecomment-231938613
class j(Command):
    """
    :j <directory>

    Uses autojump to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["autojump", self.arg(1)])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip('\n')
        self.fm.execute_console("cd " + directory)
