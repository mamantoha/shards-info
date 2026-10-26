# Country boundaries

Source: Natural Earth v5.1.2, 1:10m Admin 0 Countries, Ukraine POV (public domain).
https://github.com/nvkelso/natural-earth-vector/blob/v5.1.2/geojson/ne_10m_admin_0_countries_ukr.geojson
https://www.naturalearthdata.com/about/terms-of-use/

This variant includes Crimea in Ukraine, rather than using the default dataset's
boundary attribution. Simferopol, Sevastopol, and Dzhankoi were checked to be
inside UA and outside RU after simplification.

Preparation:

1. Simplify the source with Mapshaper 0.7.91 (a one-time tool, not an app dependency):
   `mapshaper -i ne_10m_admin_0_countries_ukr.geojson -simplify 2% keep-shapes -o simplified.geojson format=geojson precision=0.0001`
2. Reduce properties to `name` (NAME_EN) and `code` (ISO_A2_EH), replacing `-99`
   codes with an empty string. Merge features sharing a nonempty code into one
   MultiPolygon, retaining the first feature's name (France, Brazil, Australia).
3. Orient polygon exteriors clockwise for D3: reverse all rings in any polygon
   whose D3 `geoArea` exceeds 2 * Math.PI.

Features without a country code cannot receive visitor counts. Simplification
reduces coastal detail; unknown or unmapped visitors are reported separately.
No runtime download is needed.
