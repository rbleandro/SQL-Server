--To Remove Log Shipping
--On the log shipping primary server, execute sp_delete_log_shipping_primary_secondary to delete the information about the secondary database from the primary server.
EXEC sp_delete_log_shipping_primary_secondary @primary_database='bbsort',@secondary_database='bbsort',@secondary_server='LMIDVSORTDB02'
GO
--On the log shipping secondary server, execute sp_delete_log_shipping_secondary_database to delete the secondary database.
EXEC sp_delete_log_shipping_secondary_database @secondary_database='bbsort'
GO
--Note: If there are no other secondary databases with the same secondary ID, sp_delete_log_shipping_secondary_primary is invoked from sp_delete_log_shipping_secondary_database and deletes the entry for the secondary ID and the copy and restore jobs.

--On the log shipping primary server, execute sp_delete_log_shipping_primary_database to delete information about the log shipping configuration from the primary server. This also deletes the backup job.
EXEC sp_delete_log_shipping_primary_database @database='bbsort'
GO
--On the log shipping primary server, disable the backup job. For more information, see Disable or Enable a Job.

--On the log shipping secondary server, disable the copy and restore jobs.

--Optionally, if you are no longer using the log shipping secondary database, you can delete it from the secondary server.

