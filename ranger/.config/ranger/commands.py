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
    :jc <directory>

    Uses autojump to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["autojump", getcwd()] + self.args[1:])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip("\n")
        self.fm.execute_console("cd " + directory)

# fasd/fzf integration (stolen from: https://github.com/gotbletu/shownotes/blob/master/ranger_fasd_fzf.md)


# fzf_fasd - Fasd + Fzf + Ranger (Interactive Style)
class fzf(Command):
    """
    :fzf

    Jump to a file or folder using fzf

    URL: https://github.com/junegunn/fzf
    """
    def execute(self):
        import subprocess, os
        command="locate $PWD | fzf --height=100% --preview='bash $HOME/.local/share/scripts/preview.sh {}'"
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode('utf-8').rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)

# Fasd with ranger (Command Line Style)
# https://github.com/ranger/ranger/wiki/Commands
class fasd(Command):
    """
    :fasd

    Jump to directory using fasd
    URL: https://github.com/clvv/fasd
    """
    def execute(self):
        import subprocess
        arg = self.rest(1)
        if arg:
            directory = subprocess.check_output(["fasd", "-d"]+arg.split(), universal_newlines=True).strip()
            self.fm.cd(directory)
