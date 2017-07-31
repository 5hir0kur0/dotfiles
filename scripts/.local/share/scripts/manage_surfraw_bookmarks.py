#!/usr/bin/env python3

# from html.parser import HTMLParser
from os.path import expanduser
from bs4 import BeautifulSoup
from sys import stderr
import re
import urllib.request

# currently, BeautifulSoup is used to fetch the website titles,
# but this is also possible without additional libraries
# (see the commented out parts of the file)
# the reason I didn't do it is because I was too lazy to fix an exception
# that occurred everytime on FindTitleParser.feed

BOOKMAKRS_FILE = expanduser("~/.config/surfraw/bookmarks")
MAX_LENGTH_NAME = 0
MAX_LENGTH_TITLE = 0
MAX_LENGTH_TAGS = 0
MAX_LENGTH_URL = 0
SHORT_URL = True
WHITESPACE = re.compile("\s+")

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
NO_VALUE = "@@NONE@@"
class Bookmark():
    tags_regex = re.compile("^\s*$|^\w+(?:,\w+)*$")
    name_regex = re.compile("^\w+$")
    http_regex = re.compile("^https?://(?:www\d*\.)?")
    def __init__(self, s):
        split = s.split(None, 1)
        if not len(split) == 2:
            raise ValueError("not a valid bookmark: " + str(s))
        self.name = split[0].strip()
        split2 = [ i.strip() for i in split[1].split(";;", 2) ]
        if not len(split2) == 3:
            raise ValueError("not a valid bookmark: " + str(s))
        self.url = split2[0].strip()
        if split2[1].strip() == NO_VALUE or not split2[1].strip():
            self.tags = []
        else:
            self.tags = [ t.strip() for t in split2[1].strip().split(",") ]
            self.tags.sort()
        tmp_title = split2[2].strip()
        self.title = None if tmp_title == NO_VALUE else tmp_title
    def set_title(self, title):
        if title == NO_VALUE:
            self.title = None
        else:
            old = self.title
            self.title = title.strip() or None
            if old != self.title:
                print("updating title of {}; change from {} to {}".format(
                    self.url, old, self.title))
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
            if tags is not None and not Bookmark.tags_regex.match(tags):
                raise ValueError("invalid tags: {}".format(tags))
            old = self.tags
            if not tags.strip():
                self.tags = []
            else:
                self.tags = list({t.strip() for t in tags.strip().split(",")})
            self.tags.sort()
            if old != self.tags:
                print("updating tags of {} from {} to {}".format(self.name, old,
                    self.tags))
    def set_name(self, new_name):
        if not new_name or not Bookmark.name_regex.match(new_name):
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
    def get_formatted_url(self):
        return Bookmark.http_regex.sub("", self.url).rstrip("/") if SHORT_URL \
                else self.url


def read_bookmarks(path):
    bookmarks = []
    with open(path, "r") as marks:
        for line in marks:
            if not line.strip().startswith("#"):
                # uncomment if you need comments that only span part of a line
                # bookmarks.append(Bookmark(line.split("#", 1)[0].strip()))
                bookmarks.append(Bookmark(line.strip()))
    return bookmarks

def update_titles(bookmarks):
    # parser = FindTitleParser()
    for bookmark in bookmarks:
        e = update_title(bookmark)
        if e:
            print(e, file=stderr)

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
    url = bookmark.url.replace("%s", "") # set search query to empty if any
    try:
        soup = BeautifulSoup(urllib.request.urlopen(url), "html.parser")
        title = soup.title.string.replace("\n", " ").strip()
        title = WHITESPACE.sub(" ", title)
        bookmark.set_title(title)
    except Exception as e:
        return "title couldn't be updated: {}".format(e)
    return ""

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
    return (s[:max_len] + '…') if len(s) > max_len > 0 else s

# format
# %n for name
# %u for url
# %t for tags
# %T for title
def print_pretty(bookmarks, form, max_name, max_url, max_tag, max_title):
    for bookmark in bookmarks:
        print(form.replace("%n", truncate(bookmark.name, max_name))
                .replace("%u", truncate(bookmark.get_formatted_url(), max_url))
                .replace("%t", truncate(bookmark.get_tags_string(), max_tag))
                .replace("%T", truncate(bookmark.title, max_title)))

def print_index(bookmarks, bookmark):
    bookmarks.sort(key=lambda b: b.name)
    print("index:", bookmarks.index(bookmark))

def list_tags(bookmarks):
    tags = set()
    for bookmark in bookmarks:
        for tag in bookmark.tags:
            tags.add(tag)
    for tag in sorted(tags):
        print(tag)


def find_bookmark(bookmarks, name):
    name = name.strip()
    for bookmark in bookmarks:
        if bookmark.name == name:
            return bookmark
    raise ValueError("invalid bookmark name: {}".format(name))

def filter_by_tags(bookmarks, tags):
    res = []
    tset = set(tags)
    return filter(lambda bm: tset.issubset(set(bm.tags)), bookmarks)

def set_title(bookmarks, name, title):
    bookmark = find_bookmark(bookmarks, name)
    bookmark.set_title(title)
    print_index(bookmarks, bookmark)

def set_tags(bookmarks, name, tags):
    bookmark = find_bookmark(bookmarks, name)
    bookmark.set_tags(tags)
    print_index(bookmarks, bookmark)

def set_name(bookmarks, name, new_name):
    bookmark = find_bookmark(bookmarks, name)
    bookmark.set_name(new_name)
    print_index(bookmarks, bookmark)

