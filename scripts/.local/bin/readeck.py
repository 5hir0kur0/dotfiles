#!/usr/bin/env python3

import os
import sys
import urllib.request
import json
from datetime import datetime

# CLI to convert Readeck articles to markdown.
# Arguments: One or more article IDs.

# Relevant Readeck API endpoints:
# - GET /api/bookmarks/{id}
#   - Returns the article metadata as JSON (e.g., title, authors, labels, etc.)
# - GET /api/bookmarks/{id}/annotations
#   - Returns the article annotations as a JSON array (e.g., highlights, notes, etc.)
#   - Mostly only the 'text' field is relevant.

READECK_URL_FALLBACK = "http://localhost:8000"


def format_date(iso_date: str) -> str:
    iso_date = iso_date.split("T")[0]
    date = datetime.strptime(iso_date, "%Y-%m-%d")
    day = date.day
    suffix = (
        "th" if 11 <= day <= 13 else {1: "st", 2: "nd", 3: "rd"}.get(day % 10, "th")
    )
    return "[[" + date.strftime(f"%b {day}{suffix}, %Y") + "]]"


def slash_join(s1: str, s2: str) -> str:
    return s1.rstrip("/") + "/" + s2.lstrip("/")


def readeck_url(*parts) -> str:
    result = os.environ.get("READECK_URL")
    result = result or READECK_URL_FALLBACK
    for part in parts:
        result = slash_join(result, part)
    return result


def generate_article(**article):
    properties = [
        "collapsed:: true",
        "type:: [[Article]]",
        f'url:: [{article["site_name"]}]({article["url"]})',
        f'{article["authors"] and
            "author:: " + ", ".join(
                [f"[[{author}]]" for author in article["authors"]]
            )}',
        f'{f"tags:: [[Readeck]]" +
            "".join([f", [[{label}]]" for label in article["labels"]]) +
            (article["site_name"] and f", [[{article["site_name"]}]]")}',
        f'{article.get("published", "") and "date-published:: " + format_date(article["published"])}',
    ]
    annotations_rendered = ""
    for annotation in article.get("annotations", []):
        lines = annotation["text"].split("\n")
        color = annotation["color"] and f'background-color:: {annotation["color"]}'
        annotations_rendered += (
            f"\t\t- {color}\n\t\t  > " + "\n\t\t  > ".join(lines) + "\n"
        )
    return (
        f'\t- [{article["title"]}]({
            readeck_url('bookmarks', article["id"])
        })\n'
        + "".join("\t  " + prop + "\n" for prop in properties if prop)
        + annotations_rendered
    )


def readeck_get(url):
    auth_token = os.environ.get("READECK_AUTH_TOKEN")
    if not auth_token:
        raise ValueError("READECK_AUTH_TOKEN environment variable not set")
    headers = {
        "Authorization": f"Bearer {auth_token}",
    }
    print("requesting:", readeck_url(url), file=sys.stderr)
    req = urllib.request.Request(readeck_url(url), headers=headers)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read())
        return data


def get_bookmark(id):
    return readeck_get(f"/api/bookmarks/{id}")


def get_annotations(id):
    return readeck_get(f"/api/bookmarks/{id}/annotations")


def generate_articles(article_ids):
    articles = [get_bookmark(article_id) for article_id in article_ids]
    annotations = [get_annotations(article_id) for article_id in article_ids]
    articles_extended = [
        article | {"annotations": annotation}
        for article, annotation in zip(articles, annotations)
    ]
    heading = "- ## 🔖 Articles"
    return (
        heading
        + "\n"
        + "".join(generate_article(**article) for article in articles_extended)
    )


def main(args):
    if not args:
        raise ValueError("No article IDs provided")
    articles = generate_articles(args)
    print(articles)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: readeck.py <article_id> [<article_id> ...]")
        sys.exit(1)
    main(sys.argv[1:])
