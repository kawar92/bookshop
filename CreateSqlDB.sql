USE [master]
GO
/****** Object:  Database [BooksDB]    Script Date: 29.03.2017 11:53:39 ******/
CREATE DATABASE [BooksDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BooksDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\BooksDB.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'BooksDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\BooksDB_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [BooksDB] SET COMPATIBILITY_LEVEL = 120
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BooksDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BooksDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BooksDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BooksDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BooksDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BooksDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [BooksDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BooksDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BooksDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BooksDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BooksDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BooksDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BooksDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BooksDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BooksDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BooksDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BooksDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BooksDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BooksDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BooksDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BooksDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BooksDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BooksDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BooksDB] SET RECOVERY FULL 
GO
ALTER DATABASE [BooksDB] SET  MULTI_USER 
GO
ALTER DATABASE [BooksDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BooksDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BooksDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BooksDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [BooksDB] SET DELAYED_DURABILITY = DISABLED 
GO
USE [BooksDB]
GO
/****** Object:  Table [dbo].[book]    Script Date: 29.03.2017 11:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[book](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](50) NOT NULL,
	[author] [varchar](50) NOT NULL,
	[price] [float] NOT NULL,
	[genre] [varchar](20) NOT NULL,
	[country] [varchar](50) NOT NULL,
	[image] [varchar](255) NULL,
	[review] [text] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[orders]    Script Date: 29.03.2017 11:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[orders](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[client] [varchar](50) NOT NULL,
	[book] [varchar](250) NOT NULL,
	[amount] [int] NOT NULL,
	[price] [float] NOT NULL,
	[date] [date] NOT NULL,
	[orderShipped] [bit] NOT NULL,
 CONSTRAINT [PK_orders] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[users]    Script Date: 29.03.2017 11:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[password] [nvarchar](50) NOT NULL,
	[email] [nvarchar](250) NOT NULL,
	[user_type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_users_name] UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  StoredProcedure [dbo].[spGetGroupedOrders]    Script Date: 29.03.2017 11:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetGroupedOrders]
@date1 as DATE,
@date2 as DATE,
@shipped as BIT	
AS
BEGIN
	select client, date, SUM(total) as total
		FROM (
				SELECT client, date, (amount*price) AS total
				FROM [BooksDB].[dbo].[orders]
				WHERE date >= @date1
				AND date <= @date2
				AND orderShipped = @shipped
			) as result
			GROUP BY client, date
END
GO
/****** Object:  StoredProcedure [dbo].[spGetOrdersDetailed]    Script Date: 29.03.2017 11:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spGetOrdersDetailed]
@client AS nvarchar(30),
@date AS DATE
AS
BEGIN
SELECT
	book,
	SUM(amount) AS amount,
	price,
	orderShipped,
	SUM(amount * price) AS total
FROM
	orders
WHERE
	client = @client
AND 
	date = @date
GROUP BY
	book, price, orderShipped
END

	

GO
USE [master]
GO
ALTER DATABASE [BooksDB] SET  READ_WRITE 
GO