def set_url(bookmarks, name, url):
    bookmark = find_bookmark(bookmarks, name)
    bookmark.set_url(url)
    print_index(bookmarks, bookmark)

def remove_bookmark(bookmarks, name):
    bookmark = find_bookmark(bookmarks, name)
    print("removing bookmark:", bookmark.get_surfraw_format())
    print_index(bookmarks, bookmark)
    bookmarks.remove(bookmark)

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
                if not len(args) >= 2:
                    raise ValueError("expected more arguments")
                name = args[1]
                title = None
                if len(args) >= 3:
                    title = args[2].replace("\n", "").strip()
                if title:
                    set_title(bookmarks, name, title)
                else:
                    bookmark = find_bookmark(bookmarks, name)
                    update_title(bookmark)
                    print_index(bookmarks, bookmark)
                changed = True
                args = args[3:] if len(args) >= 3 else args[2:]
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
            elif args[0] == "--remove":
                if not len(args) >= 2:
                    raise ValueError("expected more arguments")
                remove_bookmark(bookmarks, args[1])
                changed = True
                args = args[2:]
            elif args[0] == "--add":
                if not len(args) >= 3 and len(args) <= 5:
                    raise ValueError("--add takes at least two arguments and"
                            " must be the last parameter")
                name = args[1].replace("\n", "").strip()
                name = WHITESPACE.sub("", name)
                url = args[2].replace("\n", "").strip()
                url = WHITESPACE.sub("", url)
                tags = None
                title = None
                if len(args) >= 4: tags = args[3].replace("\n", "").strip()
                if len(args) >= 5: title = args[4].replace("\n", "").strip()
                if tags:
                    tags = WHITESPACE.sub(" ", tags)
                if title:
                    title = WHITESPACE.sub(" ", title)
                if ";;" in url or ";;" in name or tags and ";;" in tags:
                    raise ValueError("name, url and tags must not contain ';;'")
                bm_string = "{} {} ;; {} ;; {}".format(name, url,
                        tags or NO_VALUE, title or NO_VALUE)
                bookmark = Bookmark(bm_string)
                bookmarks.append(bookmark)
                e = None
                if not title:
                    e = update_title(bookmark)
                print("adding bookmark: {}".format(
                    bookmark.get_surfraw_format()))
                print_index(bookmarks, bookmark)
                if e: print(e, file=stderr)
                changed = True
                args = []
                break
            elif args[0] == "--long-urls":
                SHORT_URL = False
                args = args[1:]
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
            elif args[0] == "--print":
                if not len(args) >= 2:
                    raise ValueError("print needs a format string; see --help")
                form = args[1]
                print_pretty(bookmarks, form, MAX_LENGTH_NAME, MAX_LENGTH_URL,
                        MAX_LENGTH_TAGS, MAX_LENGTH_TITLE)
                args = args[2:]
            elif args[0] == "--find":
                if not len(args) >= 3:
                    raise ValueError("find needs a name and a format string;"
                            "see --help")
                name = args[1]
                form = args[2]
                try:
                    mark = next(b for b in bookmarks if b.name == name)
                    print_pretty([mark], form, MAX_LENGTH_NAME,
                            MAX_LENGTH_URL, MAX_LENGTH_TAGS,
                            MAX_LENGTH_TITLE)
                except StopIteration:
                    raise ValueError("invalid name: {}".format(name))
                args = args[3:]
            elif args[0] == "--list-tags":
                list_tags(bookmarks)
                args = args[1:]
            elif args[0] == "--filter-by-tags":
                if not len(args) >= 3:
                    raise ValueError("filter-by-tag needs format and tags")
                form = args[1]
                tags = [ t.strip() for t in args[2].strip().split(",") ]
                print_pretty(filter_by_tags(bookmarks, tags), form, 
                        MAX_LENGTH_NAME, MAX_LENGTH_URL, MAX_LENGTH_TAGS,
                        MAX_LENGTH_TITLE)
                args = []
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
                    "if you want to specify a title but not tags, use '" +
                    NO_VALUE + "' as value for <tags>\n\t"
                    "if no title was specified, it is fetched automatically\n"
                    "--long-urls\n\t"
                    "don't abbreviate urls (i.e. keep the 'http(s)://www.')\n\t"
                    "must be specified before --print\n"
                    "--max-{name,url,tags,title} <value>\n\t"
                    "set the max length used by print\n\t"
                    "values must be positive\n\t"
                    "must be specified before --print\n"
                    "--print <format>\n\t"
                    "you need to specify a format string\n\t"
                    "you can use the following special sequences\n\t"
                    "%n for name\n\t"
                    "%u for url\n\t"
                    "%t for tags\n\t"
                    "%T for title\n"
                    "--list-tags\n\t"
                    "list of all tags\n"
                    "--filter-by-tags <format> <tags>\n\t"
                    "only print bookmarks that have all tags\n"
                    "--find <name> <format>\n\t"
                    "like print but only print bookmark matching <name>")
                args = args[1:]
            else:
                print("usage: " + prog_name +
                        " --update-titles | --update-{tags,name,title,url}"
                        " <name> <new_value> | --add <name> <url> [<tags>"
                        " [<title>]] | --print <format> | --long-urls | "
                        "--list-tags | --find <name> <format> | "
                        "--max-{name,tags,title,url} <value> | --help",
                        file=stderr)
                exit(1)
        if changed:
            write_bookmarks(bookmarks)
    except Exception as e:
        print("error: {}".format(e), file=stderr)
        exit(1)
