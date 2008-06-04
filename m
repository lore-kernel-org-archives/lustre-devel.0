From: Daire Byrne <Daire.Byrne@framestore.com>
Date: Wed, 4 Jun 2008 10:11:29 +0100 (BST)
Subject: [Lustre-devel] Re-direction inodes
In-Reply-To: <20080602170937.GI2961@webber.adilger.int>
Message-ID: <2029119379.1130931212570689447.JavaMail.root@dahlback.prod.local>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


----- "Andreas Dilger" <adilger@sun.com> wrote:

> filesystems it is possible to encode part of the pathname somewhat
> like:
> 
> 	/home///$UID///file
> 
> but I think you are proposing a completely transparent mapping of
> content:
> 
> alice> cat /etc/passwd
> alice:x:1000:1000:Alice:/home/alice:/bin/bash
> 
> bob> cat /etc/passwd
> bob:x:1001:1001:Bob:/home/bob:/bin/bash

I *think* autofs5 allows for $UID/$GID in mount maps to provide different mountpoints - but that only gives you a whole unique tree not individual files. Depending on the number of files you wish to be unique for each user you could perhaps use a symlink for the file which then points to an autofs5 map with a $UID in it. You may need to use --bind mounts if it points to a LustreFS.

Daire
