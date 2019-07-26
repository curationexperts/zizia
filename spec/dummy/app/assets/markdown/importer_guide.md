# Title

A name to aid in identifying a work.

This field is a string.  **This field is required**.



## Example

`[Fannie Lou Hamer, Mississippi Freedom Democratic Party delegate, at the Democratic National Convention, Atlantic City, New Jersey, August 1964] / [WKL].`

If you have multiple titles, separate them with the `|~|` delimiter, like this:

`[Fannie Lou Hamer, Mississippi Freedom Democratic Party delegate, at the Democratic National Convention, Atlantic City, New Jersey, August 1964] / [WKL].|~|[Fannie Lou Hamer, Mississippi Freedom Democratic Party delegate, at the Democratic National Convention, Atlantic City, New Jersey, August 1964] / [WKL].`

# Creator

The person or group responsible for the work. Usually this is the author of the content. Personal names should be entered with the last name first, e.g. "Smith, John.".

This field is a string. **This field is required**

## Example

`Leffler, Warren K., photographer`

If you have multiple creators you can enter them like this:

`Leffler, Warren K., photographer|~|Leffler, Warren L., photographer`

# Keyword

Words or phrases you select to describe what the work is about. These are used to search for content.

This field is a string. **This field is required**.

## Example

`Atlantic City`

If you have multiple keywords you can enter them like this:

`Atlantic City|~|Atlantic City, N.J.|~|Democratic National Convention`

# Rights Statement

This field is a URI. You can choose rights statements from
this [vocabulary](https://github.com/curationexperts/tenejo/blob/master/config/authorities/rights_statements.yml).

**This field is required**

## Example:

`http://rightsstatements.org/vocab/UND/1.0/`

# Contributor

A person or group you want to recognize for playing a role in the creation of the work, but not the primary role.

This field is a string. *This field is optional*.

## Example

`Smith, Mary`

If you have multiple contributors you can enter them like this:

`Smith, Mary|~|Smith, John`

# Abstract or Summary

Free-text notes about the work. Examples include abstracts of a paper or citation information for a journal article.

This field is a string. *This field is optional*.

## Example

`Photograph shows half-length portrait of Hamer seated at a table.`

If you have multiple abstracts you can enter them like this:

`Photograph shows half-length portrait of Hamer seated at a table.
|~|Photograph shows half-length portrait of Hamer seated near a table.`

# License

Licensing and distribution information governing access to the work.

This field is a URI. *This field is optional*.

You can choose rights statements from
this [vocabulary](https://github.com/curationexperts/tenejo/blob/master/config/authorities/licenses.yml).

## Example

`http://creativecommons.org/licenses/by/3.0/us/`

If you have multiple rights statements you can enter them like this:

`http://creativecommons.org/licenses/by/3.0/us/|~|http://creativecommons.org/licenses/by-sa/3.0/us/`

# Publisher

The person or group making the work available. Generally this is the institution.

This field is a string. *This field is optional*.

## Example

`Library of Congress`

If you have multiple publishers you can enter them like this:

`Library of Congress|~|National Archives`

# Date Created

The date on which the work was created.

This field is a string. *This field is optional*.

## Example

`1964 Aug. 22.`

If you have multiple dates you can enter them like this:

`1964 Aug. 22.|~|1964 Aug. 23.`

# Subject

Headings or index terms describing what the work is about; these do need to conform to an existing vocabulary.

This field is a string. *This field is optional*.

## Example

`Hamer, Fannie Lou--Public appearances--New Jersey--Atlantic City.`

If you have multiple subjects you can enter them like this:

`Hamer, Fannie Lou--Public appearances--New Jersey--Atlantic City|~|Mississippi Freedom Democratic Party--People--New Jersey--Atlantic City--1960-1970|~|Democratic National Convention--(1964 :--Atlantic City, N.J.)--People`

# Language

The language of the work's content.

This field is a string. *This field is optional*.

## Example

`English`

If you have multiple languages you can enter them like this:

`English|~|French`

# Identifier

A unique handle identifying the work. An example would be a DOI for a journal article, or an ISBN or OCLC number for a book.

This field is a string. *This field is optional*.

## Example

`LC-U9- 12470B-17`

If you have multiple identifiers you can enter them like this:

`LC-U9- 12470B-17|~|2003688126`

# Location

A place name related to the work, such as its site of publication, or the city, state, or country the work contents are about.

This field is a URI. *This field is optional*. The URIs should be
GeoNames identifiers. You can look these up at [GeoNames](http://www.geonames.org/).

## Example

`http://www.geonames.org/4500546/`

If you have multiple locations you can enter them like this:

`http://www.geonames.org/4500546/|~|http://www.geonames.org/4500547/`

# Related URL

A link to a website or other specific content (audio, video, PDF document) related to the work. An example is the URL of a research project from which the work was derived.

This field is a string or a URI. *This field is optional*.

## Example

`https://www.loc.gov/free-to-use/african-american-women-changemakers/`

If you have multiple related URLs you can enter them like this:

`https://www.loc.gov/free-to-use/african-american-women-changemakers/|~|http://www.loc.gov`


# Source

A related resource from which the described resource is derived.

This field is a string. *This field is optional*.

## Example

`Library of Congress Online Catalog (976,247)`

If you have multiple sources you can enter them like this:

`Library of Congress Online Catalog (976,247)|~|Prints and Photographs Division (848,104)`

# Resource Type

This field is a string. *This field is optional*.

Pre-defined categories to describe the type of content being uploaded, such as "Article" or "Dataset." More than one type may be selected.

You must choose from one of the types listed [here](https://github.com/curationexperts/tenejo/blob/master/config/authorities/resource_types.yml).

## Example

`Image`

If you have multiple resource types you can enter them like this:

`Image|~|Audio`

# Visibility

This field is a case-sensetive string. **This field is required**.

You can only have one of these.

You can use `open`, `registered`, or `restricted`

## Example

`open`

# Files

You can add one or more files to associate with this work.

This field is a string. **This field is required**.

## Example

`01267_150px.jpg`

If you have multiple resource types you can enter them like this:

`01267_150px.jpg|~|01267_151px.jpg`
