From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 13 Nov 2015 09:17:12 +1100
Subject: [lustre-devel] next-20151101 - depmod issues with Lustre modules
In-Reply-To: <CA+55aFxJYvGWszcgbWe-xAnrm7p=RpmXz30jRVRTZM4PbQPZbA@mail.gmail.com>
References: <8398.1446478793@turing-police.cc.vt.edu>
	<CAJwJo6YTNB38rYAYwExom4WW5yRJ9eUSXNV4a+xW026VY2iwTg@mail.gmail.com>
	<CA+55aFxJYvGWszcgbWe-xAnrm7p=RpmXz30jRVRTZM4PbQPZbA@mail.gmail.com>
Message-ID: <20151113091712.2018501c@canb.auug.org.au>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Linus,

On Sat, 7 Nov 2015 14:30:44 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> I do wonder if linux-next could perhaps do some modprobe testing too?

I have added an x86_64 allmodconfig modules_install to my
end-of-day-before-release builds.  Is that useful/sufficient?  It seems
to work fine at the moment.

-- 
Cheers,
Stephen Rothwell                    sfr at canb.auug.org.au
