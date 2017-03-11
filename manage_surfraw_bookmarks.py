#!/usr/bin/env python3

# from html.parser import HTMLParser
from os.path import expanduser
from bs4 import BeautifulSoup
from sys import stderr
import urllib.request

BOOKMAKRS_FILE = expanduser("~/.config/surfraw/bookmarks")
MAX_LENGTH_NAME = 42
MAX_LENGTH_TITLE = 42
MAX_LENGTH_TAGS = 42
MAX_LENGTH_URL = 42

# class FindTitleParser(HTMLParser):
#     def __init__(self):
#         super().__init__()
#         self.title = False
#         self.callback = None
#     def handle_starttag(self, tag, attrs):
#         print("starttag: " + str(tag))
#         self.title = tag == "title"
#     def handle_endtag(self, tag):
#         self.title = False
#     def handle_data(self, data):
#         if self.title:
#             print("data: " + str(data))
#             self.callback(data)
#             super().reset()
#     def feed(self, data, callback):
#         self.callback = callback
#         super().feed(data)

# expected format for bookmarks
# <name> <url> ;; <tags seperated by commas> ;; <page title>
# if there are no tags or no title, use special value:
NO_VALUE = "NONE"
class Bookmark():
    def __init__(self, s):
        import re
        split = s.split(None, 1)
        if not len(split) == 2:
            raise ValueError("not a valid bookmark: " + str(s))
        self.name = split[0].strip()
        split2 = [ i.strip() for i in split[1].split(";;", 2) ]
        if not len(split2) == 3:
            raise ValueError("not a valid bookmark: " + str(s))
        self.url = split2[0].strip()
        if split2[1].strip() == NO_VALUE:
            self.tags = []
        else:
            self.tags = [ t.strip() for t in split2[1].strip().split(",") ]
            self.tags.sort()
        self.title = None if split2[2].strip() == NO_VALUE else split2[2].strip()
        self.tags_regex = re.compile("^\w+(?:,\w+)*$")
        self.name_regex = re.compile("^\w+$")
    def set_title(self, title):
        if title == NO_VALUE:
            self.title = None
        else:
            old = self.title
            self.title = title.strip() or None
            if old != self.title:
                print("updating title of {}; change from {} to {}".format(self.url,
                    old, self.title))
    def set_url(self, url):
        if not url: raise ValueError("invalid url")
        try:
            urllib.request.urlopen(url)
        except Exception as e:
            raise ValueError("invalid url: {} ({})".format(url, e))
        old = self.url
        self.url = url.strip()
        if old != self.url:
            print("updating url of {} from {} to {}".format(self.name, old,
                self.url))
    def set_tags(self, tags):
        if tags == NO_VALUE:
            self.tags = []
        else:
            if tags is not None and not self.tags_regex.match(tags):
                raise ValueError("invalid tags: {}".format(tags))
            old = self.tags
            self.tags = tags.strip().split(",")
            self.tags.sort()
            if old != self.tags:
                print("updating tags of {} from {} to {}".format(self.name, old,
                    self.tags))
    def set_name(self, new_name):
        if not new_name or not self.name_regex.match(new_name):
            raise ValueError("invalid name: {}".format(new_name))
        self.name = new_name
    def get_surfraw_format(self):
        if not self.name or not self.url:
            raise ValueError("invalid bookmark")
        return "{name} {url} ;; {tags} ;; {title}".format(
            name=self.name,
            url=self.url,
            tags=",".join(self.tags) if self.tags else NO_VALUE,
            title=self.title or NO_VALUE)
    def get_tags_string(self):
        if not self.tags: return ""
        else: return ",".join(self.tags)



def read_bookmarks(path):
    bookmarks = []
    with open(path, "r") as marks:
        for line in marks: bookmarks.append(Bookmark(line.strip()))
    return bookmarks

def update_titles(bookmarks):
    # parser = FindTitleParser()
    for bookmark in bookmarks:
        update_title(bookmark)

