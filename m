From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 16:44:11 +0100 (BST)
Subject: [lustre-devel] `lfs check` misleading documentation
In-Reply-To: <E635A293-E169-4CB7-B95D-6A952E738542@intel.com>
References: <1466991524903229@web24g.yandex.ru>
 <E635A293-E169-4CB7-B95D-6A952E738542@intel.com>
Message-ID: <alpine.LFD.2.21.1805151643080.28403@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> George, thanks for the patches.
> 
> Note that despite Peter's comments, the right place for this ticket is in the Lustre (LU) project, because it is a change that needs to be applied to the Lustre source tree. 
> 
> For issues with the Lustre User Manual the right project is indeed LUDOC as Peter suggested.
> 
> If you are feeling particularly adventurous, you could split off the "lfs check" command into its own "lfs-check.1" man page, as is being done with other commands such as "lfs-setstripe.1", etc. 
> 
> This allows more space to describe each command and all the arguments, as well as provide examples. 

Just to let you know I have merged George's fix into the patch 
https://review.whamcloud.com/#/c/31618.

> > 
> > Hello, 
> > 
> > I've found that `lfs check` command documentation and arguments are misleading,
> > it is used to check targets, not servers, as documentation states (or am I wrong?).
> > 
> > I didn't found the better place for patches or discussions (can't find how to register in Jira),
> > so I propose a patch here.
> > 
> > I'll be glad if someone can give me the right direction for such cases.
> > 
> > From 2aaf4fa4a12ce38d283725410f4f7d0f3b1488ab Mon Sep 17 00:00:00 2001
> > From: George Melikov <mail@gmelikov.ru>
> > Date: Fri, 20 Apr 2018 15:27:00 +0300
> > Subject: [PATCH] Fix `lfs check` documentation and arguments
> > 
> > ---
> > lustre/doc/lfs.1   | 8 +++++---
> > lustre/utils/lfs.c | 4 ++--
> > 2 files changed, 7 insertions(+), 5 deletions(-)
> > 
> > diff --git a/lustre/doc/lfs.1 b/lustre/doc/lfs.1
> > index 29cd139519..714785fa63 100644
> > --- a/lustre/doc/lfs.1
> > +++ b/lustre/doc/lfs.1
> > @@ -7,7 +7,7 @@ lfs \- client utility for Lustre-specific file layout and other attributes
> > .br
> > .B lfs changelog_clear <mdtname> <id> <endrec>
> > .br
> > -.B lfs check <mds|osts|servers>
> > +.B lfs check <mds|mdts|osts|all|servers>
> > .br
> > .B lfs data_version [-n] \fB<filename>\fR
> > .br
> > @@ -151,8 +151,10 @@ interest to a particular consumer <id>, potentially allowing the MDT to
> > free up disk space. An <endrec> of 0 indicates the current last record.
> > Changelog consumers must be registered on the MDT node using \fBlctl\fR.
> > .TP
> > -.B check
> > -Display the status of MDS or OSTs (as specified in the command) or all the servers (MDS and OSTs)
> > +.B check <mds|mdts|osts|all|servers>
> > +Check and display the status of MDTs or OSTs (as specified in the command)
> > +or all (MDTs and OSTs). \fBmds\fR and \fBservers\fR arguments are equal to
> > +\fBmdts\fR and \fBall\fR, respectively, and remain for backward compatibility only.
> > .TP
> > .B data_version [-n] <filename>
> > Display current version of file data. If -n is specified, data version is read
> > diff --git a/lustre/utils/lfs.c b/lustre/utils/lfs.c
> > index 4dcb8f31a1..a7a9de9e73 100644
> > --- a/lustre/utils/lfs.c
> > +++ b/lustre/utils/lfs.c
> > @@ -5152,9 +5152,9 @@ static int lfs_check(int argc, char **argv)
> > 
> >         if (strcmp(argv[1], "osts") == 0) {
> >                 strcpy(obd_types[0], "osc");
> > -        } else if (strcmp(argv[1], "mds") == 0) {
> > +        } else if (strcmp(argv[1], "mds") == 0 || strcmp(argv[1], "mdts") == 0) {
> >                 strcpy(obd_types[0], "mdc");
> > -        } else if (strcmp(argv[1], "servers") == 0) {
> > +        } else if (strcmp(argv[1], "servers") == 0 || strcmp(argv[1], "all") == 0) {
> >                 num_types = 2;
> >                 strcpy(obd_types[0], "osc");
> >                 strcpy(obd_types[1], "mdc");
> > -- 
> > 2.14.2
> > 
> > ____________________________________
> > Sincerely,
> > George Melikov,
> > Tel. 7-915-278-39-36
> > Skype: georgemelikov
> > _______________________________________________
> > lustre-devel mailing list
> > lustre-devel at lists.lustre.org
> > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
