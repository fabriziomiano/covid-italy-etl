--VIEWS
-- Model Dimensions
-- Create Calendar Dimension view for Data Model
CREATE OR ALTER VIEW [dbo].[Calendario] AS
    SELECT DISTINCT
        CAST([data] as date)                  AS [Data]
    FROM [dbo].[dpc-covid19-ita-province]
GO
-- Create Provinces Dimension view for Data Model
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
-- Create Regions Dimension view for Data Model
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
-- Create Age-range Dimension view for Data Model
CREATE OR ALTER VIEW [dbo].[AgeRange] AS
    SELECT DISTINCT
        CASE [fascia_anagrafica]
            WHEN '80-89' THEN 80
            WHEN '90+' THEN 80
            ELSE
            CAST(
                REPLACE(
                    REPLACE([fascia_anagrafica], '-', '')
                    , '+', ''
                ) as int
            )
        END                                           [AgeRangeKey]
        ,CASE [fascia_anagrafica]
            WHEN '80-89' THEN '80+'
            WHEN '90+' THEN '80+'
            ELSE [fascia_anagrafica]
        END                                           [Fascia Anagrafica]
    FROM [dbo].[somministrazioni-vaccini-latest]
GO
-- Create Provider Dimension view for Data Model
CREATE OR ALTER VIEW [dbo].[Provider] AS
    SELECT DISTINCT
        CAST(HASHBYTES(
                'MD5',
                CAST([fornitore] as nvarchar)
            ) as bigint)                      AS [ProviderKey]
        ,[fornitore]                          AS [Fornitore]
    FROM [dbo].[somministrazioni-vaccini-latest]
GO
-- Create Regional-granularity fact view for Data Model
CREATE OR ALTER VIEW [dbo].[Regionale] AS
    SELECT
        CAST(HASHBYTES(
            'MD5',
            CAST([data] AS nvarchar)
            +CAST(codice_regione as nvarchar)
        ) as bigint)                                      AS [RegionalPandemicKey]
        ,CAST([data] as date)                             AS [Data]
        ,[ricoverati_con_sintomi]                         AS [Ricoverati con sintomi]
        ,[terapia_intensiva]                              AS [T.I.]
        ,ISNULL(
            [ingressi_terapia_intensiva]
            ,ISNULL(
                [terapia_intensiva]
                - LAG([terapia_intensiva])
                OVER (
                    PARTITION BY [denominazione_regione]
                    ORDER BY [data]
                )
                ,[terapia_intensiva]
            )
        )                                                 AS [T.I. Giornaliere]
        ,[totale_ospedalizzati]                           AS [Totale ospedalizzati]
        ,[isolamento_domiciliare]                         AS [Isolamento domiciliare]
        ,[totale_positivi]                                AS [Totale Positivi]
        ,[variazione_totale_positivi]                     AS [Variazione Totale Positivi]
        ,[nuovi_positivi]                                 AS [Nuovi Positivi]
        ,[dimessi_guariti]                                AS [Dimessi]
        ,[deceduti]                                       AS [Decessi]
        ,ISNULL(
            [deceduti] - LAG([deceduti]) OVER (
                PARTITION BY denominazione_regione
                ORDER BY [data]
            )
            ,0
        )                                                 AS [Decessi Giornalieri]
        ,[totale_casi] [Totale Casi]
        ,[tamponi] [Tamponi]
        ,ISNULL(
            [tamponi] - LAG([tamponi])
                OVER (
                    PARTITION BY
                        [denominazione_regione]
                    ORDER BY [data]
                )
            ,0
        )                                                 AS [Tamponi Giornalieri]
        FROM dbo.[dpc-covid19-ita-regioni]
GO
-- Create Provincial-granularity fact view for Data Model
CREATE OR ALTER VIEW [dbo].[Provinciale] AS
    SELECT
        CAST(
            HASHBYTES(
                'MD5',
                CAST([data] AS nvarchar)
                +CAST([codice_regione] as nvarchar)
                +CAST([codice_provincia] as nvarchar)
            ) as bigint
        )                                              AS [ProvincialPandemicKey]
        ,CAST([data] as date)                          AS [Data]
        ,[totale_casi]                                 AS [Totale Casi]
        ,ISNULL(
            [totale_casi] - LAG([totale_casi])
                OVER (
                    PARTITION BY
                        [denominazione_regione]
                        , [denominazione_provincia]
                    ORDER BY [data]
                )
            ,0
        )                                              AS [Nuovi Positivi]
    FROM dbo.[dpc-covid19-ita-province]
    WHERE denominazione_provincia NOT IN (
        'Fuori Regione / Provincia Autonoma'
        , 'In fase di definizione/aggiornamento'
    )
