From: Erich Focht <efocht@gmail.com>
Date: Tue, 03 May 2011 14:46:37 +0200
Subject: [Lustre-devel] accessing object version from user space?
Message-ID: <4DBFF92D.6070304@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

is there a way to access the file objects version information (epoch, transno, whatever is used
for version based recovery) from user space? If yes, is that possible for lustre 1.8.x, too?
Looking for a way to check (quickly) whether a file has changed while copying it away...

Erich
