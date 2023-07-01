SELECT `deposit_group`
FROM wizzard_deposits
GROUP BY  `deposit_group`
ORDER BY AVG(deposit_group)
LIMIT 1;
