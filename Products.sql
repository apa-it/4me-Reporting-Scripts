-- Returns the URLs of all active Products associated with deactivated Organizations
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
select distinct concat('/products/', ALL_products_Normalized."ITRP ID")
 
from dbo.ALL_products_Normalized
 
join dbo.ALL_organizations_Normalized on
  ALL_products_Normalized.Supplier =  ALL_organizations_Normalized.Name and
  ALL_products_Normalized.Supplier_Account = ALL_organizations_Normalized.ACCOUNT
  
where ALL_organizations_Normalized.Disabled = 1
and ALL_products_Normalized.Disabled = 0;
