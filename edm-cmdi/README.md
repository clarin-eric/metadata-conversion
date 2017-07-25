# EDM to CMDI

Implementation of conversion from the 
[Europeana Data Model (EDM)](http://pro.europeana.eu/edm) to the 
[Component Metadata Infrastructure (CMDI)](https://www.clarin.eu/cmdi).

The conversion is implemented as an XSLT stylesheet (tested to work with Saxon-HE 9.6)
and converts specifically to the 
[EDM profile](https://catalog.clarin.eu/ds/ComponentRegistry#/?itemId=clarin.eu%3Acr1%3Ap_1475136016208&registrySpace=private)
for CMDI ([XSD](https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/clarin.eu:cr1:p_1475136016208/xsd)).

The implementation of this conversion mechanism took place in the context of Europeana 
DSI-2, task 2.6.3. It wat not necessarily designed for the purpose of generating complete
representation of original EDM records but rather to preserve and represent information
useful for exploitation and processing of Europeana metadata and resources within the
[CLARIN](https://www.clarin.eu) infrastructure.

Contact: [twan@clarin.eu](mailto:twan@clarin.eu)

## Description of the conversion

In contrast to EDM, which follows the Semantic Web approach
of connecting uniquely identified objects and properties through assertions, CMDI
metadata is linear and structured hierarchically. The chosen conversion
approach produces structures mimicking those found in the RDF/XML serialisation
of EDM as provided by Europeana, but with an imposed hierarchy that reflects
the object relations allowed by the EDM specification where possible. For
example, `Place`, `Agent` and `TimeSpan` structures (CMD
components) are defined as descendants of `ProvidedCHO` (cultural heritage
object) structures, reflecting the EDM specification which defines relations
such as _edm:ProvidedCHO dc:contributor edm:Agent_ and 
_edm:ProvidedCHO edm:currentLocation edm:Place_. 
Properties are defined as CMD elements in
the order that they appear in the EDM specification. Object order is based on
relevance, hence the `ProvidedCHO` and `ProvidedCHOProxy` structures,
that contain metadata about the described object, appear first although in the
EDM ontology the `ore:Aggregation` class is arguably the higher level.
Object identifiers and references (`rdf:about` and `rdf:resource`)
are preserved for reference but serve no operational purpose within the CMDI
domain. Concept links are assigned to most components and elements, using _purl.org_
URIs for properties from the DC and DCMI Metadata Terms vocabularies, and
hand-picked URIs of matching concepts registered in the CLARIN Concept Registry
(CCR) in all other cases.

 

**CMDI records** (as of CMDI version 1.2) are governed by
two XML schemas: one that defines an ‘envelope’ common to all CMDI instances,
and a second one that is specific to a profile and defines the structure of the
‘payload’. The CMDI** envelope** wraps around the payload, and at its
highest level contains header information such as creation date, name of the
collection a record is part of, and a resolvable identifier of the document
(‘self link’); it has an adjacent section for ‘resource proxies’, which are
entities representing external documents related to the metadata description in
the payload section and exist in various types. In the implemented conversion
stylesheet, the envelope’s header information and resource proxies are produced
on the basis of a list of static XPaths in the original RDF/XML document. For
several values, multiple candidate paths are defined that get evaluated in
order of preference. For example, the self link value is derived from the
identifier of either the `EuropeanaAggregation` or `ProvidedCHO`
object. There are also various potential sources for the resource proxies. One
special resource proxy type is ‘landing page’, which is adopted from the `edm:landingPage`
property of the `EuropeanaAggregation` object if present. Further resource
proxies are produced on basis of the `WebResource` objects found in the
RDF/XML document, whether defined in the document itself or referenced through
an external identifier. `WebResource` identifiers are assumed to be
actionable and are used as the location referenced by the resource proxy. The
media type (also known as “MIME type” and labeled as such in the resource proxy
definition) is obtained from the `ebucore:hasMimeType` property if
present.

The record’s** payload** is produced mostly by means of a
straightforward crosswalk where the namespace bound properties in the RDF/XML
document are mapped to CMD components or  elements of an equivalent name
consisting of a concatenation of the common namespace prefix and the property’s
name separated by a dash. Properties of a type that only allows literal values
(i.e., no object reference) are mapped to ‘simple’ CMD elements with a
cardinality matching the definition found in the EDM specification; for
example, the `foaf:name` property of `edm:Agent` is mapped to a CMD
element `foaf-name` in the `edm-Agent` component. Properties with a
‘ref’ value are mapped to a CMD element with an `rdf-resource` attribute
unless the referenced object is of one of the following types defined in the
EDM model: `cc:License`, `edm:Agent`, `edm:Place`, `edm:TimeSpan`,
`skos:Concept`. For those cases, a CMD component is instantiated that
contains a structure of the corresponding type. If a property can have either a
reference or a literal value, a mapping to a CMD component takes place that
contains either a CMD Element of the same name, a structure representing one of
the types mentioned above, or an `rdf:resource` attribute containing the
identifier of the referenced object. For example, the relation 
_edm:Agent dc:date edm:TimeSpan_, which allows for a reference or literal value
content, is mapped to an XML element `dc-date`, containing either a `TimeSpan`
structure, or a single XML element `dc-date` carrying the literal value,
or a `rdf:resource` attribute depending on the details of the original
property.

In EDM, the description of a cultural heritage object (CHO)
is generally distributed over one or more proxies for a single `edm:ProvidedCHO`
object. Each of these proxies gets represented in the CMDI record by means of a
`edm-ProvidedCHOProxy` component, which wraps a `edm-ProvidedCHO`
component that contains all of the object’s properties. Despite the potential
of there being multiple instances, each of these describes the same CHO. In
line with the EDM model and its RDF/XML representation, the CHO object (of
which there should only be one per document) is mapped to an instance of the
same component although it generally should not have any properties defined in
it. All `edm:Aggregation` objects found in the EDM document are mapped to
CMD components `edm-Aggregation`. All relations pointing to `edm:WebResource`
objects contained in `edm:Aggregation` or `edm:ProvidedCHO` objects
(or their proxies) are expanded as instances of the `edm-WebResource` CMD
component. All such structures reference the corresponding resource proxy using
the mechanism that CMDI provides for this, i.e., the `cmd:ref` attribute,
which is based on the `xsd:IDREF` datatype of the W3C XML Schema language.
An instance of the dedicated `edm-EuropeanaAggregation` component is
created and populated in case a `edm:EuropeanaAggregation` object is
found.