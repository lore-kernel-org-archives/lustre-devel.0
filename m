From: Thomas Roth <t.roth@gsi.de>
Date: Thu, 05 May 2011 19:54:55 +0200
Subject: [Lustre-devel] [Lustre-discuss] Research on filesystem metadata
	operation	distribution
In-Reply-To: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
References: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
Message-ID: <4DC2E46F.5020509@gsi.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

At GSI, we have

lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
open                      10302752480 samples [reqs]
close                     528292519 samples [reqs]
unlink                    22292174 samples [reqs]
rename                    542512 samples [reqs]
getxattr                  408511496 samples [reqs]
setxattr                  838368 samples [reqs]
setattr                   27097846 samples [reqs]
getattr                   738233548 samples [reqs]

Output of 'lfs df' is attached.

The filesystem is used for storing HEP data from theory calculations, 
simulations and HEP experimental data for use in analysis. People also 
use it as a software repository, to compile their programs (ouch) and as 
a general purpose distributed file system (a certain sysadmin is known 
to store his music files there).

Regards,
Thomas

On 04/21/2011 08:40 PM, Andreas Dilger wrote:
> I'm trying to get some data about the relative distribution of MDS operations in the wild, and I'd be grateful if some people with production filesystems that have been running for at least a week could collect some simple stats and email them to me.  They can be collected by any regular user on the MDS node:
>
>      lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"
>
> It would be useful to also include "lfs df" and "lfs df -i" information, as well as a brief description of what the filesystem is used for (scratch, home, project, archive, etc).
>
>
>
> As a reminder, I'm also interested if some Lustre admins could run the "fsstats" tool from http://www.pdsi-scidac.org/fsstats/ and send me the output.  Sending the output to PDSI via their submission form may also produce some positive results.
>
>      http://www.pdsi-scidac.org/fsstats/files/fsstats-1.4.5.tar.gz
>
>
> Thanks in advance for any data.  I've set replies to go only to lustre-devel, to avoid clogging the larger readership of lustre-discuss, but it may be useful for others to have this in a list archive and/or searchable via Google in the future so I don't necessarily want to keep it all to myself.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Principal Engineer
> Whamcloud, Inc.
>
>
>
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss


-- 
--------------------------------------------------------------------
Thomas Roth
Department: Informationstechnologie

GSI Helmholtzzentrum f?r Schwerionenforschung GmbH
Planckstra?e 1
64291 Darmstadt
www.gsi.de

Gesellschaft mit beschr?nkter Haftung
Sitz der Gesellschaft: Darmstadt
Handelsregister: Amtsgericht Darmstadt, HRB 1528

Gesch?ftsf?hrung: Professor Dr. Dr. h.c. Horst St?cker,
Dr. Hartmut Eickhoff

Vorsitzende des Aufsichtsrates: Dr. Beatrix Vierkorn-Rudolph
Stellvertreter: Ministerialdirigent Dr. Rolf Bernhardt

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lfs_df
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110505/c14cc51a/attachment.asc>
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lfs_df_i
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110505/c14cc51a/attachment.txt>
