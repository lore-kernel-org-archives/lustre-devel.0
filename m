From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 19 Dec 2012 10:09:42 -0800
Subject: [Lustre-devel] ZFS OSD
In-Reply-To: <-5911792391846391452@unknownmsgid>
References: <-5911792391846391452@unknownmsgid>
Message-ID: <50D202E6.8030703@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes, the ZFS code is in the master branch in the main git repo, and will 
be included in Lustre when 2.4 is tagged at the end of April, 2013.

Look in the lustre/osd-zfs subdirectory.

Brian Behlendorf has an example of setting up lustre with zfs here:

   http://zfsonlinux.org/lustre-configure-single.html

But I note that there are still references to the development "orion" 
branch, so it needs updating.  If you try the instructions there and 
have any trouble, let me know and we'll update it.

Chris

On 12/18/2012 04:29 PM, John Bent wrote:
> Hello,
>
> Is the code available for the ZFS OSD that's in 2.4?  I was curious to
> see what that looks like but couldn't find it online.  Perhaps I
> missed it?
>
> Thanks,
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
