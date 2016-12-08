EDM to CMDI
-----------

Implementation of conversion from the 
[Europeana Data Model (EDM)](http://pro.europeana.eu/edm) to the 
[Component Metadata Infrastructure (CMD)](https://www.clarin.eu/cmdi).

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
