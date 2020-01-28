-- Returns the URLs of all active Products associated with deactivated Organizations
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT DISTINCT CONCAT(@BaseUrl + '/products/', ALL_products_Normalized."ITRP ID")
 
FROM dbo.ALL_products_Normalized
 
JOIN dbo.ALL_organizations_Normalized ON
  ALL_products_Normalized.Supplier =  ALL_organizations_Normalized.Name AND
  ALL_products_Normalized.Supplier_Account = ALL_organizations_Normalized.ACCOUNT
  
WHERE ALL_organizations_Normalized.Disabled = 1
AND ALL_products_Normalized.Disabled = 0;
