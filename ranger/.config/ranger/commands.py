from os.path import basename
import subprocess
import os

from ranger.api.commands import Command


# autojump integration
# stolen from https://github.com/ranger/ranger/issues/91#issuecomment-231938613
class j(Command):
    '''
    :j <directory>

    Uses autojump to set the current directory.
    '''

    def execute(self):
        directory = subprocess.check_output(['autojump'] + self.args[1:])
        directory = directory.decode('utf-8', 'ignore')
        directory = directory.rstrip('\n')
        self.fm.cd(directory)


class jc(Command):
    '''
    :jc <directory>

    Uses autojump to set the current directory.
    '''

    def execute(self):
        directory = subprocess.check_output(
            ['autojump', os.getcwd()] + self.args[1:]
        )
        directory = directory.decode('utf-8', 'ignore')
        directory = directory.rstrip('\n')
        self.fm.cd(directory)


# fzf integration
# (stolen from:
#  https://github.com/gotbletu/shownotes/blob/master/ranger_fasd_fzf.md)
class fzf(Command):
    '''
    :fzf

    Jump to a file or folder using fzf

    URL: https://github.com/junegunn/fzf
    '''
    def execute(self):
        command = 'locate "$PWD" | fzf ' \
            + '--height=100% --preview="bash $HOME/.local/bin/preview.sh {}"'
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode('utf-8').rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


def make_limited_length_name(file_paths, max_name_length=16):
    '''
    Come up with a reasonable default name for a new tmux window.
    Fit as many files as possible into the name and truncate it if it gets
    longer than max_name_length.

    max_name_length must be >= 3.
    '''
    name = ''
    i = 0
    for i, path in enumerate(file_paths):
        name += basename(path) if name == '' else ',' + basename(path)
        if len(name) >= max_name_length:
            break
    else:  # the loop did not encounter a break statement
        if len(name) > max_name_length:
            return name[:max_name_length - 1] + '…'
        return name
    # here we know that the size of name is >= max_name_length
    if i < len(file_paths) - 1:
        return name[:max_name_length - 3] + '…,…'
    return name[:max_name_length - 1] + '…'


def is_nonnegative_int(number):
    '''
    check if the argument (string or integer) is an ingeger >= 0
    '''
    try:
        return int(number) >= 0
    except ValueError:
        return False


# tmux integration
class open_with_tmux(Command):
    '''
    :open_with_tmux application|mode split_arg
    The first argument is either the name of an application (e.g. `vim`)
    or a number displayed by `draw_possible_programs` (e.g. `1`).
    split arg can be e.g. `splitw -h` or `neww -d`
    '''

    def stringified_selection(self):
        '''
        Convert a ranger selection into a list of strings (of the paths).
        Use relative or absolute paths, depending on which is shorter.
        '''
        from os import path
        sel = self.fm.thistab.get_selection()
        for f in sel:
            path1 = path.abspath(f.path)
            path2 = path.relpath(f.path, start=str(self.fm.thisdir))
            if len(path1) < len(path2):
                yield path1
            else:
                yield path2

    def maybe_name(self, file_paths):
        '''
        return arguments for tmux neww to change the name of the new window
        if no new window is being created, return an empty list
        '''
        if self.args[2] == 'neww' or self.args[2] == 'new-window':
            return ['-n', make_limited_length_name(file_paths)]
        else:
            return []

    def execute(self):
        if len(self.args) < 3:
            self.fm.notify('usage: open_with_tmux application|mode split_arg',
                           bad=True)
            return
        if 'TMUX' not in os.environ:
            self.fm.notify('this command can only be used from within tmux',
                           bad=True)
            return
        if is_nonnegative_int(self.args[1]):
            rifle_args = ['-p', self.args[1]]
        else:
            rifle_args = ['-w', self.args[1]]
        file_list = list(self.stringified_selection())
        args = ['tmux'] + self.args[2:] + self.maybe_name(file_list) + \
               ['--', 'rifle'] + rifle_args + ['--'] + file_list
        for _ in range(self.quantifier or 1):
            try:
                subprocess.run(args, cwd=str(self.fm.thisdir), check=True,
                               shell=False, capture_output=False)
            except OSError as exception:
                self.fm.notify(str(exception), bad=True)
                return
            except subprocess.CalledProcessError as exception:
                self.fm.notify('tmux failed: ' + exception.stderr.decode('utf-8'), bad=True)
                return
