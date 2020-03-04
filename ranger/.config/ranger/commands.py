from ranger.api.commands import Command
import subprocess
import os


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


# tmux integration
class open_with_tmux(Command):
    '''
    :open_with_tmux application|mode split_arg
    The first argument is either the name of an application (e.g. `vim`)
    or a number displayed by `draw_possible_programs` (e.g. `1`).
    split arg can be e.g. `splitw -h` or `neww -d`
    '''

    def is_nonnegative_int(_self, s):
        '''
        check if the argument is an ingeger >= 0
        '''
        try:
            return int(s) >= 0
        except ValueError:
            return False

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

    def make_name(self, file_paths):
        '''
        Come up with a reasonable default name for a new tmux window.
        Fit as many files as possible into the name and truncate it if it gets
        longer than MAX_NAME_LENGTH.
        '''
        from os.path import basename
        # must be >= 3
        MAX_NAME_LENGTH = 16
        name = ''
        for f in file_paths:
            name += basename(f) if name == '' else ',' + basename(f)
            if len(name) >= MAX_NAME_LENGTH:
                break
        else:  # the loop did not encounter a break statement
            if len(name) > MAX_NAME_LENGTH:
                return name[:MAX_NAME_LENGTH - 1] + '…'
            else:
                return name
        # here we know that the size of name is >= MAX_NAME_LENGTH
        return name[:MAX_NAME_LENGTH - 3] + '…,…'

    def maybe_name(self, file_paths):
        '''
        return arguments for tmux neww to change the name of the new window
        if no new window is being created, return an empty list
        '''
        if self.args[2] == 'neww' or self.args[2] == 'new-window':
            return ['-n', self.make_name(file_paths)]
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
        if self.is_nonnegative_int(self.args[1]):
            rifle_args = ['-p', self.args[1]]
        else:
            rifle_args = ['-w', self.args[1]]
        file_list = list(self.stringified_selection())
        args = ['tmux'] + self.args[2:] + self.maybe_name(file_list) + \
               ['--', 'rifle'] + rifle_args + ['--'] + file_list
        for _ in range(self.quantifier or 1):
            try:
                subprocess.run(args, cwd=str(self.fm.thisdir), check=True,
                               shell=False, capture_output=True)
            except OSError as e:
                self.fm.notify(str(e), bad=True)
                return
            except subprocess.CalledProcessError as e:
                self.fm.notify('tmux failed: ' + e.stderr.decode('utf-8'),
                               bad=True)
                return
