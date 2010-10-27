From: LEIBOVICI Thomas <thomas.leibovici@cea.fr>
Date: Wed, 27 Oct 2010 17:28:09 +0200
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
Message-ID: <4CC84509.4050609@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Would this special log have the same record structure as current 
changelogs, or a different structure with more information?
Depending on how this iterator works, maybe we can avoid RPCs (for stat, 
fid2path, get_stripe, hsm_state_get...) if this info is available when 
the log record is generated.
Anyhow, this feature sounds very interesting. We'll be glad to help, if 
you need taskforce for implementing such a feature.

Thomas

Andreas Dilger wrote:
> I had an interesting idea today during a discussion on HSM.  One of the issues with enabling HSM today is that a full-filesystem scan must be done initially to populate the policy engine database.
>
> I was thinking that it would be useful to have a virtual changelog that provides a feed from internally traversing the whole filesystem in an efficient manner.  For bug 22741 we have implemented a virtual index in the OSD which will return all of the in-use ldiskfs inodes in inode-number order (which is the fastest way to read/stat all of the inodes).  It probably wouldn't be too hard to hook this OSD callback into the changelog API, so that reading a special changelog file would return all of the files in the filesystem.  It is possible to generate the full pathnames of these inodes via the "link" xattr, if that is needed.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Technical Lead
> Oracle Corporation Canada Inc.
>
>   