def update_title(bookmark):
    # from sys import stderr
    # resource = urllib.request.urlopen(bookmark.url)
    # content = resource.read().decode(resource.headers.get_content_charset())
    # print("updating bookmark {}: old title: {}".format(bookmark.url, bookmark.title))
    # try:
    #     parser.feed(content, lambda data: bookmark.set_title(data))
    # except Exception as e:
    #     print("an exception occurred while updating the title: " + str(e), file=stderr)
    # print("        new title: {}".format(bookmark.title))
    soup = BeautifulSoup(urllib.request.urlopen(bookmark.url), "html.parser")
    bookmark.set_title(soup.title.string)

def write_bookmarks(bookmarks):
    from shutil import copyfile
    seen_names = set()
    unique = []
    for b in bookmarks:
        if b.name not in seen_names:
            unique.append(b)
            seen_names.add(b.name)
    unique.sort(key=lambda b: b.name)
    backup = "/tmp/bookmarks_backup"
    copyfile(BOOKMAKRS_FILE, backup)
    print("copied backup of {} to {}".format(BOOKMAKRS_FILE, backup))
    with open(BOOKMAKRS_FILE, "w") as f:
        for bookmark in unique:
            print(bookmark.get_surfraw_format(), file=f)

def truncate(s, max_len):
    s = str(s) if s else ""
    return (s[:max_len] + '…') if len(s) > max_len else s

# format
# %n for name
# %u for url
# %t for tags
# %T for title
def print_pretty(bookmarks, form, max_name, max_url, max_tag, max_title):
    for bookmark in bookmarks:
        print(form.replace("%n", truncate(bookmark.name, max_name))
                .replace("%u", truncate(bookmark.url, max_url))
                .replace("%t", truncate(bookmark.get_tags_string(), max_tag))
                .replace("%T", truncate(bookmark.title, max_title)))


def find_bookmark(bookmarks, name):
    for bookmark in bookmarks:
        if bookmark.name == name:
            return bookmark
    raise ValueError("invalid bookmark name: {}".format(name))

def set_title(bookmarks, name, title):
    find_bookmark(bookmarks, name).set_title(title)

def set_tags(bookmarks, name, tags):
    find_bookmark(bookmarks, name).set_tags(tags)

def set_name(bookmarks, name, new_name):
    find_bookmark(bookmarks, name).set_name(new_name)

def set_url(bookmarks, name, url):
    find_bookmark(bookmarks, name).set_url(url)

