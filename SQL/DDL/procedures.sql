-- PROCEDURES
-- Create procedure to harmonize vaccine-administrations-data table with population-data table
CREATE OR ALTER PROCEDURE [dbo].[UpdateAdminsData] AS
BEGIN
    UPDATE [dbo].[somministrazioni-vaccini-latest]
    SET fascia_anagrafica =
        CASE [fascia_anagrafica]
            WHEN '80-89' THEN '80+'
            WHEN '90+' THEN '80+'
            ELSE [fascia_anagrafica]
        END,
        codice_regione_ISTAT =
        CASE
            WHEN [area] = 'PAB' THEN 21
            WHEN [area] = 'PAT' THEN 22
            ELSE [codice_regione_ISTAT]
        END
END
GO
-- END PROCEDURES