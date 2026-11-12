"""FS2v1 portable codec, adapted from the example's integration/workbench/wire.py.

Language-neutral public Workbench interface; no application-private imports.
"""
import json
import hashlib
import re


def sexp(value):
    if isinstance(value, (list, tuple)):
        return '(' + ' '.join(map(sexp, value)) + ')'
    return json.dumps(str(value), ensure_ascii=False)


def parse(text):
    pos = 0

    def item(depth=0):
        nonlocal pos
        if depth > 64:
            raise ValueError('S-expression nesting bound exceeded')
        while pos < len(text) and text[pos].isspace():
            pos += 1
        if pos == len(text):
            raise ValueError('truncated S-expression')
        if text[pos] == '(':
            pos += 1
            out = []
            while True:
                while pos < len(text) and text[pos].isspace():
                    pos += 1
                if pos == len(text):
                    raise ValueError('unclosed list')
                if text[pos] == ')':
                    pos += 1
                    return out
                out.append(item(depth + 1))
        if text[pos] == '"':
            pos += 1
            out = bytearray()
            while pos < len(text):
                char = text[pos]
                pos += 1
                if char == '"':
                    return out.decode('utf-8', 'strict')
                if char == '\\':
                    if pos == len(text):
                        raise ValueError('truncated escape')
                    char = text[pos]
                    pos += 1
                    escapes = {'n': '\n', 'r': '\r', 't': '\t', 'b': '\b', '\\': '\\', '"': '"'}
                    if char in escapes:
                        out.extend(escapes[char].encode())
                    elif char.isascii() and char.isdigit():
                        digits = char + text[pos:pos + 2]
                        if not re.fullmatch('[0-9]{3}', digits) or int(digits) > 255:
                            raise ValueError('invalid decimal escape')
                        pos += 2
                        out.append(int(digits))
                    else:
                        raise ValueError('invalid escape')
                else:
                    out.extend(char.encode())
            raise ValueError('unclosed string')
        match = re.match(r'[^\s()";]+', text[pos:])
        if not match:
            raise ValueError('invalid atom')
        pos += len(match[0])
        return match[0]

    value = item()
    if text[pos:].strip():
        raise ValueError('trailing data')
    return value


def record(value, keys):
    if not isinstance(value, list):
        raise ValueError('expected record')
    result = {}
    for pair in value:
        if (not isinstance(pair, list) or len(pair) != 2 or
                not isinstance(pair[0], str) or pair[0] in result):
            raise ValueError('invalid or duplicate record field')
        result[pair[0]] = pair[1]
    if set(result) != set(keys):
        raise ValueError('unexpected record fields')
    return result


class Events:
    def __init__(self, stream, attempt):
        self.stream, self.attempt, self.sequence = stream, attempt, 0

    def emit(self, payload):
        line = sexp([('protocol_version', 1), ('attempt_id', self.attempt),
                     ('sequence', self.sequence), ('payload', payload)]) + '\n'
        if len(line.encode()) > 16384:
            raise ValueError('event exceeds FS2 line bound')
        self.stream.write(line)
        self.stream.flush()
        self.sequence += 1

    def artifact(self, case, path, kind, media):
        identity = 'artifact-' + hashlib.sha256(path.encode('utf-8')).hexdigest()
        self.emit(['Artifact', [('id', identity), ('case_id', [case]), ('label', path),
                               ('kind', kind), ('media_type', media), ('path', path)]])
