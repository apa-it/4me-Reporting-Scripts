-- Returns the URLS of all active SLAs associated with at least one inactive Organization.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT DISTINCT CONCAT(@BaseUrl + '/slas/', ALL_slas_Normalized."ITRP ID") "URL"
FROM dbo.ALL_slas_Organizations
	JOIN dbo.ALL_slas_Normalized ON
		ALL_slas_Organizations."ITRP ID" = ALL_slas_Normalized."ITRP ID" AND
		ALL_slas_Organizations.ACCOUNT = ALL_slas_Normalized.ACCOUNT
	JOIN dbo.ALL_organizations_Normalized ON
		ALL_slas_Organizations.Organization =  ALL_organizations_Normalized.Name AND
		ALL_slas_Organizations.Organization_Account = ALL_organizations_Normalized.ACCOUNT
 
	WHERE ALL_organizations_Normalized.Disabled = 1
	and ALL_slas_Normalized.Status = 'active'
;



-- Returns the URLs of all SLAs associated with at least one inactive Service Offering
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT DISTINCT CONCAT(@BaseUrl + '/slas/', ALL_slas_Normalized."ITRP ID") "URL"
FROM ALL_slas_Normalized
JOIN ALL_service_offerings_Normalized as so
	ON  ALL_slas_Normalized.Service_Offering = so.Name
	AND ALL_slas_Normalized.Service_Offering_Account = so.ACCOUNT
WHERE all_slas_normalized.Status = 'active' AND so.Status = 'discontinued';



-- Returns all active SLAs associated with at least one inactive SI.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT DISTINCT CONCAT(@BaseUrl + '/slas/', ALL_slas_Normalized."ITRP ID") "URL"
FROM ALL_slas_Normalized
JOIN ALL_slas_Service_Instances on all_slas_normalized."ITRP ID" = ALL_slas_Service_Instances."ITRP ID"
JOIN ALL_service_instances_Normalized as si_cov
        ON  ALL_slas_Service_Instances.Service_Instance = si_cov.Name
        AND ALL_slas_Service_Instances.Service_Instance_Account = si_cov.ACCOUNT
         
JOIN ALL_service_instances_Normalized as si
        ON  ALL_slas_Normalized.Service_Instance = si.Name
        AND ALL_slas_Normalized.Service_Instance_Account = si.ACCOUNT
         
WHERE all_slas_normalized.Status = 'active' AND (si.Status = 'discontinued' OR si_cov.Status = 'discontinued');



-- Returns all active SLAs associated with at least one inactive person.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT DISTINCT CONCAT(@BaseUrl + '/slas/', ALL_slas_Normalized."ITRP ID") "URL"
  
FROM ALL_slas_Normalized
  
JOIN ALL_slas_people ON all_slas_normalized."ITRP ID" = ALL_slas_people."ITRP ID"
 
JOIN ALL_people_Normalized as p_cov
        ON  ALL_slas_people.person = p_cov."Primary Email"
        AND ALL_slas_people.person_Account = p_cov.ACCOUNT
          
JOIN ALL_people_Normalized as p
        ON  ALL_slas_Normalized.Service_Level_Manager = p."Primary Email"
        AND ALL_slas_Normalized.Service_Level_Manager_Account = p.ACCOUNT
          
JOIN ALL_people_Normalized as c
        ON  ALL_slas_Normalized.Customer_Representative = c."Primary Email"
        AND ALL_slas_Normalized.Customer_Representative_Account = c.ACCOUNT
          
WHERE all_slas_normalized.Status = 'active' AND (p_cov.Disabled = 1 OR p.Disabled = 1 OR c.Disabled = 1);
