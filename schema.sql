USE [px]
GO
/****** Object:  Table [dbo].[sessions]    Script Date: 14/07/2022 22:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sessions](
	[session_id] [int] NOT NULL,
	[client_id] [varchar](255) NOT NULL,
	[y] [int] NOT NULL,
	[last_login] [int] NOT NULL,
	[comment] [text] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[sessions] ADD  CONSTRAINT [DF_sessions_session_id]  DEFAULT ((1)) FOR [session_id]
GO
ALTER TABLE [dbo].[sessions] ADD  CONSTRAINT [DF_sessions_y]  DEFAULT ((1)) FOR [y]
GO
