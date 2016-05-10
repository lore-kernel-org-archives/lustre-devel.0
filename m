From: Quentin BOUGET <quentin.bouget.ocre@cea.fr>
Date: Tue, 10 May 2016 16:14:55 +0200
Subject: [lustre-devel] Fwd: llmount.sh does not use fs-specific paths to
 the ost(s) and mds it mounts
In-Reply-To: <5731EAC3.5070207@cea.fr>
References: <5731EAC3.5070207@cea.fr>
Message-ID: <5731ECDF.10801@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

While trying to mount two different lustre filesystems on a local node 
with the "llmount.sh" script, I noticed that the path to mount mds and 
ost(s) was computed like this:

    eval mntpt=${!var:-${MOUNT%/*}/$facet} # var is not defined by
    default, so this removes
         # everything after the last '/' of $MOUNT

The code can be found at test-framework.sh in the function "facet_mntpt" 
around the line 3226.


By default MOUNT is initialized like this:

    MOUNT=${MOUNT:-/mnt/${FSNAME}} # default: "/mnt/lustre"

Thus the default mountpoints for mds and ost(s) are "/mnt/mds1" and 
"/mnt/ost1".
Because of that, when trying to do two successive calls to "llmount.sh" 
with two different values for FSNAME, the second fs to be mounted will 
unmount the first's mds and ost(s) (paths are identical).


Is there any reason to truncate the MOUNT variable like this ? Shouldn't 
the mountpoint path look more like "/mnt/<fsname>-mds1" and 
"/mnt/<fsname>-ost1" ?


Regards,
Quentin Bouget


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160510/809629ec/attachment.htm>
