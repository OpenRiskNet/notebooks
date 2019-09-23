import datetime
import requests
import urllib.parse
import pandas
import typing

try:
    from collections import OrderedDict
except ImportError:
    pip(['install', 'collections'])
    from collections import OrderedDict

try:
    import simplejson as json
except ImportError:
    pip(['install', 'simplejson'])
    import simplejson as json
    
def parse_utc_datetime(datetime_string : str) -> datetime.datetime:
    # Python ISO format doesn't seem to support seven digits
    # of microseconds that Edelweiss server returns. To be sure,
    # we chop everything after the third digit (this includes the timezone
    # offset but we assume per convention for this to be Z for UTC time)
    datetime_string = datetime_string[:datetime_string.index('.') + 4]
    # Python 3.7 has a nice function to parse iso datetimes but
    # we want to support python 3.6 as well and avoid additional
    # external dependencies for now (this can change once we have a pip
    # package that manages dependencies for us)
    parsed = datetime.datetime.strptime(datetime_string,'%Y-%m-%dT%H:%M:%S.%f')
    parsed = parsed.replace(tzinfo=datetime.timezone.utc)
    return parsed

class Server:
    def __init__(self):
        self._base_url = None

    def _absolute_url(self, route):
        if self._base_url is None:
            raise ValueError('Server is not set up. Call server.connect(URL) first')
        return urllib.parse.urljoin(self._base_url, route)

    def connect(self, url):
        self._base_url = url

    def get(self, route):
        response = requests.get(self._absolute_url(route))
        response.raise_for_status()
        return json.loads(response.text, object_pairs_hook=OrderedDict)

    def post(self, route, json=None, data=None):
        response = requests.post(self._absolute_url(route), json=json, data=data)
        response.raise_for_status()
        return response.json()

    def upload(self, route, files):
        response = requests.post(self._absolute_url(route), files=files)
        response.raise_for_status()
        return response.json()

    def delete(self, route):
        requests.delete(self._absolute_url(route))

    def health(self):
        return requests.get(self._absolute_url('/health')).ok

    def readiness(self):
        return requests.get(self._absolute_url('/ready')).ok

    def openapi_documents(self):
        return self.get('/openapidocuments')

    def openapi(self):
        return self.get('/openapi.json')

default_server = Server()

class Column:
    def __init__(self, name, description, data_type, array_value_separator, missing_value_identifiers, search, aggregation, rdf_predicate):
        self.name = name
        self.description = description
        self.data_type = data_type
        self.array_value_separator = array_value_separator
        self.missing_value_identifiers = missing_value_identifiers
        self.search = search
        self.aggregation = aggregation
        self.rdf_predicate = rdf_predicate

    def __repr__(self):
        return '<Column {}:{}>'.format(self.name, self.data_type)

    @classmethod
    def decode(cls, d):
        return cls(
            name=d['name'],
            description=d['description'],
            data_type=d['dataType'],
            array_value_separator=d['arrayValueSeparator'],
            missing_value_identifiers=d['missingValueIdentifiers'],
            search=d['search'],
            aggregation=d['aggregation'],
            rdf_predicate=d['rdfPredicate'],
        )

    def encode(self):
        return {
            'name': self.name,
            'description': self.description,
            'dataType': self.data_type,
            'arrayValueSeparator': self.array_value_separator,
            'missingValueIdentifiers': self.missing_value_identifiers,
            'search': self.search,
            'aggregation': self.aggregation,
            'rdfPredicate': self.rdf_predicate,
        }


class Schema:
    def __init__(self, columns):
        self.columns = columns

    def __repr__(self):
        return '<Schema>'

    @classmethod
    def decode(cls, d):
        return cls(
            columns=[
                Column.decode(column) for column in d['columns']
            ]
        )

    def encode(self):
        return {
            'columns': [column.encode() for column in self.columns]
        }

class InProgressDataset:
    def __init__(self, id, name, schema, created, description, metadata, server=default_server):
        self.id = id
        self.name = name
        self.schema = schema
        self.created = created
        self.description = description
        self.metadata = metadata
        self.server = server

    def __repr__(self):
        return '<InProgressDataset {!r} - {}>'.format(self.id, self.name)

    @classmethod
    def decode(cls, d, server=default_server):

        return cls(
            id=d['id'],
            name=d['name'],
            schema=Schema.decode(d['schema']) if d['schema'] else None,
            created=parse_utc_datetime(d['created']),
            description=d['description'],
            metadata=d['metadata'],
            server=server
        )

    def encode(self):
        return {
            'id': self.id,
            'name': self.name,
            'schema': self.schema.encode() if self.schema else None,
            'created': self.created.toisoformat(),
            'description': self.description,
            'metadata': self.metadata,
        }

    @classmethod
    def get_all(cls, server=default_server):
        route = '/datasets/in-progress'
        return [cls.decode(d, server=server) for d in server.get(route)]

    @classmethod
    def get(cls, id, server=default_server):
        route = '/datasets/{}/in-progress'.format(id)
        return cls.decode(server.get(route), server=server)

    @classmethod
    def create(cls, name, server=default_server):
        route = '/datasets/create'
        return cls.decode(server.post(route, {'name': name}), server=server)

    def sample(self):
        route = '/datasets/{}/in-progress/sample'.format(self.id)
        return self.server.get(route)

    def upload_schema(self, schema : Schema):
        route = '/datasets/{}/in-progress/schema/upload'.format(self.id)
        self.server.post(route, schema.encode())
        self.schema = schema

    def upload_schema_file(self, file : typing.TextIO):
        route = '/datasets/{}/in-progress/schema/upload'.format(self.id)
        schemacontent = file.read()
        updated_dataset = InProgressDataset.decode(self.server.post(route, data=schemacontent))
        self.schema = updated_dataset.schema

    def upload_metadata(self, metadata):
        route = '/datasets/{}/in-progress/metadata/upload'.format(self.id)
        self.server.post(route, metadata)
        self.metadata = metadata

    def upload_metadata_file(self, file : typing.TextIO):
        route = '/datasets/{}/in-progress/metadata/upload'.format(self.id)
        metadatacontent = file.read()
        updated_dataset = InProgressDataset.decode(self.server.post(route, data=metadatacontent))
        self.metadata = updated_dataset.metadata

    def upload_data(self, data):
        route = '/datasets/{}/in-progress/data/upload'.format(self.id)
        return self.server.upload(route, {'data': data})

    def infer_schema(self):
        route = '/datasets/{}/in-progress/schema/infer'.format(self.id)
        updated_dataset = self.server.post(route, None)
        self.schema = Schema.decode(updated_dataset['schema'])

    def delete(self):
        route = '/datasets/{}/in-progress'.format(self.id)
        return self.server.delete(route)

    def publish(self, changelog):
        route = '/datasets/{}/in-progress/publish'.format(self.id)
        return PublishedDataset.decode(self.server.post(route, {'changelog': changelog}))


    def copy_from(self, published_dataset):
        route = '/datasets/{}/in-progress/copy-from/{}/versions/{}'.format(
            self.id,
            published_dataset.id,
            published_dataset.version
        )
        return self.server.post(route)

