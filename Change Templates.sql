-- All active Change Templates ordered by their last use, least recently used first.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here

SELECT MAX(ALL_changes_Normalized."Created At"),
CONCAT(@BaseUrl + '/change_templates/', ALL_change_templates_Normalized."ITRP ID") url

FROM dbo.ALL_changes_Normalized
JOIN dbo.ALL_change_templates_Normalized
  ON ALL_changes_Normalized.Template = ALL_change_templates_Normalized."ITRP ID" and ALL_changes_Normalized.ACCOUNT = ALL_change_templates_Normalized.ACCOUNT
  
WHERE ALL_change_templates_Normalized.Disabled=0
 
GROUP BY ALL_change_templates_Normalized."ITRP ID"
 
ORDER BY max(ALL_changes_Normalized."Created At");
