From: bzzz.tomas at gmail.com <bzzz.tomas@gmail.com>
Date: Wed, 27 Oct 2010 17:17:31 +0400
Subject: [Lustre-devel] changelog for whole filesystem?
In-Reply-To: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
References: <855B43E2-1D24-4095-ABE7-643A3ADAD67D@oracle.com>
Message-ID: <4CC8266B.8020903@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/27/10 5:06 PM, Andreas Dilger wrote:
> I had an interesting idea today during a discussion on HSM.  One of the issues with enabling HSM today is that a full-filesystem scan must be done initially to populate the policy engine database.
>
> I was thinking that it would be useful to have a virtual changelog that provides a feed from internally traversing the whole filesystem in an efficient manner.  For bug 22741 we have implemented a virtual index in the OSD which will return all of the in-use ldiskfs inodes in inode-number order (which is the fastest way to read/stat all of the inodes).  It probably wouldn't be too hard to hook this OSD callback into the changelog API, so that reading a special changelog file would return all of the files in the filesystem.  It is possible to generate the full pathnames of these inodes via the "link" xattr, if that is needed.

probably you meant to iterate over OI ?

thanks, z
