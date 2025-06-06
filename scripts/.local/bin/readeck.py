#!/usr/bin/env python3

import os
import sys
import urllib.request
import json

# CLI to convert Readeck articles to markdown.
# Arguments: One or more article IDs.

# Relevant Readeck API endpoints:
# - GET /api/bookmarks/{id}
#   - Returns the article metadata as JSON (e.g., title, authors, labels, etc.)
# - GET /api/bookmarks/{id}/annotations
#   - Returns the article annotations as a JSON array (e.g., highlights, notes, etc.)
#   - Mostly only the 'text' field is relevant.

READECK_URL = "http://localhost:8000"

def generate_article(**article):
    properties = [
        f'collapsed:: true',
        f'type:: [[Article]]',
        f'url:: [{article["site_name"]}]({article["url"]})',
        f'{article["authors"] and "author:: " + ", ".join([f"[[{author}]]" for author in article["authors"]]) or ""}',
        f'{f"tags:: [[Readeck]]" + "".join([f", [[{label}]]" for label in article["labels"]]) + (article["site_name"] and f", [[{article["site_name"]}]]" or "")}',
    ]
    annotations_rendered = ''
    for annotation in article.get('annotations', []):
        lines = annotation['text'].split('\n')
        color = f'background-color:: {annotation["color"]}' if annotation['color'] else ''
        annotations_rendered += f'\t\t- {color}\n\t\t  > ' + '\n\t\t  > '.join(lines) + '\n'
    return f'\t- [{article["title"]}]({READECK_URL + "/bookmarks/" + article["id"]})\n' + \
        ''.join('\t  ' + prop + '\n' for prop in properties if prop) + \
        annotations_rendered

def readeck_get(url):
    auth_token = os.environ.get('READECK_AUTH_TOKEN')
    if not auth_token:
        raise ValueError('READECK_AUTH_TOKEN environment variable not set')
    headers = {
        'Authorization': f'Bearer {auth_token}',
    }
    req = urllib.request.Request(f'{READECK_URL}/{url}', headers=headers)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read())
        return data

def get_bookmark(id):
    return readeck_get(f'/api/bookmarks/{id}')

def get_annotations(id):
    return readeck_get(f'/api/bookmarks/{id}/annotations')

def generate_articles(article_ids):
    articles = [get_bookmark(article_id) for article_id in article_ids]
    annotations = [get_annotations(article_id) for article_id in article_ids]
    articles_extended = [article | {'annotations': annotation} for article, annotation in zip(articles, annotations)]
    heading = '- ## 🔖 Articles'
    return heading + '\n' + ''.join(generate_article(**article) for article in articles_extended)

def main(args):
    if not args:
        raise ValueError('No article IDs provided')
    articles = generate_articles(args)
    print(articles)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: readeck.py <article_id> [<article_id> ...]')
        sys.exit(1)
    main(sys.argv[1:])
