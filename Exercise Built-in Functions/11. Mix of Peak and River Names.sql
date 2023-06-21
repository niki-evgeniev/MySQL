SELECT 
    peak_name,
    river_name,
    LOWER(CONCAT(peak_name,
                    RIGHT(river_name,
                        LENGTH(river_name) - 1))) AS mix
FROM
    rivers,
    peaks
WHERE
    LOWER(LEFT(river_name, 1)) = RIGHT(peak_name, 1)
ORDER BY mix;
