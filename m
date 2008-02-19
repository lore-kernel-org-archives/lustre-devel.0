From: Vitaly Fertman <vitaly@sun.com>
Date: Tue, 19 Feb 2008 23:33:52 +0300
Subject: [Lustre-devel] on-disk SOM attributes [former storing SOM epoch in
	EA]
In-Reply-To: <47BAA607.1000600@sun.com>
References: <47BAA607.1000600@sun.com>
Message-ID: <200802192333.52663.vitaly@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,

Besides the question Alex asked, there are some more issues
I would like to discuss, so let me list all of them here.

1) where to store on-disk IOepoch on MDS -- this question
was described in the Alex's initial "storing SOM epoch in EA"
email, so I will not repeat it here.

2) where to store SOM-ENABLE flag in inode?
currently it is stored in inode flags, but it may be not
acceptable for DMU. If so, we will probably need to move it
to the place we will store on-disk IOepoch in (EA?).

I also want to mention that on-disk IOepoch is needed at the
attribute update time only, to be sure we write newer attributes.
Whereas SOM-ENABLE flag is needed more often, thus it is also
checked when we tell a client size is valid at getattr.

3) how to avoid e2fsck zeroing i_blocks on MDS?
we could patch e2fsck, or alternatively store i_blocks copy
in inode that fsck does not know about, e.g. in the same EA.

As i_blocks is needed on each getattr, it is worth to store
it along with SOM-ENABLE flag.

Please advise.

-- 
Vitaly
