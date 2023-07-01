SELECT deposit_group, magic_wand_creator, MIN(deposit_charge)  as min from wizzard_deposits
GROUP BY deposit_group, magic_wand_creator
order by magic_wand_creator asc, deposit_group asc ;