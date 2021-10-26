-- TABLES
-- Drop if exists and create DPC regional-data table
DROP TABLE IF EXISTS [dbo].[dpc-covid19-ita-regioni]
GO
CREATE TABLE [dbo].[dpc-covid19-ita-regioni](
    [data] [date] NOT NULL,
    [stato] [nvarchar](50) NOT NULL,
    [codice_regione] [tinyint] NOT NULL,
    [denominazione_regione] [nvarchar](50) NOT NULL,
    [lat] [float] NOT NULL,
    [long] [float] NOT NULL,
    [ricoverati_con_sintomi] [bigint] NOT NULL,
    [terapia_intensiva] [bigint] NOT NULL,
    [totale_ospedalizzati] [bigint] NOT NULL,
    [isolamento_domiciliare] [bigint] NOT NULL,
    [totale_positivi] [bigint] NOT NULL,
    [variazione_totale_positivi] [bigint] NOT NULL,
    [nuovi_positivi] [bigint] NOT NULL,
    [dimessi_guariti] [bigint] NOT NULL,
    [deceduti] [bigint] NOT NULL,
    [casi_da_sospetto_diagnostico] [bigint] NULL,
    [casi_da_screening] [bigint] NULL,
    [totale_casi] [bigint] NOT NULL,
    [tamponi] [bigint] NOT NULL,
    [casi_testati] [bigint] NULL,
    [note] [text] NULL,
    [ingressi_terapia_intensiva] [bigint] NULL,
    [note_test] [text] NULL,
    [note_casi] [text] NULL,
    [totale_positivi_test_molecolare] [bigint] NULL,
    [totale_positivi_test_antigenico_rapido] [bigint] NULL,
    [tamponi_test_molecolare] [bigint] NULL,
    [tamponi_test_antigenico_rapido] [bigint] NULL,
    [codice_nuts_1] [nvarchar](50) NULL,
    [codice_nuts_2] [nvarchar](50) NULL
) ON [PRIMARY]
GO
-- Drop if exists and create DPC provincial-data table
DROP TABLE IF EXISTS [dbo].[dpc-covid19-itam-province]
GO
CREATE TABLE [dbo].[dpc-covid19-ita-province](
    [data] [date] NOT NULL,
    [stato] [nvarchar](50) NOT NULL,
    [codice_regione] [tinyint] NOT NULL,
    [denominazione_regione] [nvarchar](50) NOT NULL,
    [codice_provincia] [smallint] NOT NULL,
    [denominazione_provincia] [nvarchar](50) NOT NULL,
    [sigla_provincia] [nvarchar](50) NULL,
    [lat] [float] NULL,
    [long] [float] NULL,
    [totale_casi] [int] NOT NULL,
    [note] [text] NULL,
    [codice_nuts_1] [nvarchar](5) NULL,
    [codice_nuts_2] [nvarchar](5) NULL,
    [codice_nuts_3] [nvarchar](5) NULL
) ON [PRIMARY]
GO
-- Drop if exists and create Italia-OD population-data table
DROP TABLE IF EXISTS [dbo].[platea]
GO
CREATE TABLE [dbo].[platea] (
    [area] [varchar](3) NOT NULL,
    [nome_area] [varchar](100) NOT NULL,
    [fascia_anagrafica] [varchar](10) NOT NULL,
    [totale_popolazione] [int] NOT NULL
) ON [PRIMARY]
GO
-- Drop if exists and create Italia-OD vaccine-administrations-data table
DROP TABLE IF EXISTS [dbo].[somministrazioni-vaccini-latest]
GO
CREATE TABLE [dbo].[somministrazioni-vaccini-latest](
    [data_somministrazione] [date] NOT NULL,
    [fornitore] [nvarchar](50) NOT NULL,
    [area] [nvarchar](50) NOT NULL,
    [fascia_anagrafica] [nvarchar](50) NOT NULL,
    [sesso_maschile] [int] NOT NULL,
    [sesso_femminile] [int] NOT NULL,
    [prima_dose] [int] NOT NULL,
    [seconda_dose] [int] NOT NULL,
    [pregressa_infezione] [int] NOT NULL,
    [dose_aggiuntiva] [int] NOT NULL,
    [dose_booster] [int] NOT NULL,
    [codice_NUTS1] [nvarchar](50) NOT NULL,
    [codice_NUTS2] [nvarchar](50) NOT NULL,
    [codice_regione_ISTAT] [int] NOT NULL,
    [nome_area] [nvarchar](50) NOT NULL

) ON [PRIMARY]
GO
-- END TABLES