#!/usr/bin/env python
from __future__ import print_function, unicode_literals
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('mapping', nargs='+')
parser.add_argument('--module-name', default='Routes')

TEMPLATE = """\
module {module_name} exposing (..)

import Url exposing (Url)
import Url.Builder exposing (absolute)
import Url.Parser exposing (Parser, s, top, map, oneOf, (</>))


type Route = {routes}


markdown : Route -> String
markdown route =
    case route of
        {markdown_cases}


parser : Parser (Route -> a) a
parser =
  oneOf
     [ {parser_cases}
     ]
"""

def to_constructor(kebab_case):
    parts = kebab_case.split('-')

    return ''.join(part.capitalize() for part in parts)


args = parser.parse_args()

routes_to_markdown = dict(reversed(mapping.split('=')) for mapping in args.mapping)

routes_to_constructors = {
    route: to_constructor(route.replace('/', '') or 'index')
    for route in routes_to_markdown.keys()
}

markdown_cases = '\n        '.join(
    '{} -> {}'.format(
        route,
        'absolute [ {} ] []'.format(
            ','.join(
                '"{}"'.format(part)
                for part in routes_to_markdown[path].split('/')
                if part != ''
            )
        ),
    )
    for (path, route)
    in routes_to_constructors.items()
)

parser_cases = '\n        , '.join(
    'map {} ({})'.format(
        constructor,
        'top' if route == '/' else 'top </> {}'.format(
            ' </> '.join('s "{}"'.format(part) for part in route.split('/') if part != '')
        )
    )
    for (route, constructor)
    in routes_to_constructors.items()
)

print(TEMPLATE.format(
    module_name = args.module_name,
    routes = ' | '.join(sorted(routes_to_constructors.values())),
    markdown_cases = markdown_cases,
    parser_cases = parser_cases,
))
