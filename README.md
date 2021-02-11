# CLARIN metadata conversion
Conversion between metadata formats, in particular conversion to/from [CMDI](https://www.clarin.eu/cmdi).
Also see the [CMDI toolkit project](https://github.com/clarin-eric/cmdi-toolkit).

## Development
Please develop in a conversion specific development branch with a clear name,
such as `dev-edm-cmdi` for EDM-CMDI conversion.

### CI & tests
A [travis configuration](.travis.yml) is included, which defines [test.sh](test.sh) 
as its script file, which in turn triggers all `test.sh` files found in directories
directly below the project's root.
