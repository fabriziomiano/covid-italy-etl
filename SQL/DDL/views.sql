/****** Object:  View [dbo].[DataType]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim DataType
CREATE OR ALTER VIEW [dbo].[DataType] AS
    SELECT
        1 AS DataTypeKey,
        'Vaccini' AS [Data Type]
    UNION
    SELECT
        2 AS DataTypeKey,
        'Pandemia' AS [Data Type]
GO
/****** Object:  View [dbo].[AgeRange]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim Fascia anagrafica
CREATE OR ALTER VIEW [dbo].[AgeRange] AS
    SELECT DISTINCT
        CASE [eta]
            WHEN '80-89' THEN 80
            WHEN '90+' THEN 80
            ELSE
            CAST(
                REPLACE(
                    REPLACE([eta], '-', '')
                    , '+', ''
                ) as int
            )
        END                                           [AgeRangeKey]
        ,CASE [eta]
            WHEN '80-89' THEN '80+'
            WHEN '90+' THEN '80+'
            ELSE [eta]
        END                                           [Fascia Anagrafica]
    FROM [dbo].[somministrazioni-vaccini-latest]
GO
/****** Object:  View [dbo].[Calendario]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim Calendario
CREATE OR ALTER VIEW [dbo].[Calendario] AS
    SELECT DISTINCT
        CAST([data] as date)                  AS [Data]
    FROM [dbo].[dpc-covid19-ita-province]
GO


/****** Object:  View [dbo].[Popolazione]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Fatto Popolazione
CREATE OR ALTER VIEW [dbo].[Popolazione] AS
    SELECT
        CAST(HASHBYTES(
            'MD5',
            CAST([area] as nvarchar)
            +CAST([eta] as nvarchar)
        ) as bigint)                               AS [PopKey]
        ,[totale_popolazione]                      AS [Popolazione]
    FROM [dbo].[platea]
GO
/****** Object:  View [dbo].[Provider]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim Provider
CREATE OR ALTER VIEW [dbo].[Provider] AS
    SELECT DISTINCT
        CAST(HASHBYTES(
                'MD5',
                CAST([forn] as nvarchar)
            ) as bigint)                      AS [ProviderKey]
        ,[forn]                               AS [Fornitore]
    FROM [dbo].[somministrazioni-vaccini-latest]
GO
/****** Object:  View [dbo].[Province]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim Province
CREATE OR ALTER VIEW [dbo].[Province] AS
    SELECT DISTINCT
        [codice_provincia]         AS [ProvinceKey]
        ,[denominazione_provincia] AS [Provincia]
        ,round(lat, 7)             AS [Lat]
        ,round(long, 7)            AS [Lon]
        ,[codice_nuts_1]           AS [NUTS1]
        ,[codice_nuts_2]           AS [NUTS2]
        ,[codice_nuts_3]           AS [NUTS3]
    FROM [dbo].[dpc-covid19-ita-province]
    WHERE [codice_nuts_1] IS NOT NULL
    AND [codice_nuts_2] IS NOT NULL
    AND [codice_nuts_3] IS NOT NULL
GO
/****** Object:  View [dbo].[Regioni]    Script Date: 11/6/2021 7:54:01 PM ******/
-- Dim Regioni
CREATE OR ALTER VIEW [dbo].[Regioni] AS
    SELECT DISTINCT
        [codice_regione]         AS [RegionKey]
        ,[denominazione_regione] AS [Regione]
        ,[codice_nuts_1]         AS [NUTS1]
        ,[codice_nuts_2]         AS [NUTS2]
        ,round([lat], 7)         AS [Lat]
        ,round([long], 7)        AS [Lon]
    FROM [dbo].[dpc-covid19-ita-regioni]
    WHERE [codice_nuts_1] IS NOT NULL
    AND [codice_nuts_2] IS NOT NULL
    AND [lat] IS NOT NULL
    AND [long] IS NOT NULL
GO