GO
-- Create Vaccine fact view for Data Model
CREATE OR ALTER VIEW [dbo].[Vaccini] AS
    SELECT
        CAST(HASHBYTES(
            'MD5',
            CAST([data_somministrazione] as nvarchar)
            +CAST([codice_regione_ISTAT] as nvarchar)
            +CAST([fornitore] as nvarchar)
            +CAST([fascia_anagrafica] as nvarchar)
        ) as bigint)                                  AS [VaxKey]
        ,SUM([sesso_maschile])                        AS [Sesso Maschile]
        ,SUM([sesso_femminile])                       AS [Sesso Femminile]
        ,SUM([prima_dose])                            AS [Prima Dose]
        ,SUM([seconda_dose])                          AS [Seconda Dose]
        ,SUM([pregressa_infezione])                   AS [Pregressa Infezione]
        ,SUM([dose_aggiuntiva])                       AS [Dose Aggiuntiva]
        ,SUM([dose_booster])                          AS [Dose Booster]
    FROM [dbo].[somministrazioni-vaccini-latest]
    GROUP BY
        data_somministrazione
        ,codice_regione_ISTAT
        ,fornitore
        ,fascia_anagrafica
GO
-- Create Population fact view for Data Model
CREATE OR ALTER VIEW [dbo].[Popolazione] AS
    SELECT
        CAST(HASHBYTES(
            'MD5',
            CAST([area] as nvarchar)
            +CAST([fascia_anagrafica] as nvarchar)
        ) as bigint)                               AS [PopKey]
        ,[totale_popolazione]                      AS [Popolazione]
    FROM [dbo].[platea]
GO
-- Create Pandemic Bridge Fact-less view for Data Model
CREATE OR ALTER VIEW [dbo].[PanBridge] AS
    with bridge as (
        SELECT
            CAST(HASHBYTES(
                'MD5',
                CAST(CAST(p.[data] as date) AS nvarchar)
                +CAST(p.[codice_regione] as nvarchar)
                +CAST(p.[codice_provincia] as nvarchar)) as bigint)  AS [BridgeKey]
            ,CAST(HASHBYTES(
                'MD5',
                CAST(CAST(r.[data] as date) AS nvarchar)
                +CAST(r.[codice_regione] as nvarchar)) as bigint)    AS [RegionalPandemicKey]
            ,CAST(p.[data] as date)                                  AS [DateKey]
            ,p.[codice_provincia]                                    AS [ProvinceKey]
            ,r.[codice_regione]                                      AS [RegionKey]
        FROM [dbo].[dpc-covid19-ita-province] p
        JOIN [dbo].[dpc-covid19-ita-regioni] r
            ON CAST(p.[data] as date)=CAST(r.[data] as date)
            AND p.[denominazione_regione]=r.[denominazione_regione]
            AND p.[denominazione_provincia] not in (
                'Fuori Regione / Provincia Autonoma'
                ,'In fase di definizione/aggiornamento'
            )
    )
    select
        [BridgeKey]
        ,[RegionalPandemicKey]
        ,[DateKey]
        ,[RegionKey]
        ,[ProvinceKey]
    FROM bridge
    group by
        [BridgeKey]
        ,[RegionalPandemicKey]
        ,[DateKey]
        ,[RegionKey]
        ,[ProvinceKey]
GO
-- Create Vax Bridge fact-less view for Data Model
CREATE OR ALTER VIEW [dbo].[VaxBridge] AS
WITH
    bridge AS (
        SELECT
            CAST(HASHBYTES(
                'MD5',
                CAST([data_somministrazione] as nvarchar)
                +CAST([codice_regione_ISTAT] as nvarchar)
                +CAST([fornitore] as nvarchar)
                +CAST([fascia_anagrafica] as nvarchar)
            ) as bigint)                                       AS [BridgeKey]
            ,CAST([data_somministrazione] as date)             AS [DateKey]
            ,CASE [fascia_anagrafica]
                WHEN '80-89' THEN 80
                WHEN '90+' THEN 80
                ELSE
                CAST(
                    REPLACE(
                        REPLACE([fascia_anagrafica], '-', '')
                        , '+', ''
                    ) as int
                )
            END                                                AS [AgeRangeKey]
            ,CAST([codice_regione_ISTAT] as int)               AS [RegionKey]
            ,CAST(HASHBYTES(
                'MD5',
                CAST([fornitore] as nvarchar)
            ) as bigint)                                       AS [ProviderKey]
            ,CAST(HASHBYTES(
                'MD5',
                CAST([area] as nvarchar)
                +CAST([fascia_anagrafica] as nvarchar)
            ) as bigint)                                       AS [PopKey]
        FROM [dbo].[somministrazioni-vaccini-latest]
    )
    SELECT
        [BridgeKey]
        ,[DateKey]
        ,[AgeRangeKey]
        ,[RegionKey]
        ,[ProviderKey]
        ,[PopKey]
    FROM bridge
    GROUP BY
        [BridgeKey]
        ,[DateKey]
        ,[AgeRangeKey]
        ,[RegionKey]
        ,[ProviderKey]
        ,[PopKey]
GO
-- END VIEWS