SELECT country_name, population
FROM countries
WHERE continent_code LIKE 'EU'
ORDER BY population DESC, country_name
LIMIT 30;