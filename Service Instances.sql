-- Returns the URLs of all active Service Instances that have no CIs associated.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
DECLARE @Account VARCHAR(100) = 'wdc' -- Optionally used below
SELECT SI.Name
      ,concat(@BaseUrl + '/service_instances/', SI.[ITRP ID]) url
FROM dbo.ALL_service_instances_Normalized SI
LEFT JOIN dbo.ALL_cis_Service_Instances CI_SI 
  ON SI.Name = CI_SI.Service_Instance AND SI.ACCOUNT = CI_SI.Service_Instance_Account
WHERE SI.Status ='in_production' -- and SI.ACCOUNT = @Account
GROUP BY SI.[ITRP ID], SI.Name
HAVING count(CI_SI.[ITRP ID]) = 0
ORDER BY SI.[ITRP ID]
;


-- Returns the URLs of all active Service Instances that have only inactive CIs
-- or no CIs at all associated.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT url FROM
  (
  SELECT
    ALL_service_instances_Normalized."ITRP ID",
    CONCAT(@BaseUrl + '/service_instances/', ALL_service_instances_Normalized."ITRP ID") url,
    COUNT (CASE WHEN all_cis_normalized.status in 
      (
      -- 'archived', 
      -- 'being_built', 
      -- 'being_tested', 
      -- 'broken_down', 
      'in_production', 
      -- 'in_stock', 
      -- 'in_transit', 
      'installed', 
      -- 'lent_out', 
      -- 'lost_or_stolen', 
      -- 'ordered', 
      -- 'removed', 
      -- 'reserved', 
      -- 'standby_for_continuity', 
      -- 'to_be_removed', 
      'undergoing_maintenance'
      ) THEN 1 ELSE NULL END) as active_cis
   
  FROM ALL_service_instances_Normalized

  JOIN ALL_cis_Service_Instances
    on ALL_cis_Service_Instances.account = ALL_service_instances_Normalized.account and ALL_cis_Service_Instances.service_instance = ALL_service_instances_Normalized.name
  
  JOIN all_cis_normalized
    on all_cis_normalized."ITRP ID" = ALL_cis_Service_Instances."ITRP ID" 
   
  WHERE ALL_service_instances_Normalized.Status IN ('in_production') -- Only active SIs

  GROUP BY ALL_service_instances_Normalized."ITRP ID"
  ) t
 
WHERE active_cis = 0
ORDER BY "ITRP ID"
;
