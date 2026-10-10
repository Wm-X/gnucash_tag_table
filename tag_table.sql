.parameter init
.parameter set @tagRE "'o'"

WITH RECURSIVE tree (
    guid,
    parent_guid,
    NAME,
    name_tree,
    name_tabs,
    account_type,
    depth
)
AS (
    SELECT guid,
           parent_guid,
           NAME,
           '' || NAME AS name_tree,
           '' AS name_tabs,
           account_type,
           0 AS depth
      FROM accounts
     WHERE parent_guid IS NULL AND
           NAME <> 'Template Root'
    UNION ALL
    SELECT AC.guid,
           AC.parent_guid,
           AC.NAME,
           tree.name_tree || ':' || AC.NAME AS name_tree,
           substr('.................................',
                  1,
                  depth * 2) || AC.NAME AS name_tabs,
           AC.account_type,
           depth + 1 AS depth
      FROM tree
           JOIN
           accounts AC ON tree.guid = AC.parent_guid
),
CoA AS (
    SELECT *,
           substr(name_tree,
                  14) AS account
      FROM tree
     ORDER BY name_tree
),
jnl AS (
SELECT DATE (transactions.post_date) AS dt
	,transactions.description
	,CoA.account
	,CASE 
		WHEN splits.quantity_num = splits.value_num
			THEN ''
		ELSE CAST(1.0 * splits.quantity_num / splits.quantity_denom AS REAL)
		END AS qty
	,CASE 
		WHEN splits.quantity_num = splits.value_num
			THEN ''
		ELSE c_ac.mnemonic
		END AS ac_commodity
	,CAST(1.0 * splits.value_num / splits.value_denom AS REAL) AS val
	,c_tx.mnemonic AS tx_currency
	,splits.guid AS splits_guid
FROM splits
INNER JOIN commodities AS c_tx ON c_tx.guid = transactions.currency_guid
INNER JOIN transactions ON transactions.guid = splits.tx_guid
INNER JOIN CoA ON CoA.guid = splits.account_guid
INNER JOIN accounts ON accounts.guid = splits.account_guid
INNER JOIN commodities AS c_ac ON c_ac.guid = accounts.commodity_guid
WHERE CoA.account NOT LIKE 'Trading%'
ORDER BY transactions.post_date
	,transactions.guid
	,CoA.account
),
tag_list AS (
    SELECT s.guid AS split_id,
           "tx_desc" AS  tag_location,
           regexp_substr(description,@tagRE) AS tag,
		   description as txt
      FROM transactions t
           JOIN
           splits s ON tx_guid = t.guid
    UNION
    SELECT s.guid AS split_id,
           "tx_num" AS  tag_location,
           regexp_substr(num,@tagRE) AS tag,
		   num as txt
      FROM transactions t
           JOIN
           splits s ON tx_guid = t.guid
    UNION
    SELECT s.guid AS split_id,
           "sp_memo" AS  tag_location,
           regexp_substr(memo,@tagRE) AS tag,
		   memo as txt
      FROM splits s
           JOIN
           transactions t ON t.guid = tx_guid
    UNION
    SELECT s.guid AS split_id,
           "sp_action" AS  tag_location,
           regexp_substr(action,@tagRE) AS tag,
		   action as txt
      FROM splits s
           JOIN
           transactions t ON t.guid = tx_guid
	UNION
	SELECT s.guid AS split_id,
           "tx_notes" AS tag_location,
           regexp_substr(slots.string_val,@tagRE) AS tag,
	       string_val as txt
    FROM slots
       JOIN
       splits s ON s.tx_guid = slots.obj_guid
       WHERE slots.name = 'notes'
)
SELECT *
  FROM tag_list l
  INNER JOIN jnl j ON j.splits_guid = l.split_id
  WHERE val != 0
    AND tag IS NOT NULL
  GROUP BY l.split_id
;
