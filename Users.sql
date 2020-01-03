-- Cleanup
-- Use this before commands that create the temporary table.
DROP table #tmp;

-- Specific Users
-- Use these two statements to search for arbitrary users
CREATE table #tmp (email varchar(254));
INSERT into #tmp values ('howard.tanner@widget.com');

-- All Disabled Users
-- Use this statement to find all disabled users
SELECT "Primary Email" email into #tmp from dbo.ALL_people_Normalized
	where Disabled=1 AND "Primary Email" LIKE '%@widget.com'
	AND "Primary Email" NOT IN (SELECT "Primary Email" from dbo.ALL_people_Normalized where disabled=0) -- don't include users who have an enabled account as well.
	;

-- Main
-- This statement finds all records that have users from #tmp associated and prints the URLs of those records.
DECLARE @BaseUrl VARCHAR(100) = 'https://4me-demo.com' -- Use your base URL here
SELECT concat(@BaseUrl + '/changes/', "ITRP ID") 
	from ALL_changes_Normalized 
	where status != 'completed' AND manager IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/flsas/', "ITRP ID") 
	from ALL_flsas_Normalized 
	where status != 'expired' AND Customer_Representative IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/organizations/', "ITRP ID") 
	from ALL_organizations_Normalized 
	where ALL_organizations_Normalized.Disabled = 0 AND (manager IN (SELECT email from #tmp) OR substitute IN (SELECT email from #tmp))
union
SELECT concat(@BaseUrl + '/people/', "ITRP ID") 
	from ALL_people_Normalized 
	where disabled=0 AND "Primary Email" IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/problems/', "ITRP ID") 
	from ALL_problems_Normalized 
	where status != 'solved' AND (manager IN (SELECT email from #tmp) OR member IN (SELECT email from #tmp))
UNION
SELECT concat(@BaseUrl + '/project_tasks/', Project_Task) 
	from ALL_project_task_assignments_Normalized 
	where status NOT IN ('completed', 'canceled') AND assignee IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/project_task_templates/', "Project Task Template") 
	from ALL_project_task_template_assignments 
	where assignee IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/projects/', "ITRP ID") 
	from ALL_projects_Normalized 
	where status NOT IN ('completed') AND manager IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/releases/', "ITRP ID") 
	from ALL_releases_Normalized 
	where manager IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/requests/', "ITRP ID") 
	from ALL_requests_Normalized 
	where member IN (SELECT email from #tmp) AND Status != 'completed'
UNION
SELECT concat(@BaseUrl + '/services/', "ITRP ID") 
	from dbo.ALL_services_Normalized
	where all_services_Normalized.Disabled = 0 AND
		(  service_owner IN (SELECT email from #tmp)
		OR release_manager IN (SELECT email from #tmp)
		OR change_manager IN (SELECT email from #tmp)
		OR problem_manager IN (SELECT email from #tmp)
		OR availability_manager IN (SELECT email from #tmp)
		OR capacity_manager IN (SELECT email from #tmp)
		OR continuity_manager IN (SELECT email from #tmp)
		)
UNION
SELECT concat(@BaseUrl + '/slas/',"ITRP ID") 
	from ALL_slas_Normalized 
	where status != 'expired' AND (Service_Level_Manager IN (SELECT email from #tmp) OR Customer_Representative IN (SELECT email from #tmp))
UNION
SELECT concat(@BaseUrl + '/task_templates/', "ITRP ID") 
	from ALL_task_templates_Normalized 
	where disabled=0 AND member IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/change_templates/', "ITRP ID") 
	from ALL_change_templates_Normalized 
	where disabled=0 AND "Recurrence_-_Change_Manager" IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/teams/', "ITRP ID") 
	from ALL_teams_Normalized 
	where all_teams_normalized.Disabled=0 AND manager IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/request_template/', "ITRP ID") 
	from dbo.ALL_request_templates 
	where ALL_request_templates.Disabled=0 AND ALL_request_templates.Member IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/cis/', ALL_cis_Users."ITRP ID") 
	from dbo.ALL_cis_Users
	join dbo.ALL_cis_Normalized as cis
		on ALL_cis_Users."ITRP ID" = cis."ITRP ID"
		AND ALL_cis_Users.ACCOUNT = cis.ACCOUNT
		AND cis.Status != 'removed'
	where ALL_cis_Users."User" IN (SELECT email from #tmp)
UNION
SELECT concat(@BaseUrl + '/tasks/', "ITRP ID") 
	from dbo.ALL_tasks_Normalized 
	where (Status != 'failed' AND Status != 'rejected' AND Status != 'completed' AND Status != 'canceled' AND Status != 'approved') 
		AND member IN (SELECT email from #tmp)
;