class PublishedDataset:
    LATEST = 'LATEST'

    def __init__(self, id, version, name, schema, created, description, metadata, server=default_server):
        self.id = id
        self.version = version
        self.name = name
        self.schema = schema
        self.created = created
        self.description = description
        self.metadata = metadata
        self.server = server

    def __repr__(self):
        return '<PublishedDataset {!r}:{} - {}>'.format(self.id, self.version, self.name)

    @classmethod
    def decode(cls, d, server=default_server):
        return cls(
            id=d['id']['id'],
            version=d['id']['version'],
            name=d['name'],
            schema=Schema.decode(d['schema']),
            created=parse_utc_datetime(d['created']),
            description=d['description'],
            metadata=d['metadata'],
            server=server
        )

    def encode(self):
        return {
            'id': {
                'id': self.id,
                'version': self.version,
            },
            'name': self.name,
            'schema': self.schema.encode(),
            'created': self.created.toisoformat(),
            'description': self.description,
            'metadata': self.metadata
        }

    @classmethod
    def get_all_raw(cls, server=default_server):
        route = '/datasets'
        return [d for d in server.get(route)]

    @classmethod
    def get_all(cls, server=default_server):
        datasets = get_all_raw()
        return [cls.decode(d, server=server) for d in self.get_all_raw(server)]

    @classmethod
    def get(cls, id, version=LATEST, server=default_server):
        route = '/datasets/{}/versions/{}'.format(id, version)
        return cls.decode(server.get(route), server=server)

    @classmethod
    def get_versions(cls, id, server=default_server):
        route = '/datasets/{}'.format(id)
        response = server.get(route)
        id, versions = response['id'], response['versions']
        return [
            cls.decode({'id': id, 'version': version['version'], 'name': version['name']}, server=server)
            for version in versions
        ]

    @classmethod
    def get_version(cls, id, version=LATEST, server=default_server):
        versions = cls.get_versions(id, server=server)
        return versions[-1] if version is cls.LATEST else versions[version - 1]

    @classmethod
    def create_from_csv_file(cls, name : str, file : typing.TextIO, metadata : dict=None):
        dataset = InProgressDataset.create('My dataset')
        # with open('../tests/Serialization/data/small1.csv') as f:
        dataset.upload_data(file)
        dataset.infer_schema()
        if metadata is not None:
            dataset.upload_metadata(metadata)
        published_dataset = dataset.publish('Initial version')
        return published_dataset


    def new_version(self):
        route = '/datasets/{}/versions/{}/create-new-version'.format(self.id, self.version)
        return InProgressDataset.decode(self.server.post(route))

    def data_as_dataframe(self):
        # TODO: add filtering by filtered values etc from a dict or querystring but for the latter strip offset/limit
        limit = 1000
        offset = 0
        column_names = [ column.name for column in self.schema.columns]
        data = self.data_as_dict(limit, offset)
        total = data['total']
        df = pandas.DataFrame.from_records(data['data'])
        df = df.loc[:, column_names] # re-order columns according to schema
        dataframes = [ df ]
        while (limit + offset) < total:
            offset = offset + limit
            data = self.data_as_dict(limit, offset)
            df = pandas.DataFrame.from_records(data['data'])
            df = df.loc[:, column_names] # re-order columns according to schema
            dataframes = dataframes + [ df ]
        # TODO: once we get row ids from the api with the data, use those as row indices so that
        # filtered operations on versions of the same datasets gets joined correctly
        return pandas.concat(dataframes, ignore_index=True)


    def data_as_dict(self, limit=100, offset=0):
        querystring = urllib.parse.urlencode({'limit': limit, 'offset': offset})
        route = '/datasets/{}/versions/{}/data?{}'.format(self.id, self.version, querystring)

        return self.server.get(route)

    def openapi(self):
        route = '/datasets/{}/versions/{}/openapi.json'.format(self.id, self.version)
        return self.server.get(route)
