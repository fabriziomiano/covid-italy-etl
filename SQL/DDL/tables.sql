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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Drop if exists and create DPC provincial-data table
DROP TABLE IF EXISTS [dbo].[dpc-covid19-ita-province]
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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Drop if exists and create Italia-OD population-data table
DROP TABLE IF EXISTS [dbo].[platea]
GO
CREATE TABLE [dbo].[platea](
	[area] [varchar](3) NOT NULL,
	[reg] [varchar](100) NOT NULL,
	[eta] [varchar](10) NOT NULL,
	[totale_popolazione] [int] NOT NULL
) ON [PRIMARY]
GO

-- Drop if exists and create Italia-OD vaccine-administrations-data table
DROP TABLE IF EXISTS [dbo].[somministrazioni-vaccini-latest]
GO
CREATE TABLE [dbo].[somministrazioni-vaccini-latest](
	[data] [date] NOT NULL,
	[forn] [nvarchar](50) NOT NULL,
	[area] [nvarchar](50) NOT NULL,
	[eta] [nvarchar](50) NOT NULL,
	[m] [int] NOT NULL,
	[f] [int] NOT NULL,
	[d1] [int] NOT NULL,
	[d2] [int] NOT NULL,
	[dpi] [int] NOT NULL,
	[db1] [int] NOT NULL,
	[dbi] [int] NOT NULL,
	[db2] [int] NOT NULL,
	[N1] [nvarchar](50) NOT NULL,
	[N2] [nvarchar](50) NOT NULL,
	[ISTAT] [int] NOT NULL,
	[reg] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO

-- Drop and create Fact table
DROP TABLE IF EXISTS [dbo].[Fact]
GO
CREATE TABLE [dbo].[Fact](
	[Data] [date] NULL,
	[DataTypeKey] [int] NOT NULL,
	[RegionKey] [int] NOT NULL,
	[ProviderKey] [bigint] NULL,
	[AgeRangeKey] [int] NULL,
	[PopKey] [bigint] NULL,
	[Ricoverati con sintomi] [bigint] NOT NULL,
	[T.I.] [bigint] NOT NULL,
	[T.I. Giornaliere] [bigint] NOT NULL,
	[Totale ospedalizzati] [bigint] NOT NULL,
	[Isolamento domiciliare] [bigint] NOT NULL,
	[Totale Positivi] [bigint] NOT NULL,
	[Variazione Totale Positivi] [bigint] NOT NULL,
	[Nuovi Positivi] [bigint] NOT NULL,
	[Dimessi] [bigint] NOT NULL,
	[Decessi] [bigint] NOT NULL,
	[Decessi Giornalieri] [bigint] NOT NULL,
	[Totale Casi] [bigint] NOT NULL,
	[Tamponi] [bigint] NOT NULL,
	[Tamponi Giornalieri] [bigint] NOT NULL,
	[Indice di positività] [bigint] NULL,
	[Prima Dose] [int] NULL,
	[Seconda Dose] [int] NULL,
	[Sesso Maschile] [int] NULL,
	[Sesso Femminile] [int] NULL,
	[Pregressa Infezione] [int] NULL,
	[Dose Booster] [int] NULL
) ON [PRIMARY]
GO
-- END TABLES