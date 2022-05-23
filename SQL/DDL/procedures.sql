-- PROCEDURES
-- Create procedure to harmonize vaccine-administrations-data table with population-data table
CREATE OR ALTER PROCEDURE [dbo].[UpdateAdminsData] AS
BEGIN
    UPDATE [dbo].[somministrazioni-vaccini-latest]
    SET eta =
        CASE [eta]
            WHEN '80-89' THEN '80+'
            WHEN '90+' THEN '80+'
            ELSE [eta]
        END,
        ISTAT =
        CASE
            WHEN [area] = 'PAB' THEN 21
            WHEN [area] = 'PAT' THEN 22
            ELSE [ISTAT]
        END
END
GO

-- Fact table generation
CREATE OR ALTER PROCEDURE [dbo].[GenerateFactTable] AS
    TRUNCATE TABLE [dbo].[Fact];
    WITH
        VAX AS (
            SELECT -- VAX
                CAST([data] AS DATE) AS [Data],
                1                                     AS [DataTypeKey],
                [ISTAT]                               AS [RegionKey],
                CAST(HASHBYTES(
                    'MD5',
                    CAST([forn] as nvarchar)
                ) as bigint)                          AS [ProviderKey],
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
                END                                  AS [AgeRangeKey],
                CAST(HASHBYTES(
                    'MD5',
                    CAST([area] as nvarchar)
                    +CAST([eta] as nvarchar)
                ) as bigint)                        AS [PopKey],
                SUM([m])                            AS [Sesso Maschile],
                SUM([f])                            AS [Sesso Femminile],
                SUM([d1])                           AS [Prima Dose],
                SUM([d2])                           AS [Seconda Dose],
                SUM([dpi])                          AS [Pregressa Infezione],
                SUM([db1])                          AS [Dose Booster]
            FROM
                [dbo].[somministrazioni-vaccini-latest]
            GROUP BY
                [data],
                ISTAT,
                forn,
                eta,
                area
        )
        ,
        REG AS (
            SELECT -- PANDEMIA REGIONALE
                [codice_regione],
                CAST([data] as date)                             AS [Data],
                2                                                AS [DataTypeKey],
                [ricoverati_con_sintomi]                         AS [Ricoverati con sintomi],
                [terapia_intensiva]                              AS [T.I.],
                ISNULL(
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
                )                                                AS [T.I. Giornaliere],
                [totale_ospedalizzati]                           AS [Totale ospedalizzati],
                [isolamento_domiciliare]                         AS [Isolamento domiciliare],
                [totale_positivi]                                AS [Totale Positivi],
                [variazione_totale_positivi]                     AS [Variazione Totale Positivi],
                [nuovi_positivi]                                 AS [Nuovi Positivi],
                [dimessi_guariti]                                AS [Dimessi],
                [deceduti]                                       AS [Decessi],
                ISNULL(
                    [deceduti] - LAG([deceduti]) OVER (
                        PARTITION BY denominazione_regione
                        ORDER BY [data]
                    )
                    ,0
                )                                                AS [Decessi Giornalieri],
                [totale_casi]                                    AS [Totale Casi],
                [tamponi]                                        AS [Tamponi],
                ISNULL(
                    [tamponi] - LAG([tamponi])
                        OVER (
                            PARTITION BY
                                [denominazione_regione]
                            ORDER BY [data]
                        )
                    ,0
                )                                                 AS [Tamponi Giornalieri]
            FROM
                dbo.[dpc-covid19-ita-regioni]
        )
    INSERT INTO [dbo].[Fact] (
        [Data]
        ,[DataTypeKey]
        ,[RegionKey]
        ,[ProviderKey]
        ,[AgeRangeKey]
        ,[PopKey]
        ,[Ricoverati con sintomi]
        ,[T.I.]
        ,[T.I. Giornaliere]
        ,[Totale ospedalizzati]
        ,[Isolamento domiciliare]
        ,[Totale Positivi]
        ,[Variazione Totale Positivi]
        ,[Nuovi Positivi]
        ,[Dimessi]
        ,[Decessi]
        ,[Decessi Giornalieri]
        ,[Totale Casi]
        ,[Tamponi]
        ,[Tamponi Giornalieri]
        ,[Indice di positività]
        ,[Prima Dose]
        ,[Seconda Dose]
        ,[Sesso Maschile]
        ,[Sesso Femminile]
        ,[Pregressa Infezione]
        ,[Dose Booster]
    )
    SELECT
        [Data],
        [DataTypeKey],
        RegionKey,
        ProviderKey,
        AgeRangeKey,
        PopKey,
        0 [Ricoverati con sintomi],
        0 [T.I.],
        0 [T.I. Giornaliere],
        0 [Totale ospedalizzati],
        0 [Isolamento domiciliare],
        0 [Totale Positivi],
        0 [Variazione Totale Positivi],
        0 [Nuovi Positivi],
        0 [Dimessi],
        0 [Decessi],
        0 [Decessi Giornalieri],
        0 [Totale Casi],
        0 [Tamponi],
        0 [Tamponi Giornalieri],
        0 [Indice di positività],
        [Prima Dose],
        [Seconda Dose],
        [Sesso Maschile],
        [Sesso Femminile],
        [Pregressa Infezione],
        [Dose Booster]
    FROM
        VAX

    UNION

    SELECT
        [Data],
        [DataTypeKey],
        codice_regione AS RegionKey,
        -999 AS ProviderKey,
        -999 AS AgeRangeKey,
        -999 AS PopKey,
        [Ricoverati con sintomi],
        [T.I.],
        [T.I. Giornaliere],
        [Totale ospedalizzati],
        [Isolamento domiciliare],
        [Totale Positivi],
        [Variazione Totale Positivi],
        [Nuovi Positivi],
        [Dimessi],
        [Decessi],
        [Decessi Giornalieri],
        [Totale Casi],
        [Tamponi],
        [Tamponi Giornalieri],
        CASE [Tamponi Giornalieri]
            WHEN 0 THEN 0
            ELSE [Nuovi Positivi] / [Tamponi Giornalieri]
        END [Indice di positività],
        0 [Prima Dose],
        0 [Seconda Dose],
        0 [Sesso Maschile],
        0 [Sesso Femminile],
        0 [Pregressa Infezione],
        0 [Dose Booster]
    FROM
        REG
GO
-- END PROCEDURES