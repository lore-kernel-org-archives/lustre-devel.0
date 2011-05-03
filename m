From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 3 May 2011 13:35:12 -0600
Subject: [Lustre-devel] accessing object version from user space?
In-Reply-To: <4DBFF92D.6070304@gmail.com>
References: <4DBFF92D.6070304@gmail.com>
Message-ID: <AD1E6969-051D-41AA-BE5D-E89F114C0317@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 3, 2011, at 06:46, Erich Focht wrote:
> is there a way to access the file objects version information (epoch, transno, whatever is used
> for version based recovery) from user space? If yes, is that possible for lustre 1.8.x, too?
> Looking for a way to check (quickly) whether a file has changed while copying it away...

Comparing the ctime at the start/end of the copy should be enough for that.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
