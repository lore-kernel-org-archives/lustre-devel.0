From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 19 Dec 2012 17:56:54 +0000
Subject: [Lustre-devel] ZFS OSD
In-Reply-To: <-5911792391846391452@unknownmsgid>
References: <-5911792391846391452@unknownmsgid>
Message-ID: <56693337-F8C5-4405-9070-20FDBC59D493@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-12-18, at 17:29, John Bent <johnbent@gmail.com> wrote:

> Is the code available for the ZFS OSD that's in 2.4?  I was curious to
> see what that looks like but couldn't find it online.  Perhaps I
> missed it?

John, yes the osd-zfs source code is available in the Lustre git repository, in the master branch only. It was also in the 2.3 release as a preview for OSTs only, while the 2.4 release will be the first one that is functional for the MDT.

The ZFS code itself is available at zfsonlinux.org in various forms.

Cheers, Andreas