if __name__ == "__main__":
    from sys import argv
    prog_name = argv[0]
    args = argv[1:]
    if not args:
        args = ["--help"]
    bookmarks = read_bookmarks(BOOKMAKRS_FILE)
    changed = False
    try:
        while args:
            if args[0] == "--update-titles":
                update_titles(bookmarks)
                changed = True
                args = args[1:]
            elif args[0] == "--update-title":
                if not len(args) >= 3:
                    raise ValueError("expected more arguments")
                set_title(bookmarks, args[1], args[2])
                changed = True
                args = args[3:]
            elif args[0] == "--update-tags":
                if not len(args) >= 3:
                    raise ValueError("expected more arguments")
                set_tags(bookmarks, args[1], args[2])
                changed = True
                args = args[3:]
            elif args[0] == "--update-name":
                if not len(args) >= 3:
                    raise ValueError("expected more arguments")
                set_name(bookmarks, args[1], args[2])
                changed = True
                args = args[3:]
            elif args[0] == "--update-url":
                if not len(args) >= 3:
                    raise ValueError("expected more arguments")
                set_url(bookmarks, args[1], args[2])
                changed = True
                args = args[3:]
            elif args[0] == "--add":
                if not len(args) >= 3 and len(args) <= 5:
                    raise ValueError("--add takes at least two arguments and"
                            " must be the last parameter")
                name = args[1]
                url = args[2]
                tags = None
                title = None
                if len(args) >= 4: tags = args[3]
                if len(args) == 5: title = args[4]
                bm_string = "{} {} ;; {} ;; {}".format(name, url,
                        tags or NO_VALUE, title or NO_VALUE)
                bookmark = Bookmark(bm_string)
                bookmarks.append(bookmark)
                if not title: update_title(bookmark)
                print("adding bookmark: {}".format(
                    bookmark.get_surfraw_format()))
                changed = True
                args = []
                break
            elif args[0] == "--max-name":
                if not len(args) >= 2:
                    raise ValueError("expected an argument for " + args[0])
                val = int(args[1])
                if val <= 0:
                    raise ValueError("invalid argument for {}: {}".format(
                        args[0], val))
                MAX_LENGTH_NAME = val
                args = args[2:]
            elif args[0] == "--max-url":
                if not len(args) >= 2:
                    raise ValueError("expected an argument for " + args[0])
                val = int(args[1])
                if val <= 0:
                    raise ValueError("invalid argument for {}: {}".format(
                        args[0], val))
                MAX_LENGTH_URL = val
                args = args[2:]
            elif args[0] == "--max-tags":
                if not len(args) >= 2:
                    raise ValueError("expected an argument for " + args[0])
                val = int(args[1])
                if val <= 0:
                    raise ValueError("invalid argument for {}: {}".format(
                        args[0], val))
                MAX_LENGTH_TAGS = val
                args = args[2:]
            elif args[0] == "--max-title":
                if not len(args) >= 2:
                    raise ValueError("expected an argument for " + args[0])
                val = int(args[1])
                if val <= 0:
                    raise ValueError("invalid argument for {}: {}".format(
                        args[0], val))
                MAX_LENGTH_TITLE = val
                args = args[2:]
            elif args[0] == "--print-pretty":
                if not len(args) >= 2:
                    raise ValueError("print needs a format string; see --help")
                form = args[1]
                print_pretty(bookmarks, form, MAX_LENGTH_NAME, MAX_LENGTH_URL,
                        MAX_LENGTH_TAGS, MAX_LENGTH_TITLE)
                args = args[2:]
            elif args[0] == "--help" or args[0] == "-h":
                print("help for " + prog_name + "\n"
                    "--help|-h\n\t"
                    "show this help\n"
                    "--update-titles\n\t"
                    "refetch all titles for the urls in " + BOOKMAKRS_FILE + "\n"
                    "--update-{tags,name,title,url} <name> <new_value>\n\t"
                    "update the property of the bookmark specified by <name> "
                    "and set it to <new_value>\n"
                    "--add <name> <url> [<tags> [<title>]]\n\t"
                    "add a new bookmark (must be the last parameter)\n\t"
                    "<tags> and <title> are optional\n\t"
                    "<tags> have to be seperated by commas\n\t"
                    "if you want to specify a title but not tags, use " +
                    NO_VALUE + " as value for <tags>\n\t"
                    "if no title was specified, it is fetched automatically\n"
                    "--max-{name,url,tags,title} <value>\n\t"
                    "set the max length used by print\n\t"
                    "values must be positive\n\t"
                    "must be specified before --print-pretty\n\t"
                    "--print-pretty <format>\n\t"
                    "you need to specify a format string\n\t"
                    "you can use the following special sequences\n\t"
                    "%n for name\n\t"
                    "%u for url\n\t"
                    "%t for tags\n\t"
                    "%T for title\n\t")
                args = args[1:]
            else:
                print("usage: " + prog_name +
                        " --update-titles|--update-{tags,name,title,url}"
                        " <name> <new_value>|--add <name> <url> [<tags>"
                        " [<title>]]|--print-pretty|"
                        "--max-{name,tags,title,url} <value>|--help",
                        file=stderr)
                exit(1)
        if changed:
            write_bookmarks(bookmarks)
    except Exception as e:
        print("error: {}".format(e), file=stderr)
        exit(1)
