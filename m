From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 21 Apr 2011 12:40:15 -0600
Subject: [Lustre-devel] Research on filesystem metadata operation
	distribution
Message-ID: <C09F427D-51DA-420F-83B6-D10F30347750@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm trying to get some data about the relative distribution of MDS operations in the wild, and I'd be grateful if some people with production filesystems that have been running for at least a week could collect some simple stats and email them to me.  They can be collected by any regular user on the MDS node:

    lctl get_param mds.*.stats | egrep "open|close|rename|link|attr|sync"

It would be useful to also include "lfs df" and "lfs df -i" information, as well as a brief description of what the filesystem is used for (scratch, home, project, archive, etc).



As a reminder, I'm also interested if some Lustre admins could run the "fsstats" tool from http://www.pdsi-scidac.org/fsstats/ and send me the output.  Sending the output to PDSI via their submission form may also produce some positive results.

    http://www.pdsi-scidac.org/fsstats/files/fsstats-1.4.5.tar.gz


Thanks in advance for any data.  I've set replies to go only to lustre-devel, to avoid clogging the larger readership of lustre-discuss, but it may be useful for others to have this in a list archive and/or searchable via Google in the future so I don't necessarily want to keep it all to myself.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